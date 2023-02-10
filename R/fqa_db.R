#' Regional Floristic Quality Assessment Databases
#'
#' A data set containing 44 regional Floristic Quality Assessment databases.
#' Each of these databases has been approved or approved with reservations for use
#' by the US Army Corps of Engineers. Paired with the `fqacalc` R package, these
#' data sets allow for Floristic Quality Assessment metrics to be calculated.
#'
#' @format A data frame with 128554 rows and 12 variables:
#' \describe{
#'   \item{name}{Latin name, either accepted name or synonym}
#'   \item{name_origin}{Indicates if the name is the accepted scientific name or a synonym}
#'   \item{acronym}{A unique acronym for each species. Not always consistent between FQA databases}
#'   \item{accepted_scientific_name}{The accepted/official scientific name}
#'   \item{family}{Taxonomic family of species}
#'   \item{nativity}{Nativity status. native, non-native, and undetermined are possible values}
#'   \item{c}{Coefficient of Conservatism (C Value)}
#'   \item{w}{Wetland Indicator Coefficient}
#'   \item{physiognomy}{Structure or physical appearance of plant}
#'   \item{duration}{Lifespan of plant}
#'   \item{common_name}{Common name(s) for plant}
#'   \item{fqa_db}{Regional FQA database}
#'   ...
#' }
#' @source See `fqa_citations`
"fqa_db"
