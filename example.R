if (interactive()) {
  script_dir <- "/home/james/Documents/microbiome_analysis/"
  setwd(script_dir)
}

source("R/data.R")
source("R/themes.R")
source("R/controls.R")
source("R/treemap.R")
source("R/density.R")
source("R/barplot.R")
source("R/pcoa.R")
source("R/heatmap.R")
source("R/co_network.R")
source('R/updated_controls.R')

library(tidyverse)


# Don't execute if running from command line
if (interactive()) {
  # load_data(path = script_dir)
}


if (interactive()) {

  # Controls -------------------------------------------------------------------
  # Evaluate abundance assays against controls

  plot_updated_controls(samples = final_samples_subset)
  best <- analyse_processing_configs(samples = final_samples, best_method = FALSE)
  
  user_data <- load_user_data_dir("/home/james/Documents/microbiome_analysis/data/input/luke/")
  check_data(user_data)
  
  pcoa <- do_pcoa(user_data, zero_missing = TRUE)
  pcoa
  
  density <- make_density_plot(user_data)
  density
  
  treemap <- make_treemap(user_data, max = 10)
  treemap
  
  heatmap <- make_heatmap(user_data)
  heatmap
  
  clustered_heatmap <- make_clustered_heatmap(user_data)
  clustered_heatmap
  
  barplot_a <- make_barplot(user_data, max = 6, orientation = "horizontal")
  barplot_a
  
  barplot_b <- make_stacked_barplot(user_data, orientation = "vertical", max = 10)
  barplot_b
  physeq_object <- create_physeq_object(data = user_data)

  create_network_phyloseq(physeq_object = physeq_object,
                 taxonomic_level = "species",
                 max_dist = 0.5)

}
