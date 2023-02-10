## code to prepare `fqa_citations` dataset goes here

#load required packaged
library(here)
library(janitor)
library(dplyr)
library(stringr)

#load data
citations <- read.csv(here("data-raw", "Regional_db_notes.csv")) %>%
  clean_names()

#cleaning
fqa_citations <- citations %>%
  select(fqa_name_in_app, recommendation, notes, citation) %>%
  rename(fqa_db = fqa_name_in_app) %>%
  mutate(citation = str_replace_all(citation, "Smith, P., G. Doyle, and J. Lemly. 2020. Revision of Colorado’s Floristic Quality Assessment Indices. Colorado Natural Heritage Program, Colorado State University, Fort Collins, Colorado.",
              "Smith, P., G. Doyle, and J. Lemly. 2020. Revision of Colorado's Floristic Quality Assessment Indices. Colorado Natural Heritage Program, Colorado State University, Fort Collins, Colorado.")) %>%
  arrange(fqa_db)

#save dataset
usethis::use_data(fqa_citations, overwrite = TRUE, compress = "gzip")

#optimize and check compression
# tools::resaveRdaFiles("data/fqa_db.rda")
# tools::checkRdaFiles("data/fqa_db.rda")
