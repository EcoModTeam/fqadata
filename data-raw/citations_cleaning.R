## code to prepare `fqa_citations` dataset goes here

#load required packaged
library(here)
library(janitor)
library(dplyr)
library(stringr)

#load data
citations <- read.csv(here("data-raw", "Regional_db_notes.csv")) %>%
  clean_names() %>%
  rename(recommended = recommendation)

#cleaning
fqa_citations <- citations %>%
  select(fqa_name_in_app, recommended, notes, citation) %>%
  rename(fqa_db = fqa_name_in_app) %>%
  mutate(citation = str_replace_all(citation, "’","'")) %>%
  arrange(fqa_db)

#save dataset
usethis::use_data(fqa_citations, overwrite = TRUE, compress = "gzip")

#optimize and check compression
# tools::resaveRdaFiles("data/fqa_db.rda")
# tools::checkRdaFiles("data/fqa_db.rda")
