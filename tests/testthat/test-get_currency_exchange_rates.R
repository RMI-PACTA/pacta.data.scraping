test_that("`get_currency_exchange_rates()`", {
  skip_if_offline()
  result <- get_currency_exchange_rates(quarter = "2021-Q4")

  expect_s3_class(result, "tbl_df")
  expect_identical(names(result), c("currency", "exchange_rate"))
  expect_true(nrow(result) > 0)

  expect_type(result$currency, "character")
  expect_true(anyDuplicated(result$currency) == 0)
  expect_true(sum(is.na(result$currency)) == 0)
  expect_true(all(result$currency %in% na.exclude(countrycode::codelist$iso4217c)))

  expect_type(result$exchange_rate, "double")
  expect_true(sum(is.na(result$currency)) == 0)
})
