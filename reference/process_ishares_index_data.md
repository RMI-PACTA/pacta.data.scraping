# Process raw iShares data into PACTA readable format

Process raw iShares data into PACTA readable format

## Usage

``` r
process_ishares_index_data(data)
```

## Arguments

- data:

  An iShares index dataset, like the output of
  [`get_ishares_index_data()`](https://rmi-pacta.github.io/pacta.data.scraping/reference/get_ishares_index_data.md).

## Value

A processed dataset, formatted for input into
`pacta.portfolio.analysis`.
