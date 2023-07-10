## code to prepare `fqa_db` dataset goes here

#load required packaged
library(here)
library(janitor)
library(tidyverse)
library(readxl)
library(splitstackshape)
library(naniar)


#FOR UNIVERSAL FQA DBS---------------------------------------------------------------

#create list of file names
univ_files <- list.files(path = here("data-raw", "FQA_databases"),
                         pattern = "*.csv",
                         full.names = F)

#read them in and create new col with region
univ_list <- lapply(univ_files, function(x)
  read_csv(paste0("./data-raw/FQA_databases/", x), skip = 11) %>%
    mutate(fqa_db = x))

#bind together
univ_fqa <- bind_rows(univ_list) %>%
  #clean names
  clean_names() %>%
  #eliminate rows that are exactly the same
  distinct()

univ_cleanish <- univ_fqa %>%
  #replace subsp., spp. with ssp.
  mutate(scientific_name = str_replace_all(scientific_name, " subsp.", " ssp.")) %>%
  mutate(scientific_name = str_replace_all(scientific_name, " spp.", " ssp.")) %>%
  #fixing up var
  mutate(scientific_name = str_replace_all(scientific_name, " var ", " var. ")) %>%
  mutate(scientific_name = str_replace_all(scientific_name, " v. ", " var. ")) %>%
  #replace corrupt x
  mutate(scientific_name = str_replace_all(scientific_name, "�", "x ")) %>%
  mutate(scientific_name = str_replace_all(scientific_name, "_", " x ")) %>%
  mutate(scientific_name = str_replace_all(scientific_name, "[?]", " X ")) %>%
  #making separators consistent
  mutate(scientific_name = str_replace_all(scientific_name, "\\(=", ";")) %>%
  mutate(scientific_name = case_when(fqa_db == "nebraska_2003.csv"
                                     ~ str_replace(scientific_name, "\\(", ";"),
                                     T ~ scientific_name)) %>%
  mutate(scientific_name = str_replace_all(scientific_name, "[\\[]", ";")) %>%
  mutate(scientific_name = str_remove(scientific_name, "\\(including.+\\)")) %>%
  mutate(scientific_name = case_when(scientific_name == "Juncus bufonius ;j. bufonius, in part)" ~
                                       "Juncus bufonius",
                                     scientific_name == "Physaria reediana  ;p. reediana, in part)" ~
                                       "Physaria reediana",
                                    scientific_name == "Salvinia ssp." ~
                                       "Salvinia sp.",
                                     scientific_name == "Arabis shortii (syn. werier)" ~
                                       "Arabis shortii; Arabis werier",
                                     scientific_name == "Cardaria draba, lepidium draba" ~
                                       "Cardaria draba; lepidium draba",
                                     scientific_name == "Glyceria striata;glyceria striata, glyceria elata;glyceria striata" ~
                                       "Glyceria striata; Glyceria elata",
                                     scientific_name == "Juncus arcticus ssp. littoralis;juncus balticus var. balticus, var. montanus, and var. vallicola." ~
                                       "Juncus arcticus ssp. littoralis;juncus balticus var. balticus; Juncus balticus var. montanus; Juncus balticus var. vallicola.",
                                     scientific_name == "Festuca valesiaca or f. pseudovina;festuca subuliflora" ~
                                       "Festuca valesiaca; f. pseudovina;festuca subuliflora",
                                     scientific_name == "Homalosorus pycnocarpon ;athyrium pycnocarpon or diplazium pycnocarpon)" ~
                                       "Homalosorus pycnocarpon; Athyrium pycnocarpon; Diplazium pycnocarpon",
                                     scientific_name == "Pinus resinosa (elsewhere in state)" ~
                                       "Pinus resinosa -not on north fork or south branch mtn",
                                     scientific_name == "Pinus resinosa (on north fork or south branch mtn)" ~
                                       "Pinus resinosa -on north fork or south branch mtn",
                                     scientific_name == "Centaurea nigrescens (c. x moncktonii);centaurea pratensis;centaurea nigrescens" ~
                                       "Centaurea nigrescens Centaurea x moncktonii; centaurea pratensis; centaurea nigrescens",
                                     scientific_name == "Juncus balticus;placehold for all varieties of j. balticus = j. arcticus)" ~
                                       "Juncus balticus; Juncus arcticus",
                                     T ~ scientific_name))

univ_syn_sep <- univ_cleanish %>%
  #separate plants by first ";" into sci name and syn
  separate(scientific_name, c("scientific_name", "synonym"), ";", extra = "merge") %>%
  #remove leading/trailing white spaces
  mutate(scientific_name = str_squish(scientific_name)) %>%
  mutate(synonym = str_squish(synonym)) %>%
  #replace empty cells with NA
  mutate(synonym = na_if(synonym, "")) %>%
  mutate(synonym = na_if(synonym, ".")) %>%
  #get rid of syn starting with ".;"
  mutate(synonym = str_remove(synonym, "^.;"))

#split synonym into many columns
syn_split <- cSplit(univ_syn_sep, 'synonym', ';')

#list of syn columns
cols <- colnames(syn_split)
syn_cols <- cols[grepl("^synonym", cols)]

#replace fist character of syn cols with upper case
syn_upper <- syn_split %>%
  mutate(across(.cols = syn_cols, .fns = ~ str_replace(., "^\\w{1}", toupper)))

