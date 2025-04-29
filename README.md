
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fqadata

<!-- badges: start -->

[![R-CMD-check](https://github.com/EcoModTeam/fqadata/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/EcoModTeam/fqadata/actions/workflows/check-standard.yaml)
[![](https://cranlogs.r-pkg.org/badges/grand-total/fqadata)](https://cran.r-project.org/package=fqadata)
<!-- badges: end -->

`fqadata` contains regional Floristic Quality Assessment databases that
have been approved or approved with reservations by the U.S. Army Corps
of Engineers. Paired with the
[fqacalc](https://github.com/EcoModTeam/fqacalc) package, these datasets
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
devtools::install_github("EcoModTeam/fqadata")
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

You can also access metadata about each database

``` r
#view metadata
head(fqa_citations)
#>                               fqa_db            recommended         notes
#> 1         appalachian_mountains_2013                    YES Wetlands Only
#> 2 atlantic_coastal_pine_barrens_2018 Yes, with reservations          <NA>
#> 3                chicago_region_2017                    YES          <NA>
#> 4       coastal_plain_southeast_2013                    YES Wetlands Only
#> 5                      colorado_2020                    YES          <NA>
#> 6 dakotas_excluding_black_hills_2017   Previously Certified          <NA>
#>                                                                                                                                                                                                                                                                                 citation
#> 1                                                           Gianopulos, K. 2014. Coefficient of Conservatism Database Development for Wetland Plants\nOccurring in the Southeast United States. NC Dept. of Envir. Quality, Div. of Water Resources: Wetlands Branch. Report to the EPA.
#> 2                                    Faber-Langendoen, D., Cameron, D., Gilman, A. V., Metzler, K. J., Ring, R. M., & Sneddon, L. (2019). Development of an Ecoregional Floristic Quality Assessment Method for the Northeastern United States. Northeastern Naturalist, 26(3), 593-608.
#> 3                                                                                                                              Herman, B., Sliwinski, R. and S. Whitaker. 2017. Chicago Region FQA (Floristic Quality Assessment) Calculator. U.S. Army Corps of Engineers, Chicago, IL.
#> 4                                                            Gianopulos, K. 2014. Coefficient of Conservatism Database Development for Wetland Plants Occurring in the Southeast United States. NC Dept. of Envir. Quality, Div. of Water Resources: Wetlands Branch. Report to the EPA.
#> 5                                                                                           Smith, P., G. Doyle, and J. Lemly. 2020. Revision of Colorado's Floristic Quality Assessment\nIndices. Colorado Natural Heritage Program, Colorado State University, Fort Collins, Colorado.
#> 6 The Northern Great Plains Floristic Quality Assessment Panel. 2001. Coefficients of conservatism for the vascular flora of the Dakotas and adjacent grasslands. U.S. Geological Survey, Biological Resources Division, Information and Technology Report USGS/BRD/ITR-2001-0001, 32 p.
```
