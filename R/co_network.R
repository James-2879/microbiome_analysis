suppressPackageStartupMessages({
  library(argparse)
  library(phyloseq)
  library(microeco)
  library(file2meco)
  library(tidyverse)
})

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-w", "--utility_directory",
                    type = "character",
                    default = NULL,
                    help = "full path to location of utility directory")
parser$add_argument("-d", "--data",
                    type = "character",
                    nargs = "+",
                    default = NULL,
                    help = "full path to directory containing .tsv files")
parser$add_argument("-m", "--method",
                    type = "character",
                    default = "bray",
                    help = "distance method to use (defaults to bray)")
parser$add_argument("-k", "--max_distance",
                    type = "double",
                    default = 0.5,
                    help = "max distance between vertices (defaults to 0.5)")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
args <- parser$parse_args()

create_physeq_object <- function(data) {
  #' Create a Phyloseq object from data set.
  #' 
  #' Required to plot networks.
  #' 
  #' How this object is created depends on how networks are created later on.
  #'  It is important to arrange the input data frame in the same way to ensure
  #'  that networks are both reproducible and comparable.
  #'
  #' @param data data frame
  #' @returns Phyloseq object
  
  # Clean input data containing multiple samples (more samples is better)
  cleaned_df <- data %>% 
    select(c(species, abundance, source)) %>% 
    group_by(source, species) %>%
    summarise(abundance = mean(abundance, na.rm = TRUE)) %>%
    pivot_wider(names_from = `source`, values_from = abundance) %>%
    arrange(across(2:ncol(.), desc))
  
  # Make arbitrary sample IDs
  sample_ids <- seq(1, dim(cleaned_df)[1])
  sample_ids <- paste0("sample_", sample_ids)
  
  # Add sample IDs to data and coerce NA values to zeros
  cleaned_df <- cleaned_df %>% 
    add_column(sample_ids) %>%
    column_to_rownames("sample_ids") %>% 
    replace(is.na(.), 0)
  
  # Abundance data
  otu_mat <- cleaned_df %>% 
    select(-c(species)) %>% 
    as.matrix()
  
  # Taxonomy data
  tax_mat <- cleaned_df %>% 
    select(species) %>% 
    as.matrix()
  
  # Convert to phyloseq objects
  OTU = otu_table(otu_mat, taxa_are_rows = TRUE)
  TAX = tax_table(tax_mat)
  physeq_object <- phyloseq(OTU, TAX)
  
  # Clean up
  remove(sample_ids)
  remove(cleaned_df)
  remove(TAX, OTU)
  
  return(physeq_object)
}

create_network_phyloseq <- function(physeq_object, max_dist = 0.5, distance_method = "bray") {
  #' Create network from a Phyloseq object.
  #' 
  #' Creates a network showing co-expression relationships. More samples works best.
  #'  For 'max_dist', lower is better. However:
  #'  - Set higher if network too disconnected or contains few vertices
  #'  - Set lower if network too connected 
  #'
  #' @param physeq_object Phyloseq object
  #' @param max_dist integer (max distance between vertices)
  #' @param distance_method string (see phyloseq documentation for available methods)
  #' @returns list (CLI will save plot as image)
  
  set.seed(123L)
  # Compute the network
  network <- plot_net(physeq_object,
                      distance = distance_method,
                      maxdist = max_dist,
                      point_label = "species",
                      type = "taxa"
  ) +
    labs(title = "Interactions Between Species in Microbial Community",
         caption = str_wrap("This network plot visualizes the interactions between different microbial species within a community. 
                            Each node represents a unique species, and the edges (lines) between them indicate the presence of a co-occurrence relationship. 
                            The thickness of the edges reflects the strength of these interactions, with thicker lines indicating closer or more significant associations. 
                            Spatial distribution of the nodes highlights the clustering of species that frequently interact with each other, while isolated nodes suggest species with fewer or weaker connections within the community.",
                            width = 160)
    )
  
  return(network)
}


if (!interactive()) {
  
  setwd(toString(args$utility_directory))
  
  # Load required functions
  message("[>>] Preparing session and data")
  suppressPackageStartupMessages({
    source("R/data.R")
  })
  message("[OK] Loaded packages")
  message("[OK] Sourced tools")
  
  # Load data and check against expected format
  user_data <- load_user_data_dir(args$data)
  check_data(user_data)
  
  physeq_obj <- create_physeq_object(user_data)
  message("[OK] Created Phyloseq object")
  
  # Make and save the plot
  message("[>>] Generating plot")
  jpeg(paste0(args$output, "network.jpeg"), height = 2160, width = 3840, res = 300)
  create_network_phyloseq(physeq_obj, max_dist = args$max_distance, distance_method = args$method)
}

if (!interactive()) {
  # Can't be in same block after graphics device as issues with dev.off()
  message(paste0("[OK] Saved plot to ", args$output))
  message("[COMPLETE]")
}