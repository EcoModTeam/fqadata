#testing for fqadata package

test_that("fqa_db does not have dup acronyms with diff names in same db", {
  skip_if_not_installed("dplyr")
  expect_equal(nrow(acronym_name_counts <- fqa_db %>%
                      dplyr::group_by(acronym, fqa_db) %>%
                      dplyr::summarize(num_names = dplyr::n_distinct(name)) %>%
                      dplyr::filter(!is.na(acronym)) %>%
                      dplyr::filter(fqa_db != "pennsylvania_piedmont_2013") %>%
                      dplyr::filter(num_names > 1)), 0)
})

test_that("fqa_db does not have dup names that are both accepted in same db", {
  skip_if_not_installed("dplyr")
  expect_true(all(!duplicated(fqa_db %>%
                                dplyr::filter(name_origin == "accepted_scientific_name") %>%
                                dplyr::select("name", "fqa_db"))))
})

test_that("all dbs are listed in citations page", {
  expect_equal(unique(fqa_db$fqa_db), fqa_citations$fqa_db)
})

