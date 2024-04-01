library(tidyverse)

make_density_plot <- function(data, limits = c(0, 0.05)) {
density_plot <- data %>% 
  ggplot(mapping = aes(x = abundance,
                       color = `repeat`)) +
  geom_density() +
  scale_y_continuous(limits = limits) +
  theme_minimal() +
  list(theme(panel.grid.major.x = element_blank(),
             panel.grid.minor.x = element_blank(),
             panel.grid.minor.y = element_blank())) +
  labs(title = "Abundance density across samples")

return(density_plot)
}
