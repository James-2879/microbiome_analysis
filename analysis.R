if (interactive()) {
  script_dir <- "/home/james/Documents/microbiome_analysis/"
  setwd(script_dir)
}

source("tools/themes.R")
source("tools/controls.R")
source("tools/treemap.R")
source("tools/density.R")
source("tools/barplot.R")
source("tools/pcoa.R")
source("tools/heatmap.R")
source("tools/co_network.R")
source("tools/cross_feeding_network.R")

library(tidyverse)

# Don't execute if running from command line
if (interactive()) {
  source("tools/data.R")
  load_data()
}

# Example functions ------------------------------------------------------------

# Will not work until day, location, type exist in data etc,
# make_barplot(test_microbiome)
# make_stacked_barplot(test_microbiome)
# make_horizontal_stacked_barplot(test_microbiome)
# make_compressed_stacked_barplot(test_microbiome)
# make_heatmap(test_microbiome)
# make_univar_heatmap(test_microbiome)
# make_multivar_heatmap(test_microbiome)

# Notes ------------------------------------------------------------------------

# TODO Plot to analyze normalization
# TODO Phylogram of the bacteria species for ordering the bar plot
# TODO Plot to show change in abundance
#     I think LFC using DESeq2 might be a good idea
#     Volcano plot

if (interactive()) {
  
  # Controls -------------------------------------------------------------------
  # Evaluate abundance assays against controls
  
  plot_controls()
  
  # Density --------------------------------------------------------------------
  # Evaluate abundance density similarity across samples/repeats
  
  make_density_plot(data = all_samples,
                    limits = c(0, 0.0005))
  
  # PCoA -----------------------------------------------------------------------
  # Evaluate beta-diversity
  
  do_pcoa(data = all_samples, 
          classification = "phylum")
  
  
  # Tree map -------------------------------------------------------------------
  # Evaluate alpha-diversity
  
  make_treemap(data = test_microbiome,
               classification = "family",
               max = 10)
  
  make_dual_treemap(data = test_microbiome,
                    classification1 = "order",
                    classification2 = "family",
                    max = 10)
  
  # Network --------------------------------------------------------------------
  # Identify clusters of linked abundances
  
  create_network(data = all_samples,
                 taxonomic_level = "genus",
                 max_dist = 1)
  
}

# jpeg("treemap.jpeg", height = 2160, width = 3840, res = 300)
# plot
# dev.off()