#replace initials with full names from column before
syn_initials <- syn_upper %>%
  mutate(
    synonym_1 = if_else(
      str_extract(synonym_1, "^\\w") == str_extract(scientific_name, "^\\w"),
      str_replace(synonym_1, "^\\w\\.", str_extract(scientific_name, "^\\w+")),
      synonym_1),
    synonym_1 = if_else(
      str_extract(synonym_1, "(?<=\\s)\\w") == str_extract(scientific_name, "(?<=\\s)\\w"),
      str_replace(synonym_1, "\\w\\.$", str_extract(scientific_name, "\\w+$")),
      synonym_1)) %>%
  mutate(
    synonym_2 = if_else(
      str_extract(synonym_2, "^\\w") == str_extract(synonym_1, "^\\w"),
      str_replace(synonym_2, "^\\w\\.", str_extract(synonym_1, "^\\w+")),
      synonym_2),
    synonym_2 = if_else(
      str_extract(synonym_2, "(?<=\\s)\\w") == str_extract(synonym_1, "(?<=\\s)\\w"),
      str_replace(synonym_2, "\\w\\.$", str_extract(synonym_1, "\\w+$")),
      synonym_2)) %>%
  mutate(
    synonym_3 = if_else(
      str_extract(synonym_3, "^\\w") == str_extract(synonym_2, "^\\w"),
      str_replace(synonym_3, "^\\w\\.", str_extract(synonym_2, "^\\w+")),
      synonym_3),
    synonym_3 = if_else(
      str_extract(synonym_3, "(?<=\\s)\\w") == str_extract(synonym_2, "(?<=\\s)\\w"),
      str_replace(synonym_3, "\\w\\.$", str_extract(synonym_2, "\\w+$")),
      synonym_3)) %>%
  mutate(
    synonym_4 = if_else(
      str_extract(synonym_4, "^\\w") == str_extract(synonym_3, "^\\w"),
      str_replace(synonym_4, "^\\w\\.", str_extract(synonym_3, "^\\w+")),
      synonym_4),
    synonym_4 = if_else(
      str_extract(synonym_4, "(?<=\\s)\\w") == str_extract(synonym_3, "(?<=\\s)\\w"),
      str_replace(synonym_4, "\\w\\.$", str_extract(synonym_3, "\\w+$")),
      synonym_4)) %>%
  mutate(
    synonym_5 = if_else(
      str_extract(synonym_5, "^\\w") == str_extract(synonym_4, "^\\w"),
      str_replace(synonym_5, "^\\w\\.", str_extract(synonym_4, "^\\w+")),
      synonym_5),
    synonym_5 = if_else(
      str_extract(synonym_5, "(?<=\\s)\\w") == str_extract(synonym_4, "(?<=\\s)\\w"),
      str_replace(synonym_5, "\\w\\.$", str_extract(synonym_4, "\\w+$")),
      synonym_5))

#pivot longer
syn_pivot <- syn_initials %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  mutate(ID = row_number()) %>%
  pivot_longer(cols = c("scientific_name", syn_cols),
               names_to = "name_origin",
               values_to = "name") %>%
  filter(!is.na(name))

#if the plant is a synonym, us NA for acronym (to avoid repeating acronyms)
syn_na_acronyms <- syn_pivot %>%
  mutate(acronym = case_when(str_detect(name_origin, "synonym_") ~ NA_character_,
                             T ~ acronym)) %>%
  mutate(w = as.character(w))


#create function for cleaning up wisconsin
wisconsin_dup <- function(.data, sci_name, new_acronym) {
  m <- mutate(.data, acronym = case_when(fqa_db %in%
                                           c("wisconsin_wetland_northern_southcentral_2017.csv",
                                             "wisconsin_wetland_southwestern_southeastern_2017.csv") &
                                           name == sci_name ~ new_acronym,
                                         T ~ acronym))
  return(m)
}

#getting rid of duplicate acronyms
clean_acronyms <- syn_na_acronyms %>%
  wisconsin_dup("Acer saccharum", "ACESACCU") %>%
  wisconsin_dup("Cakile edentula ssp. edentula var. lacustris", "CAKEDELA") %>%
  wisconsin_dup("Callitriche palustris var. verna", "CALLIPAV") %>%
  wisconsin_dup("Carex arctata", "CARARCTT") %>%
  wisconsin_dup("Carex cephalophora", "CARCEPHP") %>%
  wisconsin_dup("Carex lupulina", "CARLUPUN") %>%
  wisconsin_dup("Euonymus atropurpureus var. atropurpureus", "EUOATRVU") %>%
  wisconsin_dup("Gymnocladus dioicus", "GYMDIOIS") %>%
  wisconsin_dup("Hieracium piloselloides", "HIEPILOO") %>%
  wisconsin_dup("Humulus lupulus var. lupulus", "HUMLUPVU") %>%
  wisconsin_dup("Lotus unifoliolatus var. unifoliolatus", "LOTUNUVU") %>%
  wisconsin_dup("Lysimachia quadrifolia", "LYSQUADO") %>%
  wisconsin_dup("Odontites vernus ssp. serotinus", "ODOVERSU") %>%
  wisconsin_dup("Phlox bifida ssp. bifida x p. subulata", "PHLBIFSX") %>%
  wisconsin_dup("Phragmites australis ssp. australis", "PHRAUSSU") %>%
  wisconsin_dup("Ptelea trifoliata ssp. trifoliata var. trifoliata", "PTETRISV") %>%
  wisconsin_dup("Sambucus racemosa ssp. pubens var. pubens", "SAMRACSV") %>%
  wisconsin_dup("Solidago rugosa ssp. rugosa var. rugosa", "SOLRUGRR") %>%
  wisconsin_dup("Solidago rugosa ssp. rugosa var. villosa", "SOLRUGRV") %>%
  wisconsin_dup("Solidago simplex ssp. randii var. gillmanii", "SOLSIMSG") %>%
  wisconsin_dup("Solidago simplex ssp. simplex var. simplex", "SOLSIMSV") %>%
  wisconsin_dup("Stachys palustris ssp. pilosa", "STAPALSI") %>%
  wisconsin_dup("Viola pedatifida", "VIOPEDAI") %>%
  #cleaning up dup acronyms in other fqa lists
  mutate(acronym = case_when(fqa_db == "illinois_2020.csv" &
                               name == "Polygala verticillata var. ambigua" ~ "POLVERA",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "illinois_2020.csv" &
                               name == "Polygala verticillata var. isocycla" ~ "POLVERI",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "illinois_2020.csv" &
                               name == "Salix glaucophylloides var. glaucophylla" ~ "SALGLAG",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "iowa_2001.csv" &
                               name == "Juncus x nodosiformis" ~ "JUNXNO",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "iowa_2001.csv" &
                               name == "Malus sylvestris" ~ "MALSYV",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "louisiana_coastal_prairie_2006.csv" &
                               name == "Scleria pauciflora" ~ "SCPA",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "louisiana_coastal_prairie_2006.csv" &
                               name == "Kyllinga odorata" ~ "KYOD",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "nebraska_2003.csv" &
                               name == "Phragmites australis ssp. australis" ~ "[PHAU7U]",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "nebraska_2003.csv" &
                               name == "Rumex patientia ssp. patientia" ~ "[RUPA5P]",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "west_virginia_2015.csv" &
                               name == "Lactuca floridana" ~ "LAFL",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "west_virginia_2015.csv" &
                               name == "Osmunda cinnamomea" ~ "OSCI",
                             T ~ acronym)) %>%
  mutate(acronym = case_when(fqa_db == "west_virginia_2015.csv" &
                               acronym == "PIRE" &
                               native == "native" ~ "PIREN",
                             T ~ acronym)) %>%
  rename(scientific_name = name)

