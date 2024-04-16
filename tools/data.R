load_data <- function(path) {
  # Globally load all data to R environment
  test_microbiome <<- read_tsv(paste0(path, "data/input/test_microbiome.tsv")) %>% 
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
  
  reference_abundances <<- read_csv(paste0(path, "data/input/control_reference_table.txt")) %>% 
    mutate(genus = str_split_i(scientific_name, " ", 1)) %>% 
    mutate(species = str_split_i(scientific_name, " ", 2))
  
  # Make these variable names better
  sample_1 <<- read_tsv(paste0(path, "data/input/sample_1.tsv")) %>%
    mutate("repeat" = "1")
  sample_2 <<- read_tsv(paste0(path, "data/input/sample_2.tsv")) %>%
    mutate("repeat" = "2")
  sample_3 <<- read_tsv(paste0(path, "data/input/sample_3.tsv")) %>%
    mutate("repeat" = "3")
  
  # Make this variable name better
  all_samples <<- bind_rows(sample_1, sample_2, sample_3) %>%
    mutate("domain" = str_split_i(taxa, ";", -8)) %>%
    mutate("kingdom" = str_split_i(taxa, ";", -7)) %>%
    mutate("phylum" = str_split_i(taxa, ";", -6)) %>%
    mutate("class" = str_split_i(taxa, ";", -5)) %>%
    mutate("order" = str_split_i(taxa, ";", -4)) %>%
    mutate("family" = str_split_i(taxa, ";", -3)) %>%
    mutate("genus" = str_split_i(taxa, ";", -2)) %>%
    mutate("species" = str_split_i(taxa, ";", -1)) %>%
    mutate(species = tolower(species)) %>%
    mutate(scientific_name = paste(genus, species)) %>%
    mutate("day" = "default") %>% # TODO remove once data complete
    mutate("location" = "default") %>% # TODO remove once data complete
    mutate("type" = "default") # TODO remove once data complete
  
  remove(sample_1, sample_2, sample_3, envir = globalenv())
  
}

check_data <- function(data) {
  expected_cols <- c("taxa", "abundance", "day", "location", "repeat", "type")
  if (sum(expected_cols %in% tolower(colnames(data))) == length(expected_cols)) {
    message("[OK] Found expected columns in data")
    message("     (Note extra columns will be ignored)")
  } else {
    message("[!!] Unable to find all expected columns")
    missing_cols <- expected_cols[!expected_cols %in% tolower(colnames(data))]
    message(paste0("     Missing: ", missing_cols))
    message("[**] Aborting - check input")
    quit()
  }
}

tidy_data <- function(data) {
  colnames(data) <- tolower(colnames(data))
  data <- data %>% 
    mutate("domain" = str_split_i(taxa, ";", -8)) %>%
    mutate("kingdom" = str_split_i(taxa, ";", -7)) %>%
    mutate("phylum" = str_split_i(taxa, ";", -6)) %>%
    mutate("class" = str_split_i(taxa, ";", -5)) %>%
    mutate("order" = str_split_i(taxa, ";", -4)) %>%
    mutate("family" = str_split_i(taxa, ";", -3)) %>%
    mutate("genus" = str_split_i(taxa, ";", -2)) %>%
    mutate("species" = str_split_i(taxa, ";", -1)) %>%
    mutate(species = tolower(species)) %>%
    mutate(scientific_name = paste(genus, species))
  message("[OK] Unpacked taxonomy into separate classes")
  return(data)
}