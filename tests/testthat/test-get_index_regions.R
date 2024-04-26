test_that("returns an appropriate data frame", {
  skip_if_offline()

  logger::log_threshold("OFF")
  result <- get_index_regions()

  expect_s3_class(result, "tbl_df")
  expect_identical(names(result), c("equity_market", "country", "country_iso"))
  expect_true(nrow(result) > 0)

  expect_type(result[["equity_market"]], "character")
  expect_true(all(!is.na(result[["equity_market"]])))

  expect_type(result[["country"]], "character")
  expect_true(all(!is.na(result[["country"]])))
  expect_true(all(!is.na(countrycode::countrycode(result[["country"]], "country.name", "iso2c"))))

  expect_type(result[["country_iso"]], "character")
  expect_true(all(!is.na(result[["country_iso"]])))
  expect_true(all(result[["country_iso"]] %in% na.exclude(countrycode::codelist$iso2c)))
})
