library(ggplot2)

data <- data.frame(
  groups = c("Group 1", "Group 2", "Group 3", "Group 4", "Group 5", "Group 6", "Group 7"),
  cond_1_lfc = c(1.5, 2.0, 1.2, 4, 6, 3.2, 3.4),
  cond_2_lfc = c(1.0, 1.8, 1.5, 6.2, 1, 2.5, 4)
)

data_long <- data %>% 
  pivot_longer(cols = 2:3, names_to = "variable")

# Create the plot
ggplot(data_long, aes(y = groups, x = ifelse(variable == "cond_2_lfc", value, -value), fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.5) +
  facet_wrap(~ variable, scales = "free_x", nrow = 1) +
  labs(x = "Log Fold Change", y = "Groups", fill = "") +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        strip.background = element_blank(),
        strip.text = element_blank()) +
theme(panel.spacing = unit(-1.9, "lines"))