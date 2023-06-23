#' Get the definition of MSCI regions (in terms of member countries)
#'
#' @return A dataframe containing columns `equity_market`, `country`, and
#'   `country_iso`
#'
#' @export

get_index_regions <- function() {

  # developed countries --------------------------------------------------------

  dev_url <- "https://www.msci.com/our-solutions/indexes/developed-markets"

  dev_html <- fetch_url_html(dev_url)

  dev_countries <-
    dev_html %>%
    rvest::html_elements(css = ".cw-table") %>%
    rvest::html_elements("td:not(.heading2)") %>%
    rvest::html_text2() %>%
    stringr::str_trim()

  dev_countries <- dev_countries[dev_countries != ""]

  # emerging countries ---------------------------------------------------------

  em_url <- "https://www.msci.com/our-solutions/indexes/emerging-markets"

  em_html <- fetch_url_html(em_url)

  js_scripts <- rvest::html_elements(em_html, "div.portlet-body script")

  js_script <- js_scripts[grepl("chartDataEMJson", js_scripts)]

  ct <- V8::v8()
  #parse the html content from the js output and print it as text
    render_script <- str_replace(
      pattern = 'document.write',
      replacement = '',
      string = rvest::html_text2(js_script)
    )
    ct$eval(render_script)

  data <- jsonlite::parse_json(
    ct$get("JSON.stringify(chartDataEMJson)"),
    flatten = TRUE
  )

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

  stopifnot(length(dev_countries) > 0 && length(em_countries) > 0)

  # compile the data into the index_regions format -----------------------------

  global_countries <- unique(c(dev_countries, em_countries))

  list(
    tibble::tibble(equity_market = "GlobalMarket", country = global_countries),
    tibble::tibble(equity_market = "DevelopedMarket", country = dev_countries),
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
