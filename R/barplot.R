suppressPackageStartupMessages({
  library(forcats)
  library(tidyverse)
  library(argparse)
  library(viridis)
})

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-w", "--utility_directory",
                    type = "character",
                    default = NULL,
                    help = "full path to location of utility directory")
parser$add_argument("-d", "--data",
                    type = "character",
                    nargs = "+",
                    default = NULL,
                    help = "full path to directory containing .tsv files")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
parser$add_argument("-p", "--plot",
                    type = "character",
                    default = NULL,
                    help = "one of: standard, stacked")
parser$add_argument("-a", "--arrangement",
                    type = "character",
                    default = NULL,
                    required = FALSE,
                    help = "one of: vertical, horizontal (defaults to vertical)")
parser$add_argument("-m", "--max",
                    type = "integer",
                    default = NULL,
                    required = FALSE,
                    help = "number of variables to plot (defaults to 10)")
args <- parser$parse_args()

make_barplot <- function(data, orientation = "vertical", max = 30) {
  #' Make a simple bar plot of species abundance.
  #' 
  #' Creates a bar plot of mean abundance grouped by species.
  #' 
  #' @param data data frame
  #' @param orientation string (vertical/horizontal)
  #' @param max integer (max number of entries to display (ordered by decreasing abundance),
  #' any further entries are categorized into 'Other')
  #' @returns ggplot object (CLI will save plot as image)
  
  summary_data <- data %>%
    group_by(species) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  if (max > 0) {
    total_abundance <- summary_data %>%
      group_by(species) %>%
      summarize(total_abundance = sum(mean_abundance)) %>%
      arrange(desc(total_abundance))
    
    # Get the top 10 species
    top_species <- total_abundance %>%
      slice(1:max) %>%
      pull(species)
    
    # Reclassify other species as "Other"
    summary_data <- summary_data %>%
      mutate(species = if_else(species %in% top_species, species, "Other")) %>% 
      mutate(min_abundance = if_else(species %in% top_species, min_abundance, NA)) %>% 
      mutate(max_abundance = if_else(species %in% top_species, max_abundance, NA)) %>% 
      group_by(species, min_abundance, max_abundance) %>% 
      summarise(mean_abundance = sum(mean_abundance))
  }
  
  if (orientation == "vertical") {
    mapping <- summary_data %>% 
      ggplot(mapping = aes(x = species,
                           y = mean_abundance
      )
      )
  } else if (orientation == "horizontal") {
    mapping <- summary_data %>% 
      ggplot(mapping = aes(x = mean_abundance,
                           y = species
      )
      )
  } else {
    warning("[!!] Invalid orientation paramter, check docs")
    stop()
  }
  
  plot <- mapping + 
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_viridis(discrete = TRUE, option = "A") +
    theme_minimal() +
    custom_theme_blank +
    labs(title = "Microbial Species Abundance Averaged (mean) Across all Samples")
  
  if (orientation == "vertical") {
    plot <- plot +
      geom_errorbar(aes(ymin = min_abundance, ymax = max_abundance),
                    width = 0.2,
                    position = position_dodge(width = 0.9)) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
      labs(x = "Species",
           y = "Mean Abundance")
  } else if (orientation == "horizontal") {
    plot <- plot + 
      geom_errorbar(aes(xmin = min_abundance, xmax = max_abundance),
                    width = 0.2,
                    position = position_dodge(width = 0.9)) +
      labs(x = "Mean Abundance",
           y = "Species")
  }
  return(plot)
  
}

make_stacked_barplot <- function(data, orientation = "vertical", max = 10) {
  #' Make a stacked bar plot of species abundance.
  #' 
  #' Creates a stacked bar plot of mean abundance of species for each source (as a 
  #' fraction of total abundance per source).
  #' 
  #' @param data data frame
  #' @param orientation string (vertical/horizontal)
  #' @param max integer (max number of entries to display (ordered by decreasing abundance),
  #' any further entries are categorized into 'Other')
  #' @returns ggplot object (CLI will save plot as image)
  
  summary_data <- data %>%
    group_by(species, source) %>%
    summarize(
      fractional_abundance = mean(abundance)
    )
  
  if (max > 0) {
    total_abundance <- summary_data %>%
      group_by(species) %>%
      summarize(total_abundance = sum(fractional_abundance)) %>%
      arrange(desc(total_abundance))
    
    # Get the top 10 species
    top_species <- total_abundance %>%
      slice(1:max) %>%
      pull(species)
    
    # Reclassify other species as "Other"
    summary_data <- summary_data %>%
      mutate(species = ifelse(species %in% top_species, species, "Other"))
  }
  
  if (orientation == "horizontal") {
    mapping <- summary_data %>% 
      ggplot(mapping = aes(x = fractional_abundance,
                           y = source,
                           fill = species
      )
      )
  } else if (orientation == "vertical") {
    mapping <- summary_data %>% 
      ggplot(mapping = aes(x = source,
                           y = fractional_abundance,
                           fill = species
      )
      )
  } else {
    warning("[!!] Invalid orientation paramter, check docs")
    stop()
  }
  
  plot <- mapping +
    geom_bar(stat = "identity", position = "fill") +
    scale_fill_viridis(discrete = TRUE, option = "A") +
    theme_minimal() +
    custom_theme_blank +
    labs(title = "Relative Abundance of Microbial Species Across Samples")
  # theme(legend.position = "none") +
  
  if (orientation == "vertical") {
    plot <- plot +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
      labs(x = "Sample",
           y = "Relative Abundance")
  } else if (orientation == "horizontal") {
    plot <- plot +
      labs(x = "Relative Abundance",
           y = "Sample")
  }
  
  return(plot)
  
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
  
  # Make and save the plot
  message("[>>] Generating plot")
  jpeg(paste0(args$output, "barplot.jpeg"), height = 2160, width = 3840, res = 300)
  if (args$plot == "standard") {
    suppressMessages(
      make_barplot(user_data, orientation = args$arrangement, max = args$max)
    )
  } else if (args$plot == "stacked") {
    suppressMessages(
      make_stacked_barplot(user_data, orientation = args$arrangement, max = args$max)
    )
  } else {
    warning("[!!] Unknown plot type - check docs")
    message("[>>] Exiting")
    stop()
  }
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("[COMPLETE]")
}
