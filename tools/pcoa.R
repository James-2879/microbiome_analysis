library(vegan)
library(tidyverse)

do_pcoa <- function(data) {
  
  # Change shape for PCoA analysis
  pcoa_data <- data %>% 
    select(c(scientific_name, abundance, day, location, type, `repeat`)) %>% 
    group_by(day, location, type, `repeat`, scientific_name) %>%
    summarise(abundance = mean(abundance, na.rm = TRUE)) %>%
    filter(!is.na(abundance)) %>%
    pivot_wider(names_from = scientific_name, values_from = abundance) %>% 
    select_if(~all(complete.cases(.))) %>% 
    ungroup() %>% 
    mutate("sample_id" = paste0("sample_", seq(1, dim(pcoa_data)[1]))) %>% 
    mutate("sample_id_copy" = sample_id) %>% 
    column_to_rownames(var = "sample_id") %>% 
    rename("sample_id" = sample_id_copy) %>% 
    select(sample_id, everything())
  
  # Calculate distances using Bray-Curtis method
  ab.dist <- vegdist(pcoa_data[, 6:ncol(pcoa_data)], method="bray", diag=FALSE, upper=FALSE)
  
  # Perform multidimensional scaling
  pcoa_result <- cmdscale(ab.dist, k = 2)
  
  # Rename PCoA columns
  pcoa_df <- as.data.frame(pcoa_result) %>% 
    rownames_to_column(var = "sample_id") %>% 
    rename("PCoA1" = V1,
           "PCoA2" = V2) %>% 
    left_join(pcoa_data[, 1:5])
  
  # Plot the scaled distances
  pcoa_plot <- ggplot(pcoa_df,
                      mapping = aes(x = PCoA1,
                                    y = PCoA2,
                                    color = `repeat`
                      )) +
    geom_point() +
    theme_minimal()
  pcoa_plot
  
  return(pcoa_plot)
}

# https://journals.asm.org/doi/10.1128/msystems.00166-16





