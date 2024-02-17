make_heatmap <- function(data) {
  # data should be long
  summary_data <- data %>%
    filter(type == "INF") %>%
    group_by(day, type, location, organism) %>%
    summarize(
      mean_abundance = mean(abundance),
      min_abundance = min(abundance),
      max_abundance = max(abundance)
    )
  
  plot <- summary_data %>% 
    ggplot(mapping = aes(x = `day`,
                         y = organism,
                         fill = mean_abundance,
    )
    ) +
    geom_tile() +
    facet_grid(rows = vars(`location`))
  return(plot)
}
