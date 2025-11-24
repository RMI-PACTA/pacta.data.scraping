# Scrape index data from the iShares website

This function will scrape and process holdings data from the iShares
website.

## Usage

``` r
get_ishares_index_data(url, name, as_of_date)
```

## Arguments

- url:

  A string containing the url of the desired iShares index data.

- name:

  A string containing the name of the index.

- as_of_date:

  A string indicating the desired date, by year, month and date,
  "YYYYMMDD" (e.g. "20201231"). Data will be scraped for date specified.

## Value

A data.frame, containing the un-processed iShares data.

## Examples

``` r
if (FALSE) { # \dontrun{
url <-
  paste0(
    "https://www.ishares.com/uk/individual/en/products/",
    "251813/ishares-global-corporate-bond-ucits-etf/"
  )
name <- "iShares Global Corporate Bond UCITS ETF <USD (Distributing)>"
as_of_date <- "20211231"

get_ishares_index_data(url, name, as_of_date)
} # }
```
