load_data <- function() {
  # Globally load all data to R environment
  test_microbiome <<- read_tsv("data/input/test_microbiome.tsv") %>% 
    mutate("domain" = str_split_i(taxonomy, ";", -8)) %>% 
    mutate("kingdom" = str_split_i(taxonomy, ";", -7)) %>% 
    mutate("phylum" = str_split_i(taxonomy, ";", -6)) %>% 
    mutate("class" = str_split_i(taxonomy, ";", -5)) %>% 
    mutate("order" = str_split_i(taxonomy, ";", -4)) %>% 
    mutate("family" = str_split_i(taxonomy, ";", -3)) %>% 
    mutate("genus" = str_split_i(taxonomy, ";", -2)) %>% 
    mutate("species" = str_split_i(taxonomy, ";", -1)) %>% 
    mutate(species = tolower(species)) %>% 
    mutate(scientific_name = paste(genus, species))
  
  reference_abundances <<- read_tsv("data/input/control_reference_table.txt")
  
  # Make these variable names better
  sample_1 <<- read_tsv("data/input/sample_1.tsv") %>%
    mutate("repeat" = "1")
  sample_2 <<- read_tsv("data/input/sample_2.tsv") %>%
    mutate("repeat" = "2")
  sample_3 <<- read_tsv("data/input/sample_3.tsv") %>%
    mutate("repeat" = "3")
  
  # Make this variable name better
  all_samples <<- bind_rows(sample_1, sample_2, sample_3) %>%
    mutate("domain" = str_split_i(Taxa, ";", -8)) %>%
    mutate("kingdom" = str_split_i(Taxa, ";", -7)) %>%
    mutate("phylum" = str_split_i(Taxa, ";", -6)) %>%
    mutate("class" = str_split_i(Taxa, ";", -5)) %>%
    mutate("order" = str_split_i(Taxa, ";", -4)) %>%
    mutate("family" = str_split_i(Taxa, ";", -3)) %>%
    mutate("genus" = str_split_i(Taxa, ";", -2)) %>%
    mutate("species" = str_split_i(Taxa, ";", -1)) %>%
    mutate(species = tolower(species)) %>%
    mutate(scientific_name = paste(genus, species)) %>%
    mutate("day" = "default") %>% # TODO remove once data complete
    mutate("location" = "default") %>% # TODO remove once data complete
    mutate("type" = "default") # TODO remove once data complete
  
  remove(sample_1, sample_2, sample_3, envir = globalenv())
  
}