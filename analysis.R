if (interactive()) {
  script_dir <- "/home/james/Documents/microbiome_analysis/"
  setwd(script_dir)
}

source("tools/data.R")
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

# sort out eukaryote classifications - try to use phyloseq for this
# silva database 138.1
# ignore substrains
# how do we deal with entries are missing genus or species -- do we ignore them

# Don't execute if running from command line
if (interactive()) {
  load_data(path = script_dir)
}

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
  
  # Barplot -------------------------------------------------------------------
  # May not work until day, location, type exist in data etc.
  
  try({
    make_barplot(all_samples, classification = "order")
    make_stacked_barplot(all_samples, classification = "order")
    make_horizontal_stacked_barplot(all_samples, classification = "order")
    make_compressed_stacked_barplot(all_samples, classification = "order")
  })
  
  # Heatmap -------------------------------------------------------------------
  # May not work until day, location, type exist in data etc.
  try({
    make_heatmap(all_samples, classification = "order")
    make_univar_heatmap(all_samples, classification = "order")
    make_multivar_heatmap(all_samples, classification = "order")
  })
  
  # Density --------------------------------------------------------------------
  # Evaluate abundance density similarity across samples/repeats
  
  make_density_plot(data = all_samples,
                    limits = c(0, 0.0005))
  
  # PCoA -----------------------------------------------------------------------
  # Evaluate beta-diversity

  test_microbiome_2 <- test_microbiome %>% 
    mutate("repeat" = "4") %>% 
    rename("Taxa" = taxonomy) %>% 
    mutate("day" = "default") %>% 
    mutate("location" = "default") %>% 
    mutate("type" = "default")
  
  reference_abundances_2 <- reference_abundances %>% 
    mutate("repeat" = "5") %>% 
    mutate("day" = "default") %>% 
    mutate("location" = "default") %>% 
    mutate("type" = "default") %>% 
    mutate("abundance" = abundance*505)
  
  all_samples_with_test <- bind_rows(all_samples, test_microbiome_2)
  all_samples_with_reference <- bind_rows(all_samples, reference_abundances_2)
    
  do_pcoa(data = all_samples_with_test)
  
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
  
  physeq_object <- create_physeq_object(data = all_samples)
  
  create_network_phyloseq(physeq_object = physeq_object,
                 taxonomic_level = "genus",
                 max_dist = 1)
  
  create_network_meco(physeq_object = physeq_object,
                      plot_method = "physeq")
  
}

