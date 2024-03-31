library(vegan)
library(tidyverse)

do_pcoa <- function(data, classification) {
  
  ### Should abundances be relative to each other at this point
  ### I mean they probably are already if they're percentages
  
  # Filter data to be used in analysis
  # Change shape for PCoA analysis
  # TODO the pivot_wider then pivot_longer is probably unnecessary
  pcoa_data <<- data %>% 
    rename("organism" = classification) %>% 
    select(c(organism, abundance, day, location, type, `repeat`)) %>% 
    group_by(organism, day, location, type, `repeat`) %>%
    summarise("abundance" = sum(abundance)) %>%
    pivot_wider(names_from = organism, values_from = abundance) %>% 
    select_if(~all(complete.cases(.))) %>% 
    pivot_longer(cols = 5:length(data0), values_to = "abundance", names_to = "organism")
  
  # Add a sample ID column for later 
  # (annotations and data need to be split for analysis)
  sample_ids <- seq(1, dim(pcoa_data)[1])
  sample_ids <- paste0("sample_", sample_ids)
  pcoa_data <- pcoa_data %>% 
    add_column(sample_ids) %>%
    column_to_rownames("sample_ids")
  
  # Split off the data frames
  abundance_df <<- pcoa_data %>% 
    select(-c(location, day, type, `repeat`, organism))
  annotations_df <<- pcoa_data %>% 
    select(c(organism, location, day, type, `repeat`)) %>% 
    rownames_to_column(var = "sample_ids")
  
  # Calculate distances using Bray-Curtis method
  ab.dist <<- vegdist(abundance_df, method="bray", diag=FALSE, upper=FALSE)
  
  # Perform multidimensional scaling
  pcoa_result <<- cmdscale(ab.dist, k = 2)
  
  # Join scaled distances back up with annotations
  pcoa_df <<- as.data.frame(pcoa_result) %>% 
    rownames_to_column(var = "sample_ids") %>% 
    left_join(annotations_df, by = "sample_ids") %>% 
    select(-sample_ids) %>% 
    rename("PCoA1" = V1,
           "PCoA2" = V2)
  
  # Plot the scaled distances
  pcoa_plot <- ggplot(pcoa_df,
                      mapping = aes(x = PCoA1,
                                    y = PCoA2,
                                    color = organism,
                                    shape = `repeat`)) +
    geom_point() +
    theme_minimal()
  pcoa_plot
  
  # Could potentially also facet these by group depending on reqs
  
  return(pcoa_plot)
}

# Main ----

sample_1 <- read_tsv("data/input/sample_1.tsv") %>% 
  mutate("repeat" = "1")
sample_2 <- read_tsv("data/input/sample_2.tsv") %>% 
  mutate("repeat" = "2")
sample_3 <- read_tsv("data/input/sample_3.tsv") %>% 
  mutate("repeat" = "3")

# currently this data is not good enough to group by genus or species
all_samples <- bind_rows(sample_1, sample_2, sample_3) %>% 
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
  mutate("day" = "default") %>%
  mutate("location" = "default") %>%
  mutate("type" = "default")

# https://journals.asm.org/doi/10.1128/msystems.00166-16

pcoa_order <- do_pcoa(data = all_samples, classification = "order")
pcoa_order

pcoa_family <- do_pcoa(data = all_samples, classification = "family")
pcoa_family

pcoa_genus <- do_pcoa(data = all_samples, classification = "genus")
pcoa_genus

pcoa_species <- do_pcoa(data = all_samples, classification = "species")
pcoa_species

  # Inlcude this in error checking somewhere
# pcoa_data <- all_samples %>%
#   filter(!is.na(genus)) %>%
#   filter(!is.na(species)) %>%
#   filter(genus != species) %>%
#   select(c(genus, species, abundance, `repeat`))



