library(tidyverse)

if (interactive()) {
  script_dir <- "/home/james/Documents/microbiome_analysis/"
  setwd(script_dir)
}

source("tools/data.R")

load_data(script_dir)


suspects <- test_microbiome %>% 
  select(domain, kingdom, phylum) %>% 
  mutate("sample_id" = seq(1, dim(test_microbiome)[1]))



library(rentrez)
library(XML)

# Function to get taxonomic information
get_taxonomic_info <- function(species_name) {
  # Search for the taxonomic ID based on species name
  search_result <- entrez_search(db="taxonomy", term=species_name)
  tax_id <- search_result$ids[1]
  
  # Fetch detailed taxonomic information
  tax_info <- entrez_fetch(db="taxonomy", id=tax_id, rettype="xml")
  return(tax_info)
}

is_likely_unicellular <- function(xml_list) {
  # You would have a predefined list of kingdoms, phyla, or classes known to be unicellular
  unicellular_taxa <- c("Protista", "Monera", "Archaea", "Bacteria", "Cyanobacteria")
  
  # Traversing through the taxonomy to check each rank
  if (any(unlist(xml_list) %in% unicellular_taxa)) {
    return("TRUE")
  } else {
    return("FALSE")
  }
}

species_vector <- test_microbiome %>% 
  pull(scientific_name) %>% 
  unique(.)

species_vector_test <- species_vector[1:9]

# pull_species_info

species_classification <- map_df(.x = species_vector,
                                 .f = function(x) {
                                   Sys.sleep(1)
                                   position <- which(species_vector == x)
                                   cat(paste0("Searching ", position, " of ", length(species_vector), "\r"))
                                   
                                   tryCatch(expr = {
                                     species_info <- get_taxonomic_info(x)
                                     xml <- xmlParse(species_info)
                                     xml_list <- xmlToList(xml)
                                     
                                     result <- x %>% 
                                       as.data.frame() %>% 
                                       add_column("likely_unicellular" = is_likely_unicellular(xml_list))
                                     return(result)
                                   }, error = function(e) {
                                     result <- x %>% 
                                       as.data.frame() %>% 
                                       add_column("likely_unicellular" = "FAILED")
                                   }
                                   )
                                 }
) %>% 
  rename("species" = ".")

to_check <- species_classification %>% 
  filter(likely_unicellular == "FALSE")


