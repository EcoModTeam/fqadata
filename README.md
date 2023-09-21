
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fqadata

<!-- badges: start -->

[![R-CMD-check](https://github.com/ifoxfoot/fqadata/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/ifoxfoot/fqadata/actions/workflows/check-standard.yaml)
[![](https://cranlogs.r-pkg.org/badges/grand-total/fqadata)](https://cran.r-project.org/package=fqadata)
<!-- badges: end -->

`fqadata` contains regional Floristic Quality Assessment databases that
have been approved or approved with reservations by the U.S. Army Corps
of Engineers. Paired with the
[fqacalc](https://github.com/ifoxfoot/fqacalc) package, these datasets
allow for Floristic Quality Assessment metrics to be calculated. Both
packages were developed for the USACE by the U.S. Army Engineer Research
and Development Center’s Environmental Laboratory.

## Installation

``` r
# install the package from CRAN
install.packages("fqadata")
```

You can also install the development version of fqadata from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ifoxfoot/fqadata")
```

## Example

To access the dataa:

``` r
library(fqadata)

#view data set
head(fqa_db)
#>                                name              name_origin acronym
#> 1                    ACORUS CALAMUS accepted_scientific_name   ACCA4
#> 2                ACALYPHA GRACILENS accepted_scientific_name   ACGR2
#> 3    ACALYPHA GRACILENS VAR. DELZII                  synonym   ACGRD
#> 4   ACALYPHA GRACILENS VAR. FRASERI                  synonym   ACGRF
#> 5 ACALYPHA VIRGINICA VAR. GRACILENS                  synonym   ACVIG
#> 6                      ACER NEGUNDO accepted_scientific_name   ACNE2
#>   accepted_scientific_name family   nativity c  w wetland_indicator physiognomy
#> 1           Acorus calamus   <NA> introduced 0 -2               OBL        forb
#> 2       Acalypha gracilens   <NA>     native 4  0               FAC        forb
#> 3       Acalypha gracilens   <NA>     native 4  0               FAC        forb
#> 4       Acalypha gracilens   <NA>     native 4  0               FAC        forb
#> 5       Acalypha gracilens   <NA>     native 4  0               FAC        forb
#> 6             Acer negundo   <NA>     native 4  0               FAC        tree
#>    duration               common_name                     fqa_db
#> 1 perennial     Single-Vein Sweetflag appalachian_mountains_2013
#> 2    annual Slender Threeseed Mercury appalachian_mountains_2013
#> 3    annual Slender Threeseed Mercury appalachian_mountains_2013
#> 4    annual Slender Threeseed Mercury appalachian_mountains_2013
#> 5    annual Slender Threeseed Mercury appalachian_mountains_2013
#> 6 perennial                  Boxelder appalachian_mountains_2013
```
