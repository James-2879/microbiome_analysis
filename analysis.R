script_dir <- "/home/james/Documents/microbiome_analysis/"
setwd(script_dir)

source("tools/clean.R")
source("tools/barplot.R")
source("tools/pcoa.R")
source("tools/heatmap.R")
source("tools/co_network.R")
source("tools/cross_feeding_network.R")

library(tidyverse)
library(viridis) # Color blind palettes

data <- clean_data(type = "long")

# Example functions ------------------------------------------------------------
make_barplot(data)
make_stacked_barplot(data)
make_horizontal_stacked_barplot(data)
make_compressed_stacked_barplot(data)

make_heatmap(data)
make_univar_heatmap(data)
make_multivar_heatmap(data)

do_pcoa(data)

# Notes ------------------------------------------------------------------------
# TODO Density plot to show distribution of abundance
# TODO Plot to analyze normalization
# TODO Phylogram of the bacteria species for ordering the bar plot
# TODO Plot to show change in abundance
#       I think LFC using DESeq2 might be a good idea
#       Volcano plot

# Probably phyloseq for network analysis

## Diss notes ----
# Start looking into microbial based papers
# Make sure more microbiology and biochem oriented vs bfx
# Critical evaluation of plots

# Analysis Start ---------------------------------------------------------------

# Manufacturer relative abundance references
reference_table <- read_csv("data/input/control_reference_table.txt") %>% 
  mutate(genus = str_split_i(scientific_name, " ", 1)) %>% 
  mutate(species = str_split_i(scientific_name, " ", 2))

# Tidy relative abundances from controls
control <- read_tsv("data/input/test_microbiome.tsv") %>% 
  filter(taxonomy != "Unassigned") %>% 
  mutate("genus" = str_split_i(taxonomy, ";", -2)) %>% 
  mutate("species" = str_split_i(taxonomy, ";", -1)) %>% 
  mutate(species = tolower(species)) %>% 
  filter(!is.na(genus)) %>% 
  filter(!is.na(species)) %>% 
  filter(genus != species) %>% 
  mutate(scientific_name = paste(genus, species)) %>% 
  filter(genus %in% reference_table$genus)

# Sum abundance by genus
grouped_control <- control %>% 
  group_by(genus) %>% 
  summarise("ctrl1_abundance" = sum(abundance))

# Convert abundance to a percentage
grouped_control_percentage <- grouped_control %>% 
  mutate(ctrl1_abundance = (ctrl1_abundance/sum(grouped_control$ctrl1_abundance))*100)

# Wrangle for use in next code block
selected_references <- reference_table %>% 
  select(genus, abundance) %>% 
  rename("ref_abundance" = abundance)
  
# Merge controls with references
controls_references <- grouped_control_percentage %>% 
  left_join(selected_references, by = "genus",) %>% # change full vs left
  pivot_longer(cols = c(ctrl1_abundance, ref_abundance), names_to = "group", values_to = "percent_abundance") %>% 
  mutate(percent_abundance = if_else(is.na(percent_abundance), 0, percent_abundance))

# Plot controls against abundances
plot <- controls_references %>% 
  mutate(group = if_else(group == "ctrl1_abundance", "Control", group)) %>% 
  mutate(group = if_else(group == "ref_abundance", "Reference", group)) %>% 
  ggplot(mapping = aes(x = group,
                       y = percent_abundance,
                       fill = genus
  )
  ) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_viridis_d() + # Add in colorblind palette
  labs(title = "Control genera abundances versus references",
       subtitle = "Abundance of each genus as a fraction of total abundance",
       x = "Data source",
       y = "Fractional abundance") +
  theme_minimal() # Remove background
plot
















