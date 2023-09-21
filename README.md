
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

To access the data:

``` r
library(fqadata)

#view data set
head(fqa_db)
#>                                    name              name_origin acronym
#> 80634                    ACORUS CALAMUS accepted_scientific_name   ACCA4
#> 80635                ACALYPHA GRACILENS accepted_scientific_name   ACGR2
#> 80636    ACALYPHA GRACILENS VAR. DELZII                  synonym   ACGRD
#> 80637   ACALYPHA GRACILENS VAR. FRASERI                  synonym   ACGRF
#> 80638 ACALYPHA VIRGINICA VAR. GRACILENS                  synonym   ACVIG
#> 80639                      ACER NEGUNDO accepted_scientific_name   ACNE2
#>       accepted_scientific_name family   nativity c  w wetland_indicator
#> 80634           Acorus calamus   <NA> introduced 0 -2               OBL
#> 80635       Acalypha gracilens   <NA>     native 4  0               FAC
#> 80636       Acalypha gracilens   <NA>     native 4  0               FAC
#> 80637       Acalypha gracilens   <NA>     native 4  0               FAC
#> 80638       Acalypha gracilens   <NA>     native 4  0               FAC
#> 80639             Acer negundo   <NA>     native 4  0               FAC
#>       physiognomy  duration               common_name
#> 80634        forb perennial     Single-Vein Sweetflag
#> 80635        forb    annual Slender Threeseed Mercury
#> 80636        forb    annual Slender Threeseed Mercury
#> 80637        forb    annual Slender Threeseed Mercury
#> 80638        forb    annual Slender Threeseed Mercury
#> 80639        tree perennial                  Boxelder
#>                           fqa_db
#> 80634 appalachian_mountains_2013
#> 80635 appalachian_mountains_2013
#> 80636 appalachian_mountains_2013
#> 80637 appalachian_mountains_2013
#> 80638 appalachian_mountains_2013
#> 80639 appalachian_mountains_2013
```
