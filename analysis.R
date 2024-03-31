script_dir <- "/home/james/Documents/microbiome_analysis/"
setwd(script_dir)

source("tools/controls.R")
source("tools/treemap.R")
source("tools/barplot.R")
source("tools/pcoa.R")
source("tools/heatmap.R")
source("tools/co_network.R")
source("tools/cross_feeding_network.R")

library(tidyverse)

# Data -------------------------------------------------------------------------

test_microbiome <- read_tsv("data/input/test_microbiome.tsv") %>% 
  mutate("domain" = str_split_i(taxonomy, ";", -8)) %>% 
  mutate("kingdom" = str_split_i(taxonomy, ";", -7)) %>% 
  mutate("phylum" = str_split_i(taxonomy, ";", -6)) %>% 
  mutate("class" = str_split_i(taxonomy, ";", -5)) %>% 
  mutate("order" = str_split_i(taxonomy, ";", -4)) %>% 
  mutate("family" = str_split_i(taxonomy, ";", -3)) %>% 
  mutate("genus" = str_split_i(taxonomy, ";", -2)) %>% 
  mutate("species" = str_split_i(taxonomy, ";", -1)) %>% 
  mutate(species = tolower(species)) %>% 
  mutate(scientific_name = paste(genus, species))
reference_abundances <- read_tsv("data/input/control_reference_table.txt")

sample_1 <- read_tsv("data/input/sample_1.tsv") %>%
  mutate("repeat" = "1")
sample_2 <- read_tsv("data/input/sample_2.tsv") %>%
  mutate("repeat" = "2")
sample_3 <- read_tsv("data/input/sample_3.tsv") %>%
  mutate("repeat" = "3")

# currently this data is not good enough to group by genus or species
all_samples <- bind_rows(sample_1, sample_2, sample_3) %>%
  mutate("domain" = str_split_i(Taxa, ";", -8)) %>%
  mutate("kingdom" = str_split_i(Taxa, ";", -7)) %>%
  mutate("phylum" = str_split_i(Taxa, ";", -6)) %>%
  mutate("class" = str_split_i(Taxa, ";", -5)) %>%
  mutate("order" = str_split_i(Taxa, ";", -4)) %>%
  mutate("family" = str_split_i(Taxa, ";", -3)) %>%
  mutate("genus" = str_split_i(Taxa, ";", -2)) %>%
  mutate("species" = str_split_i(Taxa, ";", -1)) %>%
  mutate(species = tolower(species)) %>%
  mutate(scientific_name = paste(genus, species)) %>%
  mutate("day" = "default") %>%
  mutate("location" = "default") %>%
  mutate("type" = "default")

# https://journals.asm.org/doi/10.1128/msystems.00166-16

pcoa_plot <- do_pcoa(data = all_samples, classification = "order")
pcoa_plot


# Example functions ------------------------------------------------------------

make_barplot(test_data)
make_stacked_barplot(test_data)
make_horizontal_stacked_barplot(test_data)
make_compressed_stacked_barplot(test_data)

make_heatmap(test_data)
make_univar_heatmap(test_data)
make_multivar_heatmap(test_data)

# do_pcoa(test_data)

# Notes ------------------------------------------------------------------------

# TODO Density plot to show distribution of abundance
# TODO Plot to analyze normalization
# TODO Phylogram of the bacteria species for ordering the bar plot
# TODO Plot to show change in abundance
#       I think LFC using DESeq2 might be a good idea
#       Volcano plot
# TODO look at the co-occurence network stuff 

# Probably phyloseq for network analysis

# Controls --------------------------------------------------------------------

plot_controls()

# PCoA -------------------------------------------------------------------------



# Tree map ---------------------------------------------------------------------

make_treemap(data = test_microbiome,
             classification = "family",
             max = 10)

make_dual_treemap(data = test_microbiome,
             classification1 = "order",
             classification2 = "family",
             max = 10)




