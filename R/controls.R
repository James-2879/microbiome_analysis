suppressPackageStartupMessages({
  library(argparse)
  library(tidyverse)
  library(viridis)
  library(scales)
  library(pander)
})

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-w", "--utility_directory",
                    type = "character",
                    default = NULL,
                    help = "full path to location of utility directory")
parser$add_argument("-d", "--data",
                    type = "character",
                    default = NULL,
                    nargs = "+",
                    help = "full path to directory containing .tsv files")
parser$add_argument("-a", "--analyze",
                    action = "store_true",
                    help = "find the conditions that best match standard (
                    creates a plot if flag not specified)")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
args <- parser$parse_args()

plot_controls <- function(data) {
  #' Plot fractional species abundance against Zymo standard.
  #' 
  #' @param data data frame
  #' @return ggplot object (CLI will save plot as image)
  
  zymo_standard <- suppressMessages(read_tsv("~/Documents/microbiome_analysis/inst/extdata/zymo_standard.tsv")) %>% 
    select(-taxonomy) %>% 
    mutate(source = "zymo")
  
  mock <- data %>% 
    select(-c(taxonomy, entry_id)) %>% 
    mutate(species = if_else(species %in% zymo_standard$species, species, "other"))
  
  mock_standards <- bind_rows(mock, zymo_standard)
  
  plot <- mock_standards %>% 
    ggplot(mapping = aes(x = source,
                         y = abundance,
                         fill = species,
                         label = species
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    scale_fill_viridis_d() + # Add in colorblind palette
    labs(title = "Sequenced mock community species abundances versus reference",
         subtitle = "Abundance of each species as a fraction of total abundance",
         x = "Data source",
         y = "Fractional abundance") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    theme(legend.position = "right")
  plot
  
  return(plot)
}

divide_by_sum <- function(col) {
  (col / sum(col))*100
}

analyze_processing_configs <- function(data, best_method = FALSE) {
  #' Analyse processing configurations for congruence.
  #' 
  #' Calculates the differences between fractional species abundances compared
  #'  with the ZymoBIOMICS standard.
  #'  
  #' @param data data frame
  #' @param best_method boolean (return only the best value (FALSE returns all))
  #' @returns the best (or all) processing configurations and distance from the standard
  
  zymo_standard <- suppressMessages(read_tsv("~/Documents/microbiome_analysis/inst/extdata/zymo_standard.tsv")) %>% 
    select(-taxonomy) %>% 
    mutate(source = "zymo")
  
  mock <- data %>% 
    select(-c(taxonomy, entry_id)) %>% 
    mutate(species = if_else(species %in% zymo_standard$species, species, "other"))
  
  mock_standards <- bind_rows(mock, zymo_standard)
  
  compute <- mock_standards %>% 
    filter(source != "zymo")
  
  compute <- compute %>% 
    group_by(species, source) %>% 
    summarise("abundance" = sum(abundance)) %>% 
    pivot_wider(values_from = "abundance", names_from = "source") %>% 
    column_to_rownames(var = "species")
  
  compute[is.na(compute)] <- 0
  
  compute_normalized <- as.data.frame(apply(compute, 2, divide_by_sum))
  compute_normalized <- compute_normalized %>% 
    rownames_to_column(var = "species")
  
  zymo_with_selected <- zymo_standard %>% 
    select(-source) %>% 
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
    pivot_longer(cols = 3:ncol(all_normalized), names_to = "method", values_to = "percentage") %>%
    mutate(difference = abs(percentage - zymo)) %>%
    group_by(method) %>%
    summarise(total_difference = sum(difference))
  
  if (best_method) {
    best_method <- ranked_methods %>% 
      slice_min(order_by = total_difference) %>%
      pull(method)
    return(best_method)
  } else {
    ranked_methods <- ranked_methods %>% 
      arrange(total_difference)
    pander(ranked_methods, style = "simple")
    # return(ranked_methods)
  }
}

# CLI ----

if (!interactive()) {
  
  setwd(toString(args$utility_directory))
  
  # Load required functions
  message("[>>] Preparing session and data")
  suppressPackageStartupMessages({
    source("R/data.R")
    source("R/themes.R")
  })
  message("[OK] Loaded packages")
  message("[OK] Sourced tools")
  
  # Load data and check against expected format
  user_data <- load_user_data_dir(args$data)
  check_data(user_data)
  
  if (args$analyze) {
    analyze_processing_configs(user_data, best_method = FALSE)
  } else {
    # Make and save the plot
    message("[>>] Generating plot")
    jpeg(paste0(args$output, "controls.jpeg"), height = 3000, width = 4500, res = 300)
    plot_controls(user_data)
  }
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  if (!args$analyze) {
    message(paste0("[OK] Saved plot to ", args$output))
  }
  message("[COMPLETE]")
}