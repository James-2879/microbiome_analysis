suppressPackageStartupMessages({
  library(argparse)
  library(tidyverse)
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
args <- parser$parse_args()

make_density_plot <- function(data) {
  #' Make density plot.
  #'
  #' Each file in directory (or each different source) plotted separately on
  #'  the same graph.
  #'  
  #'  @param data data frame
  #'  @returns ggplot object (CLI will save plot as image)
  
  density_plot <- data %>% 
    ggplot(mapping = aes(x = abundance,
                         color = source)) +
    geom_density() +
    theme_minimal() +
    list(theme(panel.grid.major.x = element_blank(),
               panel.grid.minor.x = element_blank(),
               panel.grid.minor.y = element_blank(),
               panel.grid.major.y = element_blank())) +
    labs(title = "Abundance density across samples")
  
  return(density_plot)
}

if (!interactive()) {
  
  setwd(toString(args$utility_directory))
  
  # Load required functions
  message("> Preparing session and data")
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
  message("> Generating plot")
  jpeg(paste0(args$output, "density.jpeg"), height = 2160, width = 3840, res = 300)
  make_density_plot(data = user_data)
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("[COMPLETE]")
}