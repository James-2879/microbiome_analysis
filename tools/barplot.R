library(forcats)
library(tidyverse)

make_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = classification) %>% 
    # filter(location == "OW") %>%
    group_by(day, type, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = day,
                         y = mean_abundance,
                         fill = type
    )
    ) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_errorbar(aes(ymin = min_abundance, ymax = max_abundance),
                  width = 0.2,
                  position = position_dodge(width = 0.9)) +
    facet_wrap("organism")
  return(plot)
  
}

make_stacked_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = classification) %>% 
    # filter(location == "OW") %>% 
    # filter(type == "CTRL") %>% 
    group_by(day, type, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = day,
                         y = mean_abundance,
                         fill = organism
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    facet_wrap("location")
  return(plot)
  
}

make_horizontal_stacked_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = classification) %>% 
    # filter(location == "OW") %>% 
    # filter(type == "INF") %>% 
    group_by(day, type, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = mean_abundance,
                         y = location,
                         fill = organism
    )
    ) +
    geom_bar(stat = "identity", position = "fill") +
    facet_grid(c("day", "type"))
  return(plot)
  
}

make_compressed_stacked_barplot <- function(data, classification) {
  # data should be long
  summary_data <- data %>%
    rename("organism" = classification) %>% 
    # filter(location == "OW") %>% 
    # filter(type == "INF") %>% 
    group_by(day, type, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    ) %>% 
    ungroup() %>%
    arrange(day, location, type, ) %>%
    unite("annotation", c(day, location, type), sep = "-")
  
  # Pull numbers from annotation to order by numerically
  numeric_part <- as.numeric(gsub("[^0-9]", "", summary_data$annotation))
  
  # Reorder the factor levels based on the numeric part
  summary_data$annotation <- fct_reorder(summary_data$annotation, numeric_part)
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = mean_abundance,
                         y = annotation,
                         fill = organism
    )
    ) +
    geom_bar(stat = "identity", position = "fill")
  return(plot)
}
