library(vegan)

do_pcoa <- function(data) {
  
  ### Should abundances be relative to each other at this point
  ### I mean they probably are already if they're percentages
  
  # Change shape for PCoA analysis and calculate mean of repeats
  # data0 <- data %>% 
  #   filter(type != "CTRL") %>% 
  #   group_by(organism, type, location, day) %>% 
  #   summarise(mean_abundance = mean(`abundance`)) %>%
  #   ungroup() %>% 
  #   pivot_wider(names_from = organism, values_from = mean_abundance) %>% 
  #   select(-type)
  
  # Change shape for PCoA analysis
  data0 <- data %>% 
    filter(type != "CTRL") %>% 
    pivot_wider(names_from = organism, values_from = abundance) %>% 
    select(-c(type, `repeat`))
  
  # Add a sample ID column for later 
  # (annotations and data need to be split for analysis)
  sample_ids <- seq(1, dim(data0)[1])
  sample_ids <- paste0("sample_", sample_ids)
  data0 <- data0 %>% 
    add_column(sample_ids) %>% 
    column_to_rownames(var = "sample_ids")
  
  # Split off the data frames
  abundance_df <- data0 %>% 
    select(-c(location, day))
  annotations_df <- data0 %>% 
    select(c(location, day)) %>% 
    rownames_to_column(var = "sample_ids")
  
  # Calculate distances using Bray-Curtis method
  ab.dist <- vegdist(abundance_df, method="bray", diag=FALSE, upper=FALSE)
  
  # Perform multidimensional scaling
  pcoa_result <- cmdscale(ab.dist, k = 2)
  
  # Join scaled distances back up with annotations
  pcoa_df <- as.data.frame(pcoa_result) %>% 
    rownames_to_column(var = "sample_ids") %>% 
    left_join(annotations_df, by = "sample_ids") %>% 
    select(-sample_ids) %>% 
    rename("PCoA1" = V1,
           "PCoA2" = V2)
  
  # Plot the scaled distances
  pcoa_plot <- ggplot(pcoa_df,
                      mapping = aes(x = PCoA1,
                                    y = PCoA2,
                                    color = location,
                                    shape = day)) +
    geom_point() +
    theme_minimal()
  pcoa_plot
  
  # Could potentially also facet these by group depending on reqs
  
  return(pcoa_plot)
}
