
summary_data <- long %>%
  filter(location == "OW") %>% 
  group_by(day, type, organism) %>% # remove the filter var from grouping
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

plot
