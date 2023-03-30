
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fqadata

<!-- badges: start -->
<!-- badges: end -->

`fqadata` contains regional Floristic Quality Assessment databases that
have been approved or approved with reservations by the U.S. Army Corps
of Engineers. Paired with the
[fqacalc](https://github.com/ifoxfoot/fqacalc) package, these datasets
allow for Floristic Quality Assessment metrics to be calculated. Both
packages were developed for the USACE by the U.S. Army Engineer Research
and Development Center’s Environmental Laboratory.

## Installation

You can install the development version of fqadata from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ifoxfoot/fqadata")
```

## Example

To access the data:

``` r
library(fqadata)

#view data set
head(fqa_db)
#>                   name              name_origin acronym
#> 1       ABIES CONCOLOR accepted_scientific_name    ABCO
#> 2 ABUTILON THEOPHRASTI accepted_scientific_name    ABTH
#> 3   ACALYPHA GRACILENS accepted_scientific_name   ACGR2
#> 4  ACALYPHA RHOMBOIDEA accepted_scientific_name    ACRH
#> 5   ACALYPHA VIRGINICA accepted_scientific_name    ACVI
#> 6         ACER NEGUNDO accepted_scientific_name   ACNE2
#>   accepted_scientific_name family   nativity c  w wetland_indicator physiognomy
#> 1           Abies concolor   <NA> introduced 0 NA              <NA>        <NA>
#> 2     Abutilon theophrasti   <NA> introduced 0 NA              <NA>        <NA>
#> 3       Acalypha gracilens   <NA>     native 4 NA              <NA>        <NA>
#> 4      Acalypha rhomboidea   <NA>     native 1 NA              <NA>        <NA>
#> 5       Acalypha virginica   <NA>     native 6 NA              <NA>        <NA>
#> 6             Acer negundo   <NA>     native 2 NA              <NA>        <NA>
#>   duration common_name                             fqa_db
#> 1     <NA>        <NA> atlantic_coastal_pine_barrens_2018
#> 2     <NA>        <NA> atlantic_coastal_pine_barrens_2018
#> 3     <NA>        <NA> atlantic_coastal_pine_barrens_2018
#> 4     <NA>        <NA> atlantic_coastal_pine_barrens_2018
#> 5     <NA>        <NA> atlantic_coastal_pine_barrens_2018
#> 6     <NA>        <NA> atlantic_coastal_pine_barrens_2018
```