#delete rows that are duplicate
univ_fqa_distinct <- clean_acronyms %>%
  distinct(family, native, c,
           w, physiognomy, duration,
           fqa_db, accepted_scientific_name,
           scientific_name, .keep_all = TRUE)




#SOUTH EASTERN DBS---------------------------------------------------------------

#read in data
southeastern <- read_xlsx(here("data-raw", "FQA_databases", "not_from_universal_calc",
                               "southeastern_wetland_database_2014.xlsx")) %>%
  clean_names()

#clean whole thing
southeastern_clean <- southeastern %>%
  mutate(acronym = case_when(main_vs_syn == "Syn" ~ usda_synonym_symbol,
                             T ~ usda_accepted_symbol)) %>%
  mutate(name_origin = case_when(main_vs_syn == "Syn" ~ "synonym",
                                 main_vs_syn == "MAIN" ~ "main")) %>%
  rename(scientific_name = usda_scientific_name) %>%
  mutate(family = NA) %>%
  rename(native = native_status) %>%
  rename(physiognomy = growth_habit) %>%
  rename(common_name = usda_common_name) %>%
  group_by(usda_accepted_symbol) %>%
  mutate(ID = cur_group_id()) %>%
  mutate(accepted_scientific_name = first(scientific_name)) %>%
  ungroup()

southeastern_cols <- southeastern_clean %>%
  select(ID, accepted_scientific_name, name_origin, scientific_name, family, acronym, native,
         ave_c_value_southern_coastal_plain,
         ave_c_value_plains,
         ave_c_value_piedmont,
         ave_c_value_mountains,
         ave_c_value_interior_plateau,
         nwpl_e_mtns,
         nwpl_cstl_plain,
         common_name,
         duration,
         physiognomy,
         native) %>%
  mutate(native = case_when(name_origin == "main" & is.na(native) ~ "NA",
                            T ~ native)) %>%
  fill(native) %>%
  mutate(ave_c_value_southern_coastal_plain = case_when(name_origin == "main" & is.na(ave_c_value_southern_coastal_plain) ~ "NA",
                                                        T ~ ave_c_value_southern_coastal_plain)) %>%
  fill(ave_c_value_southern_coastal_plain) %>%
  mutate(ave_c_value_plains = case_when(name_origin == "main" & is.na(ave_c_value_plains) ~ "NA",
                                        T ~ ave_c_value_plains)) %>%
  fill(ave_c_value_plains) %>%
  mutate(ave_c_value_piedmont = case_when(name_origin == "main" & is.na(ave_c_value_piedmont) ~ "NA",
                                          T ~ ave_c_value_piedmont)) %>%
  fill(ave_c_value_piedmont) %>%
  mutate(ave_c_value_mountains = case_when(name_origin == "main" & is.na(ave_c_value_mountains) ~ "NA",
                                           T ~ ave_c_value_mountains)) %>%
  fill(ave_c_value_mountains) %>%
  mutate(ave_c_value_interior_plateau = case_when(name_origin == "main" & is.na(ave_c_value_interior_plateau ) ~ "NA",
                                                  T ~ ave_c_value_interior_plateau )) %>%
  fill(ave_c_value_interior_plateau) %>%
  mutate(nwpl_e_mtns = case_when(name_origin == "main" & is.na(nwpl_e_mtns) ~ "NA",
                                 T ~ nwpl_e_mtns)) %>%
  fill(nwpl_e_mtns) %>%
  mutate(nwpl_cstl_plain = case_when(name_origin == "main" & is.na(nwpl_cstl_plain) ~ "NA",
                                     T ~ nwpl_cstl_plain)) %>%
  fill(nwpl_cstl_plain) %>%
  mutate(common_name = case_when(name_origin == "main" & is.na(common_name) ~ "NA",
                                 T ~ common_name)) %>%
  fill(common_name) %>%
  mutate(duration = case_when(name_origin == "main" & is.na(duration ) ~ "NA",
                              T ~ duration )) %>%
  fill(duration ) %>%
  mutate(physiognomy = case_when(name_origin == "main" & is.na(physiognomy) ~ "NA",
                                 T ~ physiognomy)) %>%
  fill(physiognomy)

#southern_coastal
southern_coastal_plain <- southeastern_cols %>%
  select(ID, accepted_scientific_name, scientific_name, name_origin, family, acronym,
         ave_c_value_southern_coastal_plain, physiognomy,
         duration, common_name, nwpl_cstl_plain, native) %>%
  mutate(fqa_db = "southern_coastal_plain_2013") %>%
  rename(c = ave_c_value_southern_coastal_plain) %>%
  rename(w = nwpl_cstl_plain) %>%
  filter(!c == "NA") %>%
  replace_with_na(replace = list(c = "UND"))

#southeastern plains
southeastern_plain <- southeastern_cols %>%
  select(ID, accepted_scientific_name, scientific_name, name_origin, family, acronym,
         ave_c_value_plains, physiognomy,
         duration, common_name, nwpl_cstl_plain, native) %>%
  mutate(fqa_db = "coastal_plain_southeast_2013") %>%
  rename(c = ave_c_value_plains) %>%
  rename(w = nwpl_cstl_plain) %>%
  filter(!c == "NA") %>%
  filter(!is.na(name_origin)) %>%
  replace_with_na(replace = list(c = "UND"))

