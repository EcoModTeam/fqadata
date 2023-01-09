#' Regional Floristic Quality Assessment Index Databases
#'
#' A data frame containing....
#'
#' @format A data frame with 35 rows and 3 variables:
#' \describe{
#'   \item{name}{Latin name, either proper name or synonym}
#'   \item{name_origin}{Indicates if the name is the accepted scientific name--"accepted_scientific_name"--or a synonym}
#'   \item{acronym}{A unique acronym for each species. Not always consistent between FQA data bases}
#'   \item{accepted_scientific_name}{The accepted/official scientific name}
#'   \item{family}{Taxonomic family of species}
#'   \item{nativity}{Nativity status. native, non-native, and undetermined are values}
#'   \item{c}{Coefficient of Conservatism (C Value)}
#'   \item{w}{Wetland Indicator Rating}
#'   \item{physiognomy}{Structure or physical appearance of plant}
#'   \item{duration}{Lifespan of plant}
#'   \item{common_name}{Common name(s) for plant}
#'   \item{fqa_db}{Regional FQA database}
#'   ...
#' }
"fqai_db"
