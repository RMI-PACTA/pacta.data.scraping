#' Get currency exchange rates for a given quarter from the IMF API
#'
#' @param quarter A single string containing the desired quarter of data in the
#'   form "2022-Q4".
#' @param max_seconds A single numeric containing the max number of seconds it
#'   should wait for a response
#'
#' @return A dataframe containing columns `currency` and `exchange_rate`
#'
#' @export

get_currency_exchange_rates <-
  function(quarter, max_seconds = 60L) {
    if (!grepl("^20[0-9]{2}-Q[1-4]$", quarter)) {
      error_msg <- "quarter must be in a format like {.val 2021-Q4}, not {.val {quarter}}"
      rlang::abort(cli::format_inline(error_msg))
    }

    database_code <- "IFS"
    indicator_code <- "EDNE_USD_XDC_RATE"
    year <- as.numeric(substring(quarter, 1, 4))

    url <-
      paste0(
        "http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/",
        database_code,
        "/Q..",
        indicator_code,
        "?startPeriod=",
        year,
        "&endPeriod=",
        year
      )

    raw_data <- httr2::request(url) %>%
      httr2::req_headers("Accept" = "application/json") %>%
      httr2::req_timeout(max_seconds) %>%
      httr2::req_retry(
        max_seconds = max_seconds,
        is_transient = ~ httr2::resp_content_type(.x) != "application/json"
        ) %>%
      httr2::req_error(
        is_error = ~ httr2::resp_content_type(.x) != "application/json",
        body = ~ cli::format_inline("IMF API did not return a valid response after {.val {max_seconds}} seconds.")
        ) %>%
      httr2::req_perform() %>%
      httr2::resp_body_json(simplifyVector = TRUE) %>%
      .[["CompactData"]] %>%
      .[["DataSet"]] %>%
      .[["Series"]]

    if (is.null(raw_data)) {
      log_error("No data found for the specified quarter: {quarter}.")
      stop("No data found for the specified quarter.")
    }

    raw_data %>%
      dplyr::rowwise() %>%
      dplyr::mutate(Obs = list(as.data.frame(.data$Obs))) %>%
      tidyr::unnest(cols = "Obs") %>%
      dplyr::filter(.data$`@TIME_PERIOD` == .env$quarter) %>%
      dplyr::mutate(currency = countrycode::countrycode(.data$`@REF_AREA`, "iso2c", "iso4217c", warn = FALSE)) %>%
      dplyr::filter(!is.na(.data$currency)) %>%
      dplyr::select("currency", exchange_rate = "@OBS_VALUE") %>%
      dplyr::distinct() %>%
      dplyr::mutate(exchange_rate = as.numeric(.data$exchange_rate)) %>%
      dplyr::arrange(.data$currency)
  }
