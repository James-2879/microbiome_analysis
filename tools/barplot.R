
make_barplot <- function(data) {
  # data should be long
  summary_data <- data %>%
    filter(location == "OW") %>% 
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

make_stacked_barplot <- function(data) {
  # data should be long
  summary_data <- data %>%
    # filter(location == "OW") %>% 
    filter(type == "CTRL") %>% 
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