library(vegan)
library(tidyverse)

do_pcoa <- function(data, classification) {
  
  ### Should abundances be relative to each other at this point
  ### I mean they probably are already if they're percentages
  
  # Filter data to be used in analysis
  # Change shape for PCoA analysis
  pcoa_data <<- data %>% 
    rename("organism" = classification) %>% 
    select(c(organism, abundance, day, location, type, `repeat`)) %>% 
    mutate(`repeat` = paste0("repeat_", `repeat`)) %>% 
    group_by(day, location, type, `repeat`) %>%
    summarise("abundance" = sum(abundance)) %>%
    pivot_wider(names_from = `repeat`, values_from = abundance) %>% 
    select_if(~all(complete.cases(.)))
  
  pcoa_data <- pcoa_data %>% 
    pivot_longer(cols = 4:length(pcoa_data), values_to = "abundance", names_to = "repeat")
  
  # Add a sample ID column for later 
  # (annotations and data need to be split for analysis)
  sample_ids <- seq(1, dim(pcoa_data)[1])
  sample_ids <- paste0("sample_", sample_ids)
  pcoa_data <- pcoa_data %>% 
    add_column(sample_ids) %>%
    column_to_rownames("sample_ids")
  
  # Split off the data frames
  abundance_df <<- pcoa_data %>% 
    select(-c(location, day, type, `repeat`))
  annotations_df <<- pcoa_data %>% 
    select(c(location, day, type, `repeat`)) %>% 
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
                                    color = `repeat`
                                    # shape = `repeat` # Maybe we don't want this bit
                                    )) +
    geom_point() +
    theme_minimal()
  pcoa_plot
  
  # Could potentially also facet these by group depending on reqs
  
  return(pcoa_plot)
}

# https://journals.asm.org/doi/10.1128/msystems.00166-16





