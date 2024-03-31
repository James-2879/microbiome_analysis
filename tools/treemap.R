library(treemapify)
library(viridis)

make_treemap <- function(data, classification, max) {
  
  grouped_abundance <<- data %>% 
    select(classification, abundance) %>% 
    rename("organism" = classification) %>% 
    group_by(organism) %>% 
    summarise("abundance" = sum(abundance)) %>% 
    filter(!is.na(organism) & !is.na(abundance)) %>% 
    slice_head(n = max)
  
  treemap <<- grouped_abundance %>% 
    ggplot(mapping = aes(area = abundance,
                         fill = organism,
                         label = organism)) +
    geom_treemap() +
    geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                      grow = TRUE) +
    scale_fill_viridis(discrete = TRUE, option = "A")
  
  return(treemap)
  
}

make_dual_treemap <- function(data, classification1, classification2, max) {
  
  grouped_abundance <<- data %>%
    select(classification1, classification2, abundance) %>%
    rename("parent" = classification1,
           "child" = classification2) %>% 
    group_by(parent, child) %>%
    summarise("abundance" = sum(abundance)) %>%
    arrange(desc(abundance)) %>%
    ungroup() %>%
    filter(!is.na(parent) & !is.na(child) & !is.na(abundance)) %>% 
    slice_head(n = max)
  
  treemap <- grouped_abundance %>%
    ggplot(mapping = aes(area = abundance,
                         fill = parent,
                         label = child,
                         subgroup = parent,
                         border.col = "white",
                         border.lw = 1)) +
    geom_treemap() +
    geom_treemap_subgroup_border(color = "white", size = 3) +
    # geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 1, colour =
    #                              "white", fontface = "italic", min.size = 0) +
    geom_treemap_text(colour = "white", place = "centre", reflow = T, alpha = 1,
                      fontface = "italic") +
    scale_fill_viridis(discrete = TRUE, option = "D")
  
  return(treemap)
}
