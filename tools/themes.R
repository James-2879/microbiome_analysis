library(tidyverse)

theme_blank_with_legend = list(
  theme(
    panel.border = element_blank(),
    axis.line = element_line(color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.background = element_blank(),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    strip.text.x = element_text(size = 12),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.position = "top",
    legend.direction = "horizontal"
  )
)

theme_grids_with_legend = list(
  theme(
    panel.grid = element_line(color = rgb(0, 0, 0, 66, maxColorValue = 255)),
    axis.line = element_line(color = "black"),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    strip.text.x = element_text(size = 12),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.position = "top"
  )
)

theme_blank_with_legend_large = list(
  theme(
    panel.border = element_blank(),
    axis.line = element_line(color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.background = element_blank(),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 16),
    strip.text.x = element_text(size = 16),
    legend.text = element_text(size = 18),
    legend.title = element_text(size = 16),
    legend.position = "top",
    legend.direction = "horizontal"
  )
)

theme_grids_with_legend_large = list(
  theme(
    panel.grid = element_line(color = rgb(0, 0, 0, 66, maxColorValue = 255)),
    axis.line = element_line(color = "black"),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 16),
    strip.text.x = element_text(size = 16),
    legend.text = element_text(size = 18),
    legend.title = element_text(size = 16),
    legend.position = "top"
  )
)