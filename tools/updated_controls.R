library(tidyverse)
library(viridis)
library(scales)

clean_control_data <- function(samples) {
  
  zymo_standard <- read_tsv("~/Documents/microbiome_analysis/data/input/luke/zymo_standard.tsv") %>% 
    select(-taxonomy) %>% 
    mutate(group = "zymo") %>% 
    mutate(sample = "zymo")
  
  mock <- samples %>% 
    select(-taxonomy) %>% 
    mutate(species = if_else(species %in% zymo_standard$species, species, "other")) %>% 
    # filter(species %in% zymo_standard$species) %>% 
    unite("group", 4:8, remove = TRUE)
  
  mock_standards <- bind_rows(mock, zymo_standard)
  
  return(mock_standards)
}

plot_updated_controls <- function(samples) {
  
  mock_standards <- clean_control_data(samples = samples)
  
  plot <- mock_standards %>% 
    ggplot(mapping = aes(x = `sample`,
                         y = abundance,
                         fill = species,
                         label = species
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "_", " "), width = 15)) +
    # facet_wrap("sample") +
    # scale_x_discrete(labels = function(x) str_wrap(x, width = 20)) +
    scale_fill_viridis_d() + # Add in colorblind palette
    labs(title = "Sequenced mock community species abundances versus reference",
         subtitle = "Abundance of each species as a fraction of total abundance",
         x = "Data source",
         y = "Fractional abundance") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) +
    theme(legend.position = "none")
  plot
  
  return(plot)
}

divide_by_sum <- function(col) {
  (col / sum(col))*100
}

analyse_processing_configs <- function(samples, best_method = FALSE) {
  
  mock_standards <- clean_control_data(samples = samples)
  
  zymo_standard <- read_tsv("~/Documents/microbiome_analysis/data/input/luke/zymo_standard.tsv") %>% 
    select(-taxonomy) %>% 
    mutate(group = "zymo") %>% 
    mutate(sample = "zymo")
  
  compute <- mock_standards %>% 
    filter(sample != "zymo") %>% 
    unite("group", 3:4, sep = "_")
  
  compute <- compute %>% 
    group_by(species, group) %>% 
    summarise("abundance" = sum(abundance)) %>% 
    pivot_wider(values_from = "abundance", names_from = "group") %>% 
    column_to_rownames(var = "species")
  
  compute[is.na(compute)] <- 0
  
  compute_normalized <- as.data.frame(apply(compute, 2, divide_by_sum))
  compute_normalized <- compute_normalized %>% 
    rownames_to_column(var = "species")
  
  zymo_with_selected <- zymo_standard %>% 
    select(-group, sample) %>% 
    mutate(species = if_else(species %in% compute_normalized$species, species, "other"))
  zymo_with_selected <- zymo_with_selected %>% 
    group_by(species) %>% 
    summarise("abundance" = sum(abundance)) %>% 
    column_to_rownames(var = "species")
  
  zymo_with_selected_normalized <- as.data.frame(apply(zymo_with_selected, 2, divide_by_sum))
  zymo_with_selected_normalized <- zymo_with_selected_normalized %>% 
    rownames_to_column(var = "species") %>% 
    rename("zymo" = abundance)
  
  all_normalized <- left_join(zymo_with_selected_normalized, compute_normalized)
  
  ranked_methods <- all_normalized %>%
    pivot_longer(cols = 3:29, names_to = "method", values_to = "percentage") %>%
    mutate(difference = abs(percentage - zymo)) %>%
    group_by(method) %>%
    summarise(total_difference = sum(difference))
  
  if (best_method) {
    best_method <- ranked_methods %>% 
      slice_min(order_by = total_difference) %>%
      pull(method)
    return(best_method)
  } else {
    return(ranked_methods)
  }
}