#southern piedmont
southeastern_piedmont <- southeastern_cols %>%
  select(ID, accepted_scientific_name, scientific_name, name_origin, family, acronym,
         ave_c_value_piedmont, physiognomy,
         duration, common_name, nwpl_e_mtns, native) %>%
  mutate(fqa_db = "southeastern_piedmont_2013") %>%
  rename(c = ave_c_value_piedmont) %>%
  rename(w = nwpl_e_mtns) %>%
  filter(!c == "NA") %>%
  replace_with_na(replace = list(c = "UND"))

#southern mountians
southeastern_mountains <- southeastern_cols %>%
  select(ID, accepted_scientific_name, scientific_name, name_origin, family, acronym,
         ave_c_value_mountains, physiognomy,
         duration, common_name, nwpl_e_mtns, native) %>%
  mutate(fqa_db = "appalachian_mountains_2013") %>%
  rename(c = ave_c_value_mountains) %>%
  rename(w = nwpl_e_mtns) %>%
  filter(!c == "NA") %>%
  replace_with_na(replace = list(c = "UND"))

#southern plat
southeastern_plateau <- southeastern_cols %>%
  select(ID, accepted_scientific_name, scientific_name, name_origin, family, acronym,
         ave_c_value_interior_plateau, physiognomy,
         duration, common_name, nwpl_e_mtns, native) %>%
  mutate(fqa_db = "interior_plateau_2013") %>%
  rename(c = ave_c_value_interior_plateau) %>%
  rename(w = nwpl_e_mtns) %>%
  filter(!c == "NA") %>%
  replace_with_na(replace = list(c = "UND"))

southeastern_complete <- rbind(southeastern_mountains,
                               southeastern_piedmont,
                               southeastern_plain,
                               southeastern_plateau,
                               southern_coastal_plain) %>%
  mutate(native = case_when(str_detect(native, "L48 \\(N\\)") ~ "native",
                            str_detect(native, "L48 \\(NI\\)") & c > 0 ~ "native",
                            str_detect(native, "L48 \\(NI\\)") & c == 0 ~ "non-native",
                            str_detect(native, "L48 \\(I\\)") ~ "non-native",
                            T ~ native)) %>%
  mutate(native = case_when(scientific_name == "Cyperus esculentus" ~ "native",
                            T ~ native)) %>%
  mutate(c = str_remove(c, "\\*"))

#CHICAGO------------------------------------------------------------------------

chicago <- read_excel(here("data-raw",
                         "FQA_databases",
                         "not_from_universal_calc",
                         "chicago_region_2017.xlsx")) %>%
  clean_names()

chicago_clean <- chicago %>%
  #get correct column names
  mutate(scientific_name = scientific_name_nwpl_mohlenbrock_wilhelm_rericha) %>%
  mutate(synonym = scientific_name_synonym_swink_wilhelm_wilhelm_rericha) %>%
  mutate(family = scientific_family_name) %>%
  mutate(native = nativity) %>%
  mutate(c = coefficient_of_conservatism) %>%
  mutate(w = midwest_region_wetland_indicator) %>%
  mutate(physiognomy = habit) %>%
  mutate(common_name = common_name_nwpl_mohlenbrock_wilhelm_rericha) %>%
  mutate(fqa_db = "chicago_region_2017") %>%
  select(scientific_name, synonym, family, acronym, native,
         c, w, physiognomy, duration, common_name, fqa_db) %>%
  # #fix w
  mutate(w = case_when(scientific_name == "Fragaria virginiana" & acronym == "FRAVIRG" ~ "FACU",
                       T ~ w)) %>%
  # #fix name
  mutate(scientific_name = case_when(scientific_name == "Erysimum capitatum" & acronym == "ERYARK" ~ "Erysimum capitatum non-native",
                       T ~ scientific_name)) %>%
  mutate(common_name = case_when(scientific_name == "Hypericum fraseri" ~ "Fraser's St. John's-Wort",
                                 T ~ common_name)) %>%
  mutate(synonym = case_when(scientific_name == "Persicaria lapathifolia" ~ "Polygonum lapathifolium; POLYGONUM SCABRUM; PERSICARIA SCABRA",
                             scientific_name == "Cyperus schweinitzii" ~ "Cyperus schweinitzii; Cyperus X mesochorus",
                             T ~ synonym)) %>%
  #get ID per each official name
  group_by(scientific_name) %>%
  mutate(ID = cur_group_id()) %>%
  ungroup() %>%
  #split synonyms out
  cSplit(., 'synonym', ';') %>%
  mutate(synonym_1 = case_when(tolower(synonym_1) == tolower(scientific_name) ~ NA_character_,
                               T ~ synonym_1))


#get complete list of acronyms and IDs
chic_acronyms <- data.frame(acronym = c(chicago_clean$acronym),
                             ID = c(chicago_clean$ID)) %>%
  #create unique ID with count to be shared by chic piv
  group_by(ID) %>%
  mutate(count = row_number()) %>%
  ungroup() %>%
  mutate(new_id = paste0(ID, "-", count)) %>%
  select(acronym, new_id)

#pivot names and synonyms into long form
chic_piv <- chicago_clean %>%
  select(-acronym) %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  pivot_longer(cols = c("scientific_name", starts_with("synonym_")),
               names_to = "name_origin",
               values_to = "scientific_name") %>%
  filter(!is.na(scientific_name)) %>%
  distinct() %>%
  #new ID
  group_by(ID) %>%
  mutate(count = row_number()) %>%
  ungroup() %>%
  mutate(new_id = paste0(ID, "-", count))

