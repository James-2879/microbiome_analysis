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

test_data <- clean_data(type = "long")

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

## Diss notes ----
# Start looking into microbial based papers
# Make sure more microbiology and biochem oriented vs bfx
# Critical evaluation of plots

# Analysis Start ---------------------------------------------------------------

# TODO Try to mix up the color orders in palettes to make it more obvious

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
plot_data <- controls_references %>% 
  mutate(group = if_else(group == "ctrl1_abundance", "Control", group)) %>% 
  mutate(group = if_else(group == "ref_abundance", "Reference", group))

unique_levels <- plot_data$genus
set.seed(123)  # For reproducibility
custom_palette <- sample(viridis_pal(option = "A")(length(unique_levels)))

# Assign colors to factor levels
color_mapping <- setNames(custom_palette, unique_levels)

plot <- plot_data %>% 
  ggplot(mapping = aes(x = group,
                       y = percent_abundance,
                       fill = genus,
                       label = genus
  )
  ) +
  geom_bar(stat = "identity", position = "fill") +
  # geom_text(position = position_fill(vjust = 0.5)) +
  # scale_fill_viridis_d() + # Add in colorblind palette
  scale_fill_manual(values = color_mapping) +
  labs(title = "Control genera abundances versus references",
       subtitle = "Abundance of each genus as a fraction of total abundance",
       x = "Data source",
       y = "Fractional abundance") +
  theme_minimal() # Remove background
plot

# PCoA -------------------------------------------------------------------------



# Tree map ---------------------------------------------------------------------

library(treemapify)

genus_abundance <- control %>% 
  select(genus, abundance) %>% 
  group_by(genus) %>% 
  summarise("abundance" = sum(abundance))

genus_treemap <- genus_abundance %>% 
  filter(genus != "Prevotella") %>% 
  ggplot(mapping = aes(area = abundance,
                       fill = genus,
                       label = genus)) +
  geom_treemap() +
  geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                    grow = TRUE) +
  scale_fill_viridis(discrete = TRUE, option = "A")
genus_treemap

# species_abundance <- control %>% 
#   select(species, abundance) %>% 
#   group_by(species) %>% 
#   summarise("abundance" = sum(abundance))
# 
# species_treemap <- species_abundance %>% 
#   ggplot(mapping = aes(area = abundance,
#                        fill = species,
#                        label = species)) +
#   geom_treemap() +
#   geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
#                     grow = TRUE) +
#   scale_fill_viridis(discrete = TRUE, option = "A")
# species_treemap

genus_species_abundance <- control %>% 
  select(genus, species, abundance) %>% 
  group_by(genus, species) %>% 
  summarise("abundance" = sum(abundance)) %>% 
  arrange(desc(abundance)) %>% 
  ungroup() #%>% 
  # slice_head(n = 10)

genus_species_treemap <- genus_species_abundance %>% 
  filter(species != "prevotella corporis") %>%
  ggplot(mapping = aes(area = abundance,
                       fill = genus,
                       label = species,
                       subgroup = genus,
                       border.col = "white",
                       border.lw = 1)) +
  geom_treemap() +
  geom_treemap_subgroup_border(color = "white", size = 3) +
  # geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 1, colour =
  #                              "white", fontface = "italic", min.size = 0) +
  geom_treemap_text(colour = "white", place = "centre", reflow = T, alpha = 1,
                    fontface = "italic") +
  scale_fill_viridis(discrete = TRUE, option = "D")
genus_species_treemap






