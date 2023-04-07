#' Process raw iShares data into PACTA readable format
#'
#' @param data An iShares index dataset, like the output of
#'   `get_ishares_index_data()`.
#'
#' @return A processed dataset, formatted for input into
#'   `pacta.portfolio.analysis`.
#'
#' @export

process_ishares_index_data <- function(data) {
  data[data == "-"] <- NA

  data %>%
    dplyr::mutate(
      `Market Value` = as.double(.data$`Market Value`),
      `Weight (%)` = as.double(.data$`Weight (%)`)
    ) %>%
    # summarize rows without an ISIN into one row (cash, derivatives, futures, etc.)
    dplyr::group_by(.data$ISIN, .data$index_name, .data$timestamp) %>%
    dplyr::summarise(
      `Market Value` = sum(.data$`Market Value`, na.rm = TRUE),
      `Weight (%)` = sum(.data$`Weight (%)`, na.rm = TRUE),
      `Market Currency` = dplyr::if_else(
        dplyr::n() > 1,
        NA_character_,
        .data$`Market Currency`[[1]]
      ),
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      .x = lubridate::ymd(.data$timestamp),
      year_quarter = paste0(lubridate::year(.data$.x), "Q", lubridate::quarter(.data$.x)),
      .x = NULL
    ) %>%
    dplyr::transmute(
      investor_name = as.character(paste0("Indices", .data$year_quarter)),
      portfolio_name = as.character(.data$index_name),
      isin = as.character(.data$ISIN),
      market_value = as.double(.data$`Market Value`),
      weight = as.double(.data$`Weight (%)`),
      currency = as.character(.data$`Market Currency`),
    )
}
