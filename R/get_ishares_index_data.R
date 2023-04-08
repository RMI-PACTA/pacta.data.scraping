#' Scrape index data from the iShares website
#'
#' This function will scrape and process holdings data from the iShares website.
#'
#' @param url A string containing the url of the desired iShares index data.
#' @param name A string containing the name of the index.
#' @param timestamp A string indicating the desired timestamp, by year and
#'   quarter, "YYYYMMDD" (e.g. "20201231"). Data will be scraped for the first
#'   day in the corresponding quarter.
#'
#' @return A data.frame, containing the un-processed iShares data.
#'
#' @examples
#' \dontrun{
#' url <-
#'   paste0(
#'     "https://www.ishares.com/uk/individual/en/products/",
#'     "251813/ishares-global-corporate-bond-ucits-etf/"
#'   )
#' name <- "iShares Global Corporate Bond UCITS ETF <USD (Distributing)>"
#' timestamp <- "20211231"
#'
#' get_ishares_index_data(url, name, timestamp)
#' }
#'
#' @export

get_ishares_index_data <- function(url, name, timestamp) {
  page_url <- paste0(url, "/?siteEntryPassthrough=true")
  page_path <- curl::curl_download(page_url, tempfile())

  data_names <-
    rvest::read_html(page_path) %>%
    rvest::html_elements("#allHoldingsTable thead th") %>%
    rvest::html_text(trim = TRUE)

  data_url <- paste0(url, "/1506575576011.ajax?tab=all&fileType=json&asOfDate=", timestamp)
  data_path <- curl::curl_download(data_url, tempfile())

  raw_data <- suppressWarnings(
    # FIXME: froJSON gives following warning message:
    # JSON string contains (illegal) UTF8 byte-order-mark!
    jsonlite::fromJSON(data_path)$aaData
  )

  fixed_data <- fix_data(raw_data, data_names)

  fixed_data %>%
    dplyr::mutate(
      base_url = .env$url,
      index_name = .env$name,
      timestamp = .env$timestamp
    )
}

fix_data <- function(data, data_names) {
  dplyr::bind_rows(
    lapply(
      data,
      function(item) {
        out <- stats::setNames(lapply(item, pick_raw_name), data_names)
        out[] <- lapply(out, as.character)
      }
    )
  )
}

pick_raw_name <- function(data) {
  ifelse("raw" %in% names(data), data[["raw"]], data[[1]])
}