#join acronyms to df
chic_piv_acronym <- left_join(chic_piv, chic_acronyms, by = "new_id") %>%
  select(-new_id, - count) %>%
  #fixing acronyms
  mutate(acronym = case_when(accepted_scientific_name == "Viola sororia" & scientific_name == "Viola sororia"  ~ "VIOSOR",
                             accepted_scientific_name == "Viola sororia" & scientific_name == "Viola priceana" ~ "VIOPRC",
                             accepted_scientific_name == "Verbena X perriana" & scientific_name == "Verbena X perriana" ~ "VERPEI",
                             accepted_scientific_name == "Schoenoplectus maritimus" & scientific_name == "Schoenoplectus maritimus" ~ "SCHMAR",
                             accepted_scientific_name == "Schoenoplectus maritimus" & scientific_name == "SCIRPUS PALUDOSUS" ~ "SCIPAU",
                             accepted_scientific_name == "Schoenoplectus maritimus" & scientific_name == "Bolboschoenus maritimus" ~ "BOLMAR",
                             accepted_scientific_name == "Proserpinaca palustris var. crebra" & scientific_name == "Proserpinaca palustris var. crebra" ~ "PROPACR",
                             accepted_scientific_name == "Mentha arvensis" & scientific_name == "Mentha arvensis subsp. parietariaefolia" ~ "MENARPA",
                             accepted_scientific_name == "Mentha arvensis" & scientific_name == "Mentha canadensis" ~ "MENCAA",
                             accepted_scientific_name == "Poinsettia dentata" & scientific_name == "Poinsettia dentata" ~ "POIDEN",
                             scientific_name == "EUPHORBIA DENTATA" ~ "EUPDEN",
                             accepted_scientific_name == "Corispermum welshii" & scientific_name == "Corispermum welshii" ~ "CORWEL",
                             accepted_scientific_name == "Corispermum welshii" & scientific_name == "Corispermum hyssopifolium" ~ "CORHYS",
                             accepted_scientific_name == "Corispermum welshii" & scientific_name == "Corispermum nitidum" ~ "CORNIT",
                             accepted_scientific_name == "Corispermum welshii" & scientific_name == "Corispermum pallasii" ~ "CORPAA",
                             T ~ acronym))

chic_dup <- chic_piv_acronym %>%
  group_by(scientific_name, accepted_scientific_name) %>%
  count()

#COLORADO-----------------------------------------------------------------------

colorado <- read_xlsx(here("data-raw",
                           "FQA_databases",
                           "not_from_universal_calc",
                           "colorado_2020.xlsx")) %>%
  clean_names()

colorado_clean <- colorado %>%
  mutate(scientific_name = fqa_sci_name_no_authority) %>%
  mutate(synonym = national_sci_name_no_authority) %>%
  mutate(ID = row_number()) %>%
  mutate(family = fqa_family) %>%
  mutate(acronym = fqa_usda_symbol) %>%
  mutate(native = fqa_native_status) %>%
  mutate(c = fqa_c_value2020_numeric) %>%
  mutate(w = wmvc_wet_indicator) %>%
  mutate(physiognomy = usda_growth_habit_simple) %>%
  mutate(duration = usda_duration) %>%
  mutate(common_name = NA) %>%
  mutate(fqa_db = "colorado_2020") %>%
  select(scientific_name, synonym, ID, family, acronym, native,
         c, w, physiognomy, duration, common_name, fqa_db) %>%
  #if sci name and syn name match, delete syn
  mutate(synonym = case_when(scientific_name == synonym ~ NA_character_, T ~ synonym)) %>%
  #remove genus with no C score
  mutate(remove_me = case_when(is.na(c) & str_detect(scientific_name, " ", negate = TRUE) ~ "remove")) %>%
  filter(is.na(remove_me)) %>%
  select(-remove_me) %>%
  mutate(synonym = case_when(synonym == "Rosa ×harisonii [foetida × spinosissima]" ~
                               "foetida × spinosissima",
                             T ~ synonym))

colorado_pivot <- colorado_clean %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  pivot_longer(cols = c("scientific_name", "synonym"),
               names_to = "name_origin",
               values_to = "scientific_name") %>%
  filter(!is.na(scientific_name)) %>%
  mutate(acronym = case_when(name_origin == "synonym" ~ NA_character_,
                             T ~ acronym))

#FLORIDA------------------------------------------------------------------------


florida <- read_csv(here("data-raw",
                         "FQA_databases",
                         "not_from_universal_calc",
                         "florida_2011.csv")) %>%
  clean_names() %>%
  filter(if_any(everything(), ~ !is.na(.)))

florida_clean <- florida %>%
  mutate(scientific_name = taxa_name) %>%
  mutate(synonym = NA) %>%
  mutate(family = NA) %>%
  mutate(acronym = NA) %>%
  mutate(native = nativity) %>%
  mutate(c = as.numeric(c_of_c_value)) %>%
  mutate(w = NA) %>%
  mutate(physiognomy = NA) %>%
  mutate(common_name = NA) %>%
  mutate(fqa_db = "florida_2011") %>%
  select(scientific_name, family, acronym, native,
         c, w, physiognomy, duration, common_name, fqa_db) %>%
  mutate(scientific_name = case_when(scientific_name == "Euthamia caroliniana (syn. Euthamia minor, E. tenuifolia tenuifolia)" ~
                                       "Euthamia caroliniana (syn. Euthamia minor, Euthamia tenuifolia tenuifolia)",
                                     scientific_name == "Ruellia simplex (syn. Ruellia brittoniana, R. tweediana)" ~
                                       "Ruellia simplex (syn. Ruellia brittoniana, Ruellia tweediana)",
                                     T ~ scientific_name))



florida_pivot <- florida_clean %>%
  mutate(scientific_name = str_replace(scientific_name, "syn.", ",")) %>%
  separate(scientific_name, into = c("scientific_name", "synonym_1", "synonym_2"), sep = ",") %>%
  mutate(ID = row_number()) %>%
  mutate(scientific_name = case_when(scientific_name == "Eleocharis (submersed viviparous but unable to ID to species)" ~ "Eleocharis sp.",
                                     T ~ scientific_name)) %>%
  mutate(scientific_name = str_remove_all(scientific_name, "[()]")) %>%
  mutate(synonym_1 = str_remove_all(synonym_1, "[()]")) %>%
  mutate(synonym_2 = str_remove_all(synonym_2, "[()]")) %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  pivot_longer(cols = c("scientific_name", "synonym_1", "synonym_2"),
               names_to = "name_origin",
               values_to = "scientific_name") %>%
  filter(!is.na(scientific_name))

#FLORIDA_SOUTH-------------------------------------------------------------------

florida_south <- read_csv(here("data-raw",
                               "FQA_databases",
                               "not_from_universal_calc",
                               "florida_south_2009.csv")) %>%
  clean_names()

