library(ComplexHeatmap)
library(circlize)

make_heatmap <- function(data) {
  # Make a simple heatmap, dendrogram unavailable
  # Can plot one var pair in x/y, and another across facets
  # Use long data
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

make_univar_heatmap <- function(data) {
  # Uses filters to plot only a single variable against abundance
  # Take data as long and pivot to wide
  summary_data <- data %>%
    filter(location == "OW") %>%
    filter(type == "INF") %>%
    # filter(day == "D6") %>% 
    group_by(organism, day, location, type) %>%
    summarize(
      mean_abundance = mean(abundance)
    ) %>%
    ungroup() %>% 
    mutate("org" = organism) %>% 
    select(c(day, organism, mean_abundance)) %>%
    pivot_wider(names_from = organism, values_from = mean_abundance) %>%
    column_to_rownames(var = "day") %>% 
    as.matrix() %>% 
    t()
  
  # Scale data between -1 and 1
  mat <- t(scale(t(summary_data)))
  # Set colors
  col_rnorm = colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))
  
  # Create heatmap object
  plot <- Heatmap(mat,
                  show_column_names = FALSE,
                  row_title = "Organism",
                  col = col_rnorm, # Apply colors set above
                  column_title = "Day",
                  heatmap_legend_param = list(
                    title = "Scaled abundance",
                    legend_direction = "horizontal",
                    legend_width = unit(6, "cm")))
  
  plot <- draw(plot, heatmap_legend_side = "top")
  return(plot)
}

make_multivar_heatmap <- function(data) {
  # Plot a heatmap containing all vars
  # Take data as long and pivot to wide
  summary_data <- data %>%
    filter(type == "INF") %>% # Filter out controls
    group_by(organism, day, location, type) %>%
    summarize(
      mean_abundance = mean(abundance) # Calculate mean from repeats
    ) %>%
    ungroup() %>% 
    unite("annotation", c(day, location), sep = "-") %>% # Merge cols
    select(c(annotation, organism, mean_abundance)) %>%
    pivot_wider(names_from = organism, values_from = mean_abundance) %>%
    column_to_rownames(var = "annotation") %>%
    as.matrix() %>% 
    t() # Transpose
  
  # Scale data between -1 and 1
  mat <- t(scale(t(summary_data)))
  # Set colors
  col_rnorm = colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))
  
  # Order matrix columns by day
  numeric_part <- as.numeric(gsub("[^0-9]", "", colnames(mat))) # Pull numeric values
  ordered_cols <- colnames(mat)[order(numeric_part)] # Order cols against numeric values
  mat <- mat[, ordered_cols] # Apply ordered cols to matrix
  
  # Make heatmap object
  plot <- Heatmap(mat,
                  show_column_names = TRUE,
                  col = col_rnorm, # Apply colors set above
                  cluster_columns = FALSE, # Preserve column order
                  row_title = "Organism",
                  column_title = "Annotation",
                  heatmap_legend_param = list(
                    title = "Scaled abundance",
                    legend_direction = "horizontal",
                    legend_width = unit(6, "cm")))
  
  # Draw heatmap
  plot <- draw(plot, heatmap_legend_side = "top")
}
