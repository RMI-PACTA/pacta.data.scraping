test_that("outputs crucial names", {
  skip_if_offline()

  url <- "https://www.ishares.com/uk/individual/en/products/251813/ishares-global-corporate-bond-ucits-etf/"
  name <- "iShares Global Corporate Bond UCITS ETF <USD (Distributing)>"
  timestamp <- "20211231"

  out <- get_ishares_index_data(url, name, timestamp)

  names(out)

  crucial_names <- c(
    "ISIN",
    "Market Value",
    "Weight (%)"
  )

  missing_crucial_names <- setdiff(crucial_names, names(out))

  expect_length(missing_crucial_names, 0L)
})
