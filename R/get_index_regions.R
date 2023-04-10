#' Get the definition of MSCI regions (in terms of member countries)
#'
#' @return A dataframe containing columns `equity_market`, `country`, and
#'   `country_iso`
#'
#' @export

get_index_regions <- function() {
  em_url <- "https://www.msci.com/our-solutions/indexes/emerging-markets"

  # start the headless browser and capture the DOM as HTML after JavaScript runs
  session <- chromote::ChromoteSession$new()
  session$Network$setUserAgentOverride(userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15")

  { # these commands must be run together, hence the {...}
    session$Page$navigate(em_url, wait_ = FALSE)
    session$Page$loadEventFired() # wait until the page is loaded to continue
  }

  html <- session$Runtime$evaluate("document.documentElement.outerHTML")$result$value

  session$close() # close the headless browser session

  # developed countries --------------------------------------------------------

  dev_countries <-
    html %>%
    rvest::read_html() %>%
    rvest::html_elements(css = "#boxes-container-1 li") %>%
    rvest::html_text2()

  # emerging countries ---------------------------------------------------------

  em_countries <-
    html %>%
    rvest::read_html() %>%
    rvest::html_elements(css = "#boxes-container-2 li") %>%
    rvest::html_text2()

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
