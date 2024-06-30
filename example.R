if (interactive()) {
  
  library(tidyverse)
  
  # Construct directory ----
  
  home_dir <- Sys.getenv("HOME")
  script_dir <- file.path(home_dir, "Documents", "microbiome_analysis")
  
  # Source required scripts ----
  
  source(file.path(script_dir, "R", "data.R"))
  source(file.path(script_dir, "R", "themes.R"))
  source(file.path(script_dir, "R", "controls.R"))
  source(file.path(script_dir, "R", "treemap.R"))
  source(file.path(script_dir, "R", "density.R"))
  source(file.path(script_dir, "R", "barplot.R"))
  source(file.path(script_dir, "R", "pcoa.R"))
  source(file.path(script_dir, "R", "heatmap.R"))
  source(file.path(script_dir, "R", "co_network.R"))
  
  
  
  
  library("roxygen2")
  roxygen2::roxygenise(package.dir = "/home/james/Documents/microbiome_analysis/")
  
  
  user_data <- load_user_data_dir("/home/james/Documents/microbiome_analysis/data/input/luke/")
  # user_data <- load_user_data_dir(c("/home/james/Documents/microbiome_analysis/data/input/luke/",
  #                                   "/home/james/Documents/microbiome_analysis/data/input/luke_copy/",
  #                                   "/home/james/Documents/microbiome_analysis/data/input/luke_copy2/")) %>%
  #   mutate(abundance = if_else(source == "luke_copy", abundance + runif(1, 100, 10000), abundance)) %>% 
  #   mutate(abundance = if_else(source == "luke_copy2", abundance + runif(1, 100, 10000), abundance))
  
  check_data(user_data)
  
  plot_controls(user_data)
  best <- analyse_processing_configs(user_data, best_method = TRUE)
  analyse_processing_configs(user_data, best_method = FALSE)
  
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
  
  network <- create_network_phyloseq(physeq_object = physeq_object,
                                     distance_method = "bray",
                                     max_dist = 0.5)
  network
  
}
