library(treemapify)
library(viridis)

make_treemap <- function(data, classification) {
  
  grouped_abundance <<- data %>% 
    select(classification, abundance) %>% 
    rename("organism" = classification) %>% 
    group_by(organism) %>% 
    summarise("abundance" = sum(abundance)) %>% 
    slice_head(n = 10)
  
  treemap <<- grouped_abundance %>% 
    filter(organism != "Prevotella") %>% 
    ggplot(mapping = aes(area = abundance,
                         fill = organism,
                         label = organism)) +
    geom_treemap() +
    geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                      grow = TRUE) +
    scale_fill_viridis(discrete = TRUE, option = "A")
  
  return(treemap)
  
  # genus_species_abundance <- data %>% 
  #   select(genus, species, abundance) %>% 
  #   group_by(genus, species) %>% 
  #   summarise("abundance" = sum(abundance)) %>% 
  #   arrange(desc(abundance)) %>% 
  #   ungroup() # %>% 
  # # slice_head(n = 10)
  # 
  # genus_species_treemap <- genus_species_abundance %>% 
  #   filter(species != "prevotella corporis") %>%
  #   ggplot(mapping = aes(area = abundance,
  #                        fill = genus,
  #                        label = species,
  #                        subgroup = genus,
  #                        border.col = "white",
  #                        border.lw = 1)) +
  #   geom_treemap() +
  #   geom_treemap_subgroup_border(color = "white", size = 3) +
  #   # geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 1, colour =
  #   #                              "white", fontface = "italic", min.size = 0) +
  #   geom_treemap_text(colour = "white", place = "centre", reflow = T, alpha = 1,
  #                     fontface = "italic") +
  #   scale_fill_viridis(discrete = TRUE, option = "D")
  # genus_species_treemap
}
