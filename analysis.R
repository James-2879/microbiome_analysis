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
source('tools/updated_controls.R')

library(tidyverse)


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
  
  # Heatmap -------------------------------------------------------------------
  # May not work until day, location, type exist in data etc.
  try({
    make_heatmap(all_samples, classification = "order")
    make_univar_heatmap(all_samples, classification = "order")
    make_multivar_heatmap(all_samples, classification = "order")
  })
  
  # Density --------------------------------------------------------------------
  # Evaluate abundance density similarity across samples/repeats
  
  library(plotly)
  
  density_final_samples <- final_samples %>% 
    rename("scientific_name" = "species") %>% 
    rename("repeat" = "sample") %>%
    unite("type", 5:9, sep = "_") %>% 
    mutate("day" = "default") %>% 
    mutate("location" = "default")
  
  density_zymo <- zymo_standard %>% 
    rename("scientific_name" = "species") %>% 
    rename("repeat" = "sample") %>%
    mutate("day" = "default") %>% 
    mutate("location" = "default") %>% 
    mutate('type' = "default")
  
  density_both <- bind_rows(density_final_samples, density_zymo)
  
  make_density_plot(data = density_both,
                    limits = c(0, 0.001))
  
  plotly <- ggplotly(plot)
  plotly
  
  # PCoA -----------------------------------------------------------------------
  # Evaluate beta-diversity
    
  pcoa_final_samples <- final_samples %>% 
    rename("scientific_name" = "species") %>% 
    rename("repeat" = "sample") %>% 
    unite("type", 5:9, sep = "_") %>% 
    mutate("day" = "default") %>% 
    mutate("location" = "default")
  
  do_pcoa(data = pcoa_final_samples)
  
  
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


# final_samples <- final_samples %>%a
#   mutate(source = sub("\\.tsv$", "", source)) %>%
#   separate(source, into = c("sample", "minimap_thresh", "samtools_score", "qiime_thresh", "kk_overlap", "kk_min_conf"), sep = "_")

# write_tsv(final_samples, "~/Documents/microbiome_analysis/data/input/final_samples.tsv")


