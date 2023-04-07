# test_that("w/ data lacking crucial columns, errors with informative message", {
#   data <- dplyr::tibble(
#     ISIN = "abc123",
#     index_name = "Some Index",
#     timestamp = "2021Q4",
#     `Market Value` = 1.5,
#     `Weight (%)` = 1.0,
#     `Market Currency` = "USD"
#   )
#
#   expect_error_data_missing_names <- function(name) {
#     bad_data <- dplyr::rename(
#       data,
#       bad = dplyr::all_of(name)
#     )
#
#     expect_error(
#       class = "missing_names",
#       process_ishares_index_data(
#         bad_data
#       )
#     )
#   }
#
#   expect_error_data_missing_names("ISIN")
#   expect_error_data_missing_names("index_name")
#   expect_error_data_missing_names("timestamp")
#   expect_error_data_missing_names("Market Value")
#   expect_error_data_missing_names("Weight (%)")
#   expect_error_data_missing_names("Market Currency")
# })
