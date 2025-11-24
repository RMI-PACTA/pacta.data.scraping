# Get currency exchange rates for a given quarter from the IMF API

Get currency exchange rates for a given quarter from the IMF API

## Usage

``` r
get_currency_exchange_rates(quarter, max_seconds = 60L)
```

## Arguments

- quarter:

  A single string containing the desired quarter of data in the form
  "2022-Q4".

- max_seconds:

  A single numeric containing the max number of seconds it should wait
  for a response

## Value

A dataframe containing columns `currency` and `exchange_rate`