florida_south_clean <- florida_south %>%
  mutate(name_origin = "scientific_name") %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  mutate(ID = row_number()) %>%
  mutate(acronym = NA) %>%
  mutate(c = as.numeric(c)) %>%
  mutate(w = NA) %>%
  mutate(physiognomy = NA) %>%
  mutate(duration = NA) %>%
  mutate(fqa_db = "florida_south_2009") %>%
  select(scientific_name, accepted_scientific_name, name_origin, ID, family, acronym, native,
         c, w, physiognomy, duration, common_name, fqa_db) %>%
  mutate(scientific_name = str_replace_all(scientific_name, "subsp.", "ssp.")) %>%
  #cleaning up inconsistent C scores
  filter(!(scientific_name == "Amorpha herbacea var. crenulata" & c == "8")) %>%
  filter(!(scientific_name == "Halophila decipiens" & c == "8")) %>%
  filter(!(scientific_name == "Ruppia maritima" & c == "10")) %>%
  filter(!(scientific_name == "Thalassia testudinum" & c == "9")) %>%
  filter(!(scientific_name == "Halophila engelmannii" & c == "8")) %>%
  filter(!(scientific_name == "Alternanthera flavescens" & native == "Exotic")) %>%
  filter(!(scientific_name == "Heteropogon contortus" & native == "native")) %>%
  filter(!(scientific_name == "Heteropogon melanocarpus" & native == "native")) %>%
  filter(!(scientific_name == "Stylosanthes hamata" & native == "Exotic"))


#MISSISSISSIPPI------------------------------------------------------------------

ms <- read_xlsx(here("data-raw",
                     "FQA_databases",
                     "not_from_universal_calc",
                     "mississippi_north_central_wetlands_2005.xlsx")) %>%
  clean_names()

ms_clean <- ms %>%
  mutate(scientific_name = species) %>%
  mutate(name_origin = "scientific_name") %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  mutate(ID = row_number()) %>%
  mutate(acronym = NA) %>%
  mutate(native = origin) %>%
  mutate(c = ave_cc) %>%
  mutate(w = wetland_indicator_status) %>%
  mutate(physiognomy = physiogynomy) %>%
  mutate(duration = x9) %>%
  mutate(duration = case_when(duration == "A" ~ "annual",
                              duration == "P" ~ "perennial",
                              T ~ duration)) %>%
  mutate(common_name = common) %>%
  mutate(fqa_db = "mississippi_north_central_wetlands_2005") %>%
  select(scientific_name, accepted_scientific_name, name_origin, ID, family, acronym, native,
         c, w, physiognomy, duration, common_name, fqa_db)


#MONTANA------------------------------------------------------------------------

montana <- read_xlsx(here("data-raw",
                          "FQA_databases",
                          "not_from_universal_calc",
                          "montana_2017.csv")) %>%
  clean_names()

montana_clean <- montana %>%
  mutate(scientific_name = scientific_name_mtnhp) %>%
  mutate(synonym = synonym_s) %>%
  mutate(family = family_name) %>%
  mutate(acronym = NA) %>%
  mutate(native = origin_in_montana) %>%
  mutate(c = as.numeric(montana_c_value)) %>%
  mutate(w = NA) %>%
  mutate(physiognomy = NA) %>%
  mutate(duration = NA) %>%
  mutate(fqa_db = "montana_2017") %>%
  select(scientific_name, synonym, family, acronym, native,
         c, w, physiognomy, duration, common_name, fqa_db) %>%
  mutate(synonym = case_when(scientific_name == "Eriogonum brevicaule var. canum"
                             ~ "Eriogonum lagopus; Eriogonum pauciflorum var. canum",
                             scientific_name == "Transberingia bursifolia ssp. virgata" ~
                               "Halimolobos virgata; Transberingia virgata",
                             T ~ synonym)) %>%
  distinct()

montana_pivot <- montana_clean %>%
  mutate(ID = row_number()) %>%
  mutate(synonym = str_remove_all(synonym, "\\[.*\\]")) %>%
  cSplit(., 'synonym', ';') %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  pivot_longer(cols = c("scientific_name", starts_with("synonym_")),
               names_to = "name_origin",
               values_to = "scientific_name") %>%
  filter(!is.na(scientific_name))


#OHIO--------------------------------------------------------------------------

ohio <- read_xlsx(here("data-raw",
                       "FQA_databases",
                       "not_from_universal_calc",
                       "ohio_2014.xlsx")) %>%
  clean_names() %>%
  #removing random mostly empty rows
  filter(usda_id != "CAREX")

ohio_clean <- ohio %>%
  mutate(name_origin = "scientific_name") %>%
  mutate(ID = row_number()) %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  mutate(native = oh_status) %>%
  mutate(c = cofc) %>%
  mutate(w = wet) %>%
  mutate(physiognomy = form) %>%
  mutate(duration = habit) %>%
  mutate(fqa_db = "ohio_2014") %>%
  select(scientific_name, accepted_scientific_name, name_origin, ID, family, acronym, native, c, w,
         physiognomy, duration, common_name, fqa_db) %>%
  distinct() %>%
  mutate(remove_me = case_when(is.na(c) & str_detect(scientific_name, " sp.") ~ "remove")) %>%
  filter(is.na(remove_me)) %>%
  select(-remove_me) %>%
  mutate(acronym = case_when(scientific_name == "Symphyotrichum laeve" ~ "SYNLAE",
                             scientific_name == "Solidago speciosa Nutt. var. rigidiuscula" ~ "SOLSPR",
                             scientific_name == "Cuscuta epithymum" ~ "CUSEPT",
                             scientific_name == "Collinsonia verticillata" ~ "COLVET",
                             scientific_name == "Chenopodium glaucum" ~ "CHEGLU", T ~ acronym)) %>%
  mutate(scientific_name = case_when(scientific_name == "Najas marina" &
                                       native == "native" ~ "Najas marina -native",
                                     T ~ scientific_name)) %>%
  mutate(acronym = case_when(scientific_name == "Najas marina -native" ~ "NAJMARI",
                             T ~ acronym)) %>%
  mutate(scientific_name = case_when(scientific_name == "Phlox subulata" &
                                       native == "native" ~ "Phlox subulata -native",
                                     T ~ scientific_name)) %>%
  mutate(acronym = case_when(scientific_name == "Phlox subulata -native" ~ "PHLSUBT",
                             T ~ acronym)) %>%
  mutate(scientific_name = case_when(scientific_name == "Pinus strobus" &
                                       native == "native" ~ "Pinus strobus -native",
                                     T ~ scientific_name)) %>%
  mutate(acronym = case_when(scientific_name == "Pinus strobus -native" ~ "PINSTRO",
                             T ~ acronym))

