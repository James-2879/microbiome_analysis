suppressPackageStartupMessages({
  library(treemapify)
  library(viridis)
})

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-d", "--data",
                    type = "character",
                    default = NULL,
                    help = "full path to directory containing .tsv files")
parser$add_argument("-m", "--max",
                    type = "character",
                    default = "10",
                    help = "max number of species to plot")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
args <- parser$parse_args()

make_treemap <- function(data, max) {
  #' Make a tree map to show most abundant species.
  #' 
  #' Samples are grouped (if applicable) to show top mean abundances.
  #' 
  #' @param data data frame
  #' @param max integer (takes top n species)
  #' @returns ggplot object (CLI will save plot as image)
  
  grouped_abundance <<- data %>% 
    select(species, abundance) %>% 
    group_by(species) %>% 
    summarise("abundance" = sum(abundance)) %>% 
    filter(!is.na(species) & !is.na(abundance)) %>% 
    arrange(desc(abundance)) %>% 
    slice_head(n = max)
  
  treemap <<- grouped_abundance %>% 
    ggplot(mapping = aes(area = abundance,
                         fill = species,
                         label = species)) +
    geom_treemap() +
    geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                      grow = TRUE) +
    scale_fill_viridis(discrete = TRUE, option = "A")
  
  return(treemap)
}

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
  user_data <- load_user_data_dir(args$data)
  check_data(user_data)
  
  # Make and save the plot
  message("> Generating plot")
  jpeg(args$output, height = 2160, width = 3840, res = 300)
  make_treemap(data = user_data, max = args$max)
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("> Done")
}


