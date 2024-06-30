if (interactive()) {
  
  # Example usage ----
  
  library(tidyverse)
  
  # Construct directory ----
  
  home_dir <- Sys.getenv("HOME")
  package_dir <- file.path(home_dir, "Documents", "microbiome_analysis")
  
  # Source required scripts ----
  
  source(file.path(package_dir, "R", "data.R"))
  source(file.path(package_dir, "R", "themes.R"))
  source(file.path(package_dir, "R", "controls.R"))
  source(file.path(package_dir, "R", "treemap.R"))
  source(file.path(package_dir, "R", "density.R"))
  source(file.path(package_dir, "R", "barplot.R"))
  source(file.path(package_dir, "R", "pcoa.R"))
  source(file.path(package_dir, "R", "heatmap.R"))
  source(file.path(package_dir, "R", "co_network.R"))
  
  # Load documentation ----
  
  # Only if not installed as package
  library("roxygen2")
  roxygen2::roxygenise(package.dir = package_dir)
  
  # Load data ----
  
  # Single directory example
  user_data <- load_user_data_dir(file.path(package_dir, "data", "input", "a/"))
  # Multi directory example (randomly mutates data for variation)
  user_data <- load_user_data_dir(c(file.path(package_dir, "data", "input", "a/"),
                                    file.path(package_dir, "data", "input", "b/"),
                                    file.path(package_dir, "data", "input", "c/"))) %>%
    mutate(abundance = if_else(source == "b", abundance + runif(1, 100, 10000), abundance)) %>%
    mutate(abundance = if_else(source == "c", abundance + runif(1, 100, 10000), abundance))
  # Check loaded data
  check_data(user_data)
  
  # Example functions ----
  
  ## Controls ----
  plot_controls(user_data)
  best <- analyze_processing_configs(user_data, best_method = TRUE)
  analyze_processing_configs(user_data, best_method = FALSE)
  
  ## PCoA ----
  pcoa <- do_pcoa(user_data, zero_missing = TRUE)
  pcoa
  
  ## Density ----
  density <- make_density_plot(user_data)
  density
  
  ## Tree map ----
  treemap <- make_treemap(user_data, max = 10)
  treemap
  
  ## Heat maps ----
  heatmap <- make_heatmap(user_data)
  heatmap
  
  clustered_heatmap <- make_clustered_heatmap(user_data)
  clustered_heatmap
  
  ## Bar plots ----
  barplot_a <- make_barplot(user_data, max = 6, orientation = "horizontal")
  barplot_a
  
  barplot_b <- make_stacked_barplot(user_data, orientation = "vertical", max = 10)
  barplot_b
  
  ## Network ----
  physeq_object <- create_physeq_object(data = user_data)
  
  network <- create_network_phyloseq(physeq_object = physeq_object,
                                     distance_method = "bray",
                                     max_dist = 0.5)
  network
  
} else if (!interactive()) {
  message("[!!] This script is not meant to be executed, it is only to be used as an example.")
}