#WYOMING------------------------------------------------------------------------

wyoming <- read_xlsx(here("data-raw",
                          "FQA_databases",
                          "not_from_universal_calc",
                          "wyoming_2017.xlsx"), skip = 1) %>%
  clean_names()

wyoming_cols <- wyoming %>%
  mutate(family = family_scientific_name) %>%
  mutate(synonym = synonyms) %>%
  mutate(acronym = NA) %>%
  mutate(native = statewide_origin) %>%
  mutate(c = wyoming_coefficient_of_conservatism) %>%
  mutate(w = wetland_indicator_status_arid_west) %>%
  mutate(physiognomy = NA) %>%
  mutate(duration = NA) %>%
  mutate(fqa_db = "wyoming_2017") %>%
  select(scientific_name, synonym, family, acronym, native, c, w, physiognomy, duration, common_name, fqa_db) %>%
  slice(., 1:(n() - 1))

wyoming_pivot <- wyoming_cols %>%
  cSplit(., 'synonym', ',') %>%
  mutate(ID = row_number()) %>%
  mutate(accepted_scientific_name = scientific_name) %>%
  pivot_longer(cols = c("scientific_name", starts_with("synonym_")),
               names_to = "name_origin",
               values_to = "scientific_name") %>%
  filter(!is.na(scientific_name))

#NOW CLEANING ALL TOGETHER-----------------------------------------------------

#bind all together
fqa_db_bind <- rbind(univ_fqa_distinct,
                     southeastern_complete,
                     colorado_pivot,
                     chic_piv_acronym,
                     florida_pivot,
                     florida_south_clean,
                     ms_clean,
                     montana_pivot,
                     ohio_clean,
                     wyoming_pivot) %>%
  #remove csv from end of fqa_db column
  mutate(fqa_db = str_remove_all(fqa_db, ".csv")) %>%
  #covert things to uppercase
  mutate(scientific_name = toupper(scientific_name)) %>%
  #fixing white spaces in scientific name
  mutate(scientific_name = str_squish(scientific_name)) %>%
  mutate(scientific_name = str_trim(scientific_name, side = "both")) %>%
  #find observations that are at the genus level (only one name)
  mutate(scientific_name = case_when(!str_detect(scientific_name, pattern = " ") ~
                                       paste(scientific_name, "SP."),
                                     T ~ scientific_name)) %>%
  #delete observations that are not genus not species
  filter(str_detect(scientific_name, " SP\\.", negate = TRUE)) %>%
  rename(name = scientific_name) %>%
  #clean commmon name
  mutate(common_name = str_to_title(common_name)) %>%
  #clean C Value
  mutate(c = as.numeric(c)) %>%
  #get rid of case where sci name and syn were same, so duplicate rows
  distinct(family, native, c,
           w, physiognomy, duration,
           fqa_db, accepted_scientific_name,
           name, .keep_all = TRUE)

#cleaning up native column
fqa_native <- fqa_db_bind %>%
  mutate(native = case_when(native %in% c("native",
                                          "Native",
                                          "N",
                                          "Native/Naturalized",
                                          "Native/Adventive",
                                          "Likely Native",
                                          "Native/Exotic") ~ "native",
                            native %in% c("non-native",
                                          "Nonnative",
                                          "cryptogenic",
                                          "adventive",
                                          "Likely Exotic",
                                          "I",
                                          "Exotic",
                                          "Adventive",
                                          "Cryptogenic",
                                          "Non-native") ~ "introduced",
                            T ~ "undetermined")) %>%
  rename(nativity = native)

#cleaning up wet coef column
fqa_wet <- fqa_native %>%
  mutate(w = str_remove_all(w, "[()]")) %>%
  mutate(wetland_indicator = case_when(w %in% c("UPL", "FACU", "FACU-", "FACU+",
                                                 "FAC", "FAC-", "FAC+", "FACW",
                                                 "FACW-", "FACW+", "OBL") ~ w,
                                       T ~ NA_character_)) %>%
  mutate(w = case_when(w %in% c("NA", "ND", "NI") ~ NA_character_,
                       w %in% c("UPL") ~ "2",
                       w %in% c("FACU", "FACU-", "FACU+") ~ "1",
                       w %in% c("FAC", "FAC-", "FAC+") ~ "0",
                       w %in% c("FACW", "FACW-", "FACW+") ~ "-1",
                       w %in% c("OBL") ~ "-2",
                       T ~ w)) %>%
  mutate(w = as.numeric(w))


#cleaning physiog column
fqa_physiog <- fqa_wet %>%
  mutate(physiognomy = tolower(physiognomy)) %>%
  mutate(physiognomy = str_remove(physiognomy, ",.*")) %>%
  mutate(physiognomy = str_remove(physiognomy, "\\/.*")) %>%
  mutate(physiognomy = str_replace(physiognomy, "shurb", "shrub")) %>%
  mutate(physiognomy = str_replace(physiognomy, "sm tree", "tree")) %>%
  mutate(physiognomy = str_replace(physiognomy, "subshrub", "shrub")) %>%
  mutate(physiognomy = str_replace(physiognomy, "frob", "forb")) %>%
  mutate(physiognomy = str_replace(physiognomy, "graminoid", "grass")) %>%
  mutate(physiognomy = str_replace(physiognomy, "gram", "grass")) %>%
  mutate(physiognomy = str_replace(physiognomy, "h-vine", "vine")) %>%
  mutate(physiognomy = str_replace(physiognomy, "w-vine", "vine")) %>%
  mutate(physiognomy = str_replace(physiognomy, "^bryo$", "bryophyte"))

#cleaning up duration column
fqa_duration <- fqa_physiog %>%
  mutate(duration = tolower(duration)) %>%
  mutate(duration = str_replace(duration, "n\\/a \\(non-vascular\\)", "none")) %>%
  mutate(duration = str_remove(duration, ",.*")) %>%
  mutate(duration = str_remove(duration, "\\/.*")) %>%
  mutate(duration = str_replace(duration, "^an$", "annual")) %>%
  mutate(duration = str_replace(duration, "^w$", "perennial")) %>%
  mutate(duration = str_replace(duration, "^pe$", "perennial")) %>%
  mutate(duration = str_replace(duration, "^bi$", "biennial")) %>%
  mutate(duration = str_replace(duration, "^br$", "none")) %>%
  mutate(duration = str_replace(duration, "^nd$", NA_character_))

