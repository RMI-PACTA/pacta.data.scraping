test_that("", {
  test_data <- tibble::tibble(
    `Issuer Ticker` = c("-", "JGB", "JGB"),
    Name = c("Acme", "ABC Corp.", "XYC Ltd."),
    Sector = c("Cash and/or Derivatives", "Treasuries", "Treasuries"),
    `Asset Class` = c("Money Market", "Fixed Income", "Fixed Income"),
    `Market Value` = c("16203066.86", "12070930.45", "11399306.97"),
    `Weight (%)` = c("0.47758", "0.35578", "0.33599"),
    `Notional Value` = c("16203066.86", "12070930.45", "11399306.97"),
    Nominal = c("161978", "1375000000", "1301500000"),
    `Par Value` = c("161978", "1375000000", "1301500000"),
    ISIN = c("IE00BK8MB266", "JP1103521JA8", "JP1103251C91"),
    Price = c("100.03", "0.88", "0.87"),
    Location = c("Ireland", "Japan", "Japan"),
    Exchange = c("-", "-", "-"),
    Duration = c("0.09", "6.7", "0.72"),
    Maturity = c(NA, "20280920", "20220920"),
    `Coupon (%)` = c("0.1", "0.1", "0.8"),
    `Market Currency` = c("USD", "JPY", "JPY"),
    `Effective Date` = c("24/Jul/2019", "03/Oct/2018", "20/Sept/2012"),
    base_url = c("https://test_url.com",
                 "https://test_url.com","https://test_url.com"),
    index_name = c("Test Index", "Test Index", "Test Index"),
    as_of_date = c("20211231", "20211231", "20211231")
  )

  test_expected <- tibble::tibble(
    investor_name = c("Indices2021Q4", "Indices2021Q4", "Indices2021Q4"),
    portfolio_name = c("Test Index", "Test Index", "Test Index"),
    isin = c("IE00BK8MB266", "JP1103251C91", "JP1103521JA8"),
    market_value = c(16203066.86, 11399306.97, 12070930.45),
    weight = c(0.47758, 0.33599, 0.35578),
    currency = c("USD", "JPY", "JPY")
  )

  result <- process_ishares_index_data(test_data)
  expect_equal(result, test_expected)
})
