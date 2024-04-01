library(phyloseq)
library(tidyverse)

create_network <- function(data, taxonomic_level, max_dist) {
  # Clean input data containing multiple samples (more samples is better)
  cleaned_df <- data %>% 
    mutate("repeat" = paste0("repeat_", `repeat`)) %>% 
    pivot_wider(names_from = `repeat`, values_from = abundance)
  
  # Make arbitrary sample IDs
  sample_ids <- seq(1, dim(cleaned_df)[1])
  sample_ids <- paste0("sample_", sample_ids)
  
  # Add sample IDs to data and remove NA values
  cleaned_df <- cleaned_df %>% 
    add_column(sample_ids) %>%
    column_to_rownames("sample_ids") %>% 
    filter(!is.na(repeat_1) & !is.na(repeat_2) & !is.na(repeat_3))
  
  # Create dataframe with sample data annotations
  sample_df <- cleaned_df %>% 
    select(c(day, location, type, repeat_1, repeat_2, repeat_3)) %>% 
    pivot_longer(cols = c(repeat_1, repeat_2, repeat_3), names_to = "repeat", values_to = "abundance") %>% 
    select(-abundance) %>% 
    distinct(`repeat`, .keep_all = TRUE) %>% 
    column_to_rownames("repeat")
  
  # Abundance data
  otu_mat <- cleaned_df %>% 
    select(c(repeat_1, repeat_2, repeat_3)) %>% 
    as.matrix()
  
  # Taxonomy data
  tax_mat <- cleaned_df %>% 
    select(-c(scientific_name, Taxa, day, location, type, repeat_1, repeat_2, repeat_3)) %>% 
    as.matrix()
  
  # Convert to phyloseq objects
  SAMP = sample_data(sample_df)
  OTU = otu_table(otu_mat, taxa_are_rows = TRUE)
  TAX = tax_table(tax_mat)
  physeq_object <- phyloseq(OTU, TAX, SAMP)
  
  # Clean up
  remove(sample_ids)
  remove(cleaned_df)
  remove(sample_df)
  remove(SAMP, TAX, OTU)
  
  set.seed(123L)
  
  # Calculate the network
  network <- plot_net(physeq_object,
                      distance = "bray",
                      maxdist = max_dist,
                      point_label = taxonomic_level,
                      type = "taxa"
  )
  
  return(network)
}




