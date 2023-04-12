#' Regional Floristic Quality Assessment Databases
#'
#' A data set containing regional Floristic Quality Assessment databases.
#' Each of these databases has been approved or approved with reservations for use
#' by the U.S. Army Corps of Engineers. Paired with the `fqacalc` R package, these
#' data sets allow for Floristic Quality Assessment metrics to be calculated.
#'
#' @format A data frame
#' \describe{
#'   \item{name}{Latin name for species, either accepted name or synonym}
#'   \item{name_origin}{Indicates if the name is the accepted scientific name or a synonym}
#'   \item{acronym}{A unique acronym for each species. Not always consistent between FQA databases}
#'   \item{accepted_scientific_name}{The accepted botanical nomenclature}
#'   \item{family}{Taxonomic family of species}
#'   \item{nativity}{Nativity status. Native, introduced, and undetermined are possible values}
#'   \item{c}{Coefficient of Conservatism (C Value)}
#'   \item{w}{Wetness Coefficient}
#'   \item{wetland_indicator}{Wetland indicator status}
#'   \item{physiognomy}{Structure or physical appearance of species}
#'   \item{duration}{Lifespan of species}
#'   \item{common_name}{Common name(s) for species}
#'   \item{fqa_db}{Regional FQA database}
#' }
#' @source See `fqa_citations`
"fqa_db"
