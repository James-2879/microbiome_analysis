library(tidyverse)
library(viridis)

plot_controls <- function() {

# TODO Order the blocks such that they are in height order

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

return(plot)
}