#' Get the definition of MSCI regions (in terms of member countries)
#'
#' @return A dataframe containing columns `equity_market`, `country`, and
#'   `country_iso`
#'
#' @export

get_index_regions <- function() {

  log_info("Fetching index regions.")

  ct <- V8::v8()

  # developed countries --------------------------------------------------------

  dm_url <- "https://www.msci.com/our-solutions/indexes/developed-markets"
  log_debug("fetching html from %s", dm_url)
  dm_html <- fetch_url_html(dm_url)

  log_debug("extracting developing markets javascript.")
  dm_js_scripts <- rvest::html_elements(dm_html, "div.portlet-body script")
  dm_js_script <- dm_js_scripts[grepl("chartDataDMJson", dm_js_scripts)]

  #parse the html content from the js output and print it as text
  log_debug("rendering javascript.")
  dm_render_script <- stringr::str_replace(
    pattern = 'document.write',
    replacement = '',
    string = rvest::html_text2(dm_js_script)
  )
  ct$eval(dm_render_script)

  dm_data <- jsonlite::parse_json(
    ct$get("JSON.stringify(chartDataDMJson)"),
    flatten = TRUE
  )
  if (length(dm_data$categories) == 0) {
    log_error("No data found for Developed Markets.")
    stop("No data found for Developed Markets.")
  }
  
  log_debug("extracting data from script.")
  dm_countries <- c()
  for (category in dm_data$categories) {
    for (type in category$type) {
      for (index in type$index) {
        for (name in index$name) {
          dm_countries <- c(dm_countries, name)
        }
      }
    }
  }

  dm_countries <- dm_countries[dm_countries != ""]

  # emerging countries ---------------------------------------------------------

  em_url <- "https://www.msci.com/our-solutions/indexes/emerging-markets"
  log_debug("fetching html from %s", dm_url)
  em_html <- fetch_url_html(em_url)

  log_debug("extracting emerging markets javascript.")
  js_scripts <- rvest::html_elements(em_html, "div.portlet-body script")
  js_script <- js_scripts[grepl("chartDataEMJson", js_scripts)]

  #parse the html content from the js output and print it as text
  log_debug("rendering javascript.")
    render_script <- stringr::str_replace(
      pattern = 'document.write',
      replacement = '',
      string = rvest::html_text2(js_script)
    )
    ct$eval(render_script)

  data <- jsonlite::parse_json(
    ct$get("JSON.stringify(chartDataEMJson)"),
    flatten = TRUE
  )
  if (length(data$categories) == 0) {
    log_error("No data found for Emerging Markets.")
    stop("No data found for Emerging Markets.")
  }

  log_debug("extracting data from script.")
  em_countries <- c()
  for (category in data$categories) {
    for (type in category$type) {
      for (index in type$index) {
        for (name in index$name) {
          em_countries <- c(em_countries, name)
        }
      }
    }
  }

  # error if values are empty --------------------------------------------------

  stopifnot(length(dm_countries) > 0 && length(em_countries) > 0)

  # compile the data into the index_regions format -----------------------------

  global_countries <- unique(c(dm_countries, em_countries))

  list(
    tibble::tibble(equity_market = "GlobalMarket", country = global_countries),
    tibble::tibble(equity_market = "DevelopedMarket", country = dm_countries),
    tibble::tibble(equity_market = "EmergingMarket", country = em_countries),
    tibble::tibble(equity_market = "USMarket", country = "United States")
  ) %>%
  dplyr::bind_rows() %>%
  dplyr::mutate(country = countryname(.data$country)) %>% # standardize names
  dplyr::mutate(country_iso = countryname(.data$country, "iso2c")) %>%
  dplyr::distinct() %>%
  dplyr::arrange("equity_market", "country", "country_iso")
}

fetch_url_html <- function(url) {
  url %>%
    httr2::request() %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_perform() %>%
    httr2::resp_body_html()
}
