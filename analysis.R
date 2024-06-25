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

  final_samples <- read_tsv("~/Documents/microbiome_analysis/data/input/final_samples.tsv")

  final_samples_subset <- final_samples
  plot_updated_controls(samples = final_samples_subset)
  best <- analyse_processing_configs(samples = final_samples, best_method = FALSE)

  # Barplot -------------------------------------------------------------------
  # May not work until day, location, type exist in data etc.

  try({
    make_barplot(all_samples, classification = "order")
    make_stacked_barplot(all_samples, classification = "order")
    make_horizontal_stacked_barplot(all_samples, classification = "order")
    make_compressed_stacked_barplot(all_samples, classification = "order")
  })


  
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
  
  # Network --------------------------------------------------------------------
  # Identify clusters of linked abundances

  network_final_samples <- final_samples %>%
    rename("scientific_name" = "species") %>%
    rename("repeat" = "sample") %>%
    unite("type", 5:9, sep = "_") %>%
    mutate("day" = "default") %>%
    mutate("location" = "default") %>%
    mutate(`repeat` = gsub("M", "", `repeat`)) %>%
    rename("Taxa" = "taxonomy")


  physeq_object <- create_physeq_object(data = network_final_samples)

  create_network_phyloseq(physeq_object = physeq_object,
                 taxonomic_level = "scientific_name",
                 max_dist = 1)

  create_network_meco(physeq_object = physeq_object,
                      plot_method = "physeq")

}
