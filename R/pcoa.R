suppressPackageStartupMessages({
  library(vegan)
  library(tidyverse)
  library(argparse)
  library(ggrepel)
})

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-w", "--utility_directory",
                    type = "character",
                    default = NULL,
                    help = "full path to location of utility directory")
parser$add_argument("-d", "--data",
                    type = "character",
                    default = NULL,
                    help = "full path to directory containing .tsv files")
parser$add_argument("-z", "--zero",
                    action = "store_true",
                    default = NULL,
                    help = "replace NA values with zeros")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
args <- parser$parse_args()

do_pcoa <- function(data, zero_missing = TRUE) {
  #' Run PCoA analysis on data set.
  #' 
  #' Creates a data frame of abundances for each sample against each species (mean),
  #'  before multidimensional scaling. If a sample is missing abundances for a given
  #'  species, the sample can either be removed (zero_missing = FALSE), or the specific
  #'  entry can be set to zero (zero_missing = TRUE).
  #'  
  #' Removing samples is likely to be more destructive, particularly for lower quality data,
  #'  and removing too many samples will reduce statistical weight. 
  #' 
  #' @param data data frame
  #' @param zero_missing TRUE/FALSE
  #' @returns list which can be called to display the plot (CLI will save plot as image)
  
  # Summarise data set
  pcoa_data <- data %>% 
    select(c(species, abundance, source)) %>% 
    group_by(source, species) %>%
    suppressMessages(summarise(abundance = mean(abundance, na.rm = TRUE))) %>%
    filter(!is.na(abundance)) %>%
    pivot_wider(names_from = species, values_from = abundance)
  if (zero_missing) {
    message('[**] Any missing values for species will be replaced with zeros.')
    pcoa_data <- pcoa_data %>% 
      replace(is.na(.), 0) %>% 
      ungroup()
  } else {
    message('[!!] Any species not present in all samples will be excluded, 
            this may significantly reduce number of species for PCoA.')
    pcoa_data <- pcoa_data %>% 
      select_if(~all(complete.cases(.))) %>%
      ungroup()
  }
  
  # Add sample IDs to join annotations back on later
  pcoa_data <- pcoa_data %>% 
    mutate("sample_id" = paste0("sample_", seq(1, dim(pcoa_data)[1]))) %>% 
    mutate("sample_id_copy" = sample_id) %>% 
    column_to_rownames(var = "sample_id") %>% 
    rename("sample_id" = "sample_id_copy") %>% 
    select(sample_id, everything())
  
  # Calculate distances using Bray-Curtis method
  ab.dist <- vegdist(pcoa_data[, 3:ncol(pcoa_data)], method="bray", diag=FALSE, upper=FALSE)
  
  # Perform multidimensional scaling
  pcoa_result <<- cmdscale(ab.dist, k = 2)
  
  # Rename PCoA columns
  pcoa_df <<- as.data.frame(pcoa_result) %>% 
    rownames_to_column(var = "sample_id") %>% 
    rename("PCoA1" = "V1",
           "PCoA2" = "V2") %>% 
    left_join(pcoa_data[, 1:2], by = "sample_id")
  
  # Plot the scaled distances
  pcoa_plot <- ggplot(pcoa_df,
                      mapping = aes(x = PCoA1,
                                    y = PCoA2,
                                    color = `source`
                      )) +
    geom_point() +
    theme(panel.grid.major = element_blank()) +
    theme(panel.grid.minor = element_blank()) +
    theme(panel.background = element_blank())
  pcoa_plot
  
  return(pcoa_plot)
}

# https://journals.asm.org/doi/10.1128/msystems.00166-16

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
  jpeg(paste0(args$output, "pcoa.jpeg"), height = 2160, width = 3840, res = 300)
    do_pcoa(data = user_data, zero_missing = args$zero)
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("[COMPLETE]")
}


