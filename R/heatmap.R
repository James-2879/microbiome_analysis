suppressPackageStartupMessages({
  library(argparse)
  library(ComplexHeatmap)
  library(circlize)
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
parser$add_argument("-c", "--clustering",
                    type = "character",
                    default = "FALSE",
                    help = "use clustering and dendrograms")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
args <- parser$parse_args()


make_heatmap <- function(data) {
  #' Create a heatmap of species abundance across sources.
  #' 
  #' Makes a clean heatmap but does not include clustering or dendrograms.
  #' Use 'make_clustered_heatmap()' for these functions.
  #' 
  #' @param data data frame
  #' @returns ggplot object (CLI will save plot as image)
  
  summary_data <- data %>%
    group_by(source, species) %>%
    summarize(
      mean_abundance = mean(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = source,
                         y = species,
                         fill = mean_abundance,
    )
    ) +
    geom_tile() +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    labs(title = "Heatmap Representation of Microbial Abundance Levels across Different Samples",
         x = "Sample",
         y = "Species")
  return(plot)
}

make_clustered_heatmap <- function(data) {
  #' Create a heatmap of species abundance across sources.
  #' 
  #' Less clean than ggplot heatmap, but includes clustering and dendrograms
  #'  for both samples (source) and species. Use 'make_heatmap()' for a simpler
  #'  but cleaner-looking heatmap.
  #' 
  #' @param data data frame
  #' @returns large HeatmapList (CLI will save plot as image)
  
  summary_data <<- data %>%
    group_by(source, species) %>%
    summarize(
      mean_abundance = mean(abundance)
    ) %>%
    ungroup() %>% 
    select(c(source, species, mean_abundance)) %>%
    pivot_wider(names_from = species, values_from = mean_abundance) %>%
    column_to_rownames(var = "source") %>% 
    replace(is.na(.), 0) %>% 
    as.matrix() %>% 
    t()
  
  # Scale data between -1 and 1
  mat <- t(scale(t(summary_data)))
  # Set colors
  col_rnorm = colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))
  
  # Create heatmap object
  plot <- Heatmap(mat,
                  show_column_names = TRUE,
                  row_title = "Species",
                  col = col_rnorm, # Apply colors set above
                  column_title = "Sample",
                  heatmap_legend_param = list(
                    title = "Heatmap Representation of Microbial Abundance Levels across Different Samples",
                    legend_direction = "horizontal",
                    legend_width = unit(6, "cm")))
  
  plot <- draw(plot, heatmap_legend_side = "top",
               padding = unit(c(2, 2, 2, 2), "cm"))
  return(plot)
}

if (!interactive() && !knitr::is_html_output()) {
  
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
  jpeg(paste0(args$output, "heatmap.jpeg"), height = 4500, width = 6000, res = 300)
  if (args$clustering) {
    make_clustered_heatmap(data = user_data)
  } else {
    make_heatmap(data = user_data)
  }
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("[COMPLETE]")
}

