library(tidyverse)
library(rentrez)
library(XML)

if (interactive()) {
  script_dir <- "/home/james/Documents/microbiome_analysis/"
  cache_dir <- "/home/james/Documents/microbiome_analysis/data/input/NCBI_cache/"
  setwd(script_dir)
}

if (!dir.exists(cache_dir)) {
  dir.create(cache_dir, recursive = TRUE)
}

source("tools/data.R")
load_data(script_dir)

# Fetch taxonomic info, either from cache or NCBI
fetch_taxonomic_info <- function(species_name) {
  file_name <- file.path(cache_dir, paste0(gsub(" ", "_", species_name), ".xml"))
  tax_info_xml <- NULL
  if (file.exists(file_name)) {
    # Read the XML from the cache
    message(paste0("Fetching entry from cache for ", species_name))
    tax_info_xml <- xmlParse(file_name)
  } else {
    # Sleep to avoid hitting too many requests error (414?)
    Sys.sleep(1)
    # Fetch XML from NCBI
    message(paste0("Fetching entry from NCBI for ", species_name))
    
    # Search for the taxonomic ID based on species name
    search_result <- entrez_search(db="taxonomy", term=species_name)
    tax_id <- search_result$ids[1]
    
    # Attempt to fetch detailed taxonomic information
    tryCatch({
      tax_info_xml_raw <- entrez_fetch(db="taxonomy", id=tax_id, rettype="xml")
      tax_info_xml <- xmlParse(tax_info_xml_raw)
      # Write XML to cache
      writeLines(as.character(tax_info_xml_raw), file_name)
    }, error = function(error) {
      message(paste0("[!!] Unable to fetch entry for ", species_name))
    }
    )
  }
  
  return(tax_info_xml)
}

# Check if a sinlge organism is unicellular
is_likely_unicellular <- function(xml_list) {
  # List of known unicellular taxa
  unicellular_taxa <- c("Protista", "Monera", "Archaea", "Bacteria", "Cyanobacteria")
  # Check if each of the taxa are unicellular
  if (any(unlist(xml_list) %in% unicellular_taxa)) {
    return("TRUE")
  } else {
    return("FALSE")
  }
}

# ----

# Check if each organism in a vector is unicellular
check_taxa <- function(species_vector) {
  checked_taxa <- map_df(.x = species_vector,
                         .f = function(species) {
                           position <- which(species_vector == species)
                           cat(paste0("Searching ", position, " of ", length(species_vector), "\r"))
                           tryCatch({
                             species_info <- fetch_taxonomic_info(species)
                             xml_list <- xmlToList(species_info)
                             result <- species %>% 
                               as.data.frame() %>% 
                               add_column("likely_unicellular" = is_likely_unicellular(xml_list))
                             return(result)
                           }, error = function(error) {
                             # Non-uniquely handle any error
                             result <- species %>% 
                               as.data.frame() %>% 
                               add_column("likely_unicellular" = "FAILED")
                             return(result)
                           }
                           )
                         }
  ) %>% 
    rename("species" = ".")
  
  failed <- checked_taxa %>% 
    filter(likely_unicellular == "FAILED") %>% 
    count() %>% 
    as.character()
  
  if (failed > 0) {
    message(paste0("[!!] Failed to get taxonomic info for ", failed, " entries"))
  }
  
  return(checked_taxa)
}

# Pull common name for species from NCBI
get_common_names <- function(species_vector) {
  map_chr(.x = species_vector,
          .f = function(species) {
            position <- which(species_vector == species)
            cat(paste0("Searching ", position, " of ", length(species_vector), "\r"))
            species_info <- fetch_taxonomic_info(species)
            if (!is.null(species_info)) {
            xml_list <- xmlToList(species_info)
            common_name <- xml_list[["Taxon"]][["OtherNames"]][["GenbankCommonName"]]
            } else {
              common_name <- "NON FOUND"
            }
            if (!is.null(common_name)) {
              names <- paste0(species, ": ", common_name)
            } else {
              names <- paste0(species, ": ", "NONE FOUND")
            }
            return(names)
          })
}


# ----

if (interactive()) {
  species_vector <- final_samples %>% 
    filter(minimap_thresh == "MM-50") %>% 
    pull(species) %>% 
    unique(.)
  
  checked_taxa <- check_taxa(species_vector)
  
  to_name <- checked_taxa %>% 
    filter(likely_unicellular == "FALSE") %>% 
    pull(species)
  
  common_names <- get_common_names(to_name)
  common_names
}

assigned_taxa <- unique(test_microbiome$taxonomy)