#cleaning up name_origin column
fqa_origin <- fqa_duration %>%
  mutate(name_origin = case_when(str_detect(name_origin, "synonym") ~ "synonym",
                                 name_origin %in% c("scientific_name", "main") ~ "accepted_scientific_name",
                                 T ~ name_origin))

#clean up name
fqa_name <- fqa_origin %>%
  #fixing x
  mutate(name = case_when(name == "MENTHA X X VERTICILLATA" ~
                            "MENTHA X VERTICILLATA",
                          name == "QUERCUS XSUBFALCATA" ~
                            "QUERCUS X SUBFALCATA",
                          name == "QUERCUS XSAULII" ~
                            "QUERCUS X SAULII",
                          name == "QUERCUS XRUDKINII" ~
                            "QUERCUS X RUDKINII",
                          name == "QUERCUS XHETEROPHYLLA" ~
                            "QUERCUS X HETEROPHYLLA",
                          name == "QUERCUS XGIFFORDII" ~
                            "QUERCUS X GIFFORDII",
                          name == "QUERCUS XFILIALIS" ~
                            "QUERCUS X FILIALIS",
                          name == "QUERCUS XFERNOWII" ~
                            "QUERCUS X FERNOWII",
                          name == "QUERCUS XBEADLEI" ~
                            "QUERCUS X BEADLEI",
                          name == "POPULUS XJACKII" ~
                            "POPULUS X JACKII",
                          name == "PLATANTHERA XCANBYI" ~
                            "PLATANTHERA X CANBYI",
                          name == "PETUNIA XHYBRIDA" ~
                            "PETUNIA X HYBRIDA",
                          name == "LYCOPODIELLA XCOPELANDII" ~
                            "LYCOPODIELLA X COPELANDII",
                          name == "ILEX XATTENUATA" ~
                            "ILEX X ATTENUATA",
                          name == "DRYOPTERIS XBOOTTII" ~
                            "DRYOPTERIS X BOOTTII",
                          name == "DICHANTHELIUM XSCOPARIOIDES" ~
                            "DICHANTHELIUM X SCOPARIOIDES",
                          name == "KALANCHOE XHOUGHTONII" ~
                            "KALANCHOE X HOUGHTONII",
                          name == "DRYOPTERIS XTRIPLOIDEA" ~
                            "DRYOPTERIS X TRIPLOIDEA",
                          name == "MENTHA XPIPERITA" ~
                            "MENTHA X PIPERITA",
                          name == "ELEOCHARIS ACICULARIS / WILL SUGGESTS REMOVING, MAY BE MORE MONTANE" ~
                            "ELEOCHARIS ACICULARIS",
                          name == "PHYTOLACCA AMERICANA VAR, AMERICANA" ~
                            "PHYTOLACCA AMERICANA VAR. AMERICANA",
                          name == "TYPHA XGLAUCA" ~
                            "TYPHA X GLAUCA",
                          T ~ name)) %>%
  #fixing odds and ends
  mutate(name = str_remove_all(name, ", IN PART\\)")) %>%
  mutate(name = str_remove_all(name, ", MISAPPLIED\\)")) %>%
  mutate(name = str_remove_all(name, ", MISAPPLIED")) %>%
  mutate(name = str_remove_all(name, "MISAPPLIED")) %>%
  mutate(name = str_remove_all(name, "\\(EXCLUDING SSP. BUXIFORME\\)")) %>%
  mutate(name = str_remove_all(name, "\\[|\\]")) %>%
  mutate(name = str_remove_all(name, "\\s*\\{[^\\)]+\\}")) %>%
  mutate(acronym = str_remove_all(acronym, "\\[|\\]")) %>%
  mutate(acronym = str_replace_all(acronym, "7-FEB", "FEBR")) %>%
  mutate(acronym = str_replace_all(acronym, "_CYCA", "CYCA")) %>%
  mutate(acronym = str_replace_all(acronym, "_DIDIY", "DIDIY")) %>%
  mutate(name = str_replace_all(name, "A. PRAEALTUS VAR. NEBR.\\)", "A. PRAEALTUS VAR. NEBR.")) %>%
  mutate(name = str_replace_all(name, "A. ERICOIDES SSP. PANSUS\\)", "A. ERICOIDES SSP. PANSUS")) %>%
  mutate(acronym = str_replace_all(acronym, "41429", "JUNE")) %>%
  mutate(acronym = na_if(acronym, "2/7/2016")) %>%
  filter(name != "INCLUDING 1 SSP.CIES)") %>%
  filter(name != "NEW TAXON FORMERLY INCL IN C. SESQUIFLORA (ADDED BY ANTIEAU)")

#sort data frame column alphabetically
fqa_db_cols <- fqa_name[order(fqa_name$fqa_db), ]

#get desired column order
fqa_db <- fqa_db_cols %>%
  select(name, name_origin, acronym, accepted_scientific_name, family, nativity, c,
         w, wetland_indicator, physiognomy, duration, common_name, fqa_db) %>%
  mutate(c = as.numeric(c))


#check for dups
dup_names <- fqa_db %>%
  group_by(name, fqa_db, name_origin) %>%
  summarise(n = n()) %>%
  filter(name_origin == "accepted_scientific_name")

#check for dups
dup_acronym <- fqa_db %>%
  group_by(acronym, fqa_db) %>%
  filter(!is.na(acronym)) %>%
  filter(fqa_db != "pennsylvania_piedmont_2013") %>%
  summarise(n = n())

#SAVING DATA-------------------------------------------------------------------------------
#saving dataset MAKE SURE IT IS CLEAN VERSION!!!

#use this dataset  (not viewable to package user)
usethis::use_data(fqa_db, overwrite = TRUE, compress = "xz")

#optimize and check compression
# tools::resaveRdaFiles("data/fqa_db.rda")
# tools::checkRdaFiles("data/fqa_db.rda")
