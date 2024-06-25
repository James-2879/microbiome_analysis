suppressPackageStartupMessages({
  library(forcats)
  library(tidyverse)
  library(argparse)
  library(viridis)
})

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-d", "--data",
                    type = "character",
                    default = NULL,
                    help = "full path to .tsv file")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
parser$add_argument("-p", "--plot",
                    type = "character",
                    default = NULL,
                    help = "barplot type; one of: standard, v-stacked, h-stacked")
parser$add_argument("-l", "--level",
                    type = "character",
                    default = NULL,
                    help = "taxonomic level; probably one of genus or species")
args <- parser$parse_args()

make_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    mutate("repeat" = as.character(`repeat`)) %>% 
    rename("organism" = all_of(classification)) %>% 
    # filter(location == "OW") %>%
    group_by(day, `repeat`, type, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = day,
                         y = mean_abundance,
                         fill = `repeat`
    )
    ) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_errorbar(aes(ymin = min_abundance, ymax = max_abundance),
                  width = 0.2,
                  position = position_dodge(width = 0.9)) +
    facet_wrap("organism") +
    scale_fill_viridis(discrete = TRUE, option = "A") +
    theme_minimal() +
    custom_theme_blank
  return(plot)
  
}

make_stacked_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = all_of(classification)) %>% 
    group_by(day, type, `repeat`, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = `repeat`,
                         y = mean_abundance,
                         fill = organism
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    facet_wrap("location") +
    scale_fill_viridis(discrete = TRUE, option = "A") +
    theme_minimal() +
    custom_theme_blank
  return(plot)
  
}

make_horizontal_stacked_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = all_of(classification)) %>% 
    mutate("repeat" = as.character(`repeat`)) %>% 
    group_by(day, type, `repeat`, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = mean_abundance,
                         y = `repeat`,
                         fill = organism
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    facet_grid(c("day", "type")) +
    scale_fill_viridis(discrete = TRUE, option = "A") +
    theme_minimal() +
    custom_theme_blank
  return(plot)
  
}

make_compressed_stacked_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = all_of(classification)) %>% 
    # filter(location == "OW") %>% 
    # filter(type == "INF") %>% 
    group_by(day, type, `repeat`, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    ) %>% 
    ungroup() %>%
    arrange(day, location, type, ) %>%
    unite("annotation", c(day, `repeat`, location, type), sep = "-")
  
  # Pull numbers from annotation to order by numerically
  numeric_part <- as.numeric(gsub("[^0-9]", "", summary_data$annotation))
  
  # Reorder the factor levels based on the numeric part
  summary_data$annotation <- fct_reorder(summary_data$annotation, numeric_part)
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = mean_abundance,
                         y = annotation,
                         fill = organism
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    scale_fill_viridis(discrete = TRUE, option = "A") +
    theme_minimal() +
    custom_theme_blank
  return(plot)
}

# CLI ----

if (!interactive()) {
  
  # Load required functions
  message("> Preparing session and data")
  suppressPackageStartupMessages({
    source("R/data.R")
    source("R/themes.R")
  })
  message("[OK] Loaded packages")
  message("[OK] Sourced tools")
  
  # Load data and check against expected format
  user_data <- load_user_data(args$data)
  check_data(user_data)
  user_data <- tidy_data(user_data)
  
  # Make and save the plot
  message("> Generating plot")
  jpeg(args$output, height = 2160, width = 3840, res = 300)
  if (args$plot == "standard") {
    # There is a warning message with the vector selection - look into this
    suppressMessages(
      make_barplot(user_data, classification = args$level)
    )
  } else if (args$plot == "v-stacked") {
    suppressMessages(
      make_stacked_barplot(user_data, classification = args$level)
    )
  } else if (args$plot == "h-stacked") {
    suppressMessages(
      make_horizontal_stacked_barplot(user_data, classification = args$level)
    )
  } else {
    message("[!!] Unknown plot type - check docs")
    message("> Exiting")
    quit()
  }
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("> Done")
}
