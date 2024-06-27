library(phyloseq)
library(microeco)
library(file2meco)
library(tidyverse)

create_physeq_object <- function(data) {
  
  # data <- user_data
  
  # Clean input data containing multiple samples (more samples is better)
  cleaned_df <- data %>% 
    pivot_wider(names_from = `source`, values_from = abundance)
  
  # Make arbitrary sample IDs
  sample_ids <- seq(1, dim(cleaned_df)[1])
  sample_ids <- paste0("sample_", sample_ids)
  
  # Add sample IDs to data and remove NA values
  cleaned_df <- cleaned_df %>% 
    add_column(sample_ids) %>%
    column_to_rownames("sample_ids") %>% 
    replace(is.na(.), 0) # maybe move up?
  
  # Create dataframe with sample data annotations
  # sample_df <- cleaned_df %>% 
  #   pivot_longer(cols = 4:ncol(cleaned_df), names_to = "source", values_to = "abundance") %>% 
  #   select(-abundance) %>% 
  #   distinct(`source`, .keep_all = TRUE) %>% 
  #   column_to_rownames("source")
  
  # Abundance data
  otu_mat <- cleaned_df %>% 
    select(-c(species, taxonomy, entry_id)) %>% 
    as.matrix()
  
  # Taxonomy data
  tax_mat <- cleaned_df %>% 
    select(species) %>% 
    as.matrix()
  
  # Convert to phyloseq objects
  # SAMP = sample_data(sample_df)
  OTU = otu_table(otu_mat, taxa_are_rows = TRUE)
  TAX = tax_table(tax_mat)
  # physeq_object <- phyloseq(OTU, TAX, SAMP)
  physeq_object <- phyloseq(OTU, TAX)
  
  # Clean up
  remove(sample_ids)
  remove(cleaned_df)
  # remove(sample_df)
  # remove(SAMP, TAX, OTU)
  
  return(physeq_object)
}

create_network_phyloseq <- function(physeq_object, taxonomic_level, max_dist) {
  
  set.seed(123L)
  
  # Calculate the network
  network <- plot_net(physeq_object,
                      distance = "bray",
                      maxdist = max_dist,
                      point_label = taxonomic_level,
                      type = "taxa"
  )
  
  return(network)
}

create_network_meco <- function(physeq_object, plot_method = "phyloseq") {
  meco_object <<- phyloseq2meco(physeq_object)
  
  meco_network <<- trans_network$new(
    dataset = meco_object,
    cor_method = "bray",
    # use_WGCNA_pearson_spearman = FALSE,
    # use_NetCoMi_pearson_spearman = FALSE,
    use_sparcc_method = c("NetCoMi", "SpiecEasi")[1],
    taxa_level = "OTU",
    filter_thres = 0,
    nThreads = 1,
    SparCC_simu_num = 100
  )
  meco_network$cal_network()
  meco_network$cal_module(method = "cluster_fast_greedy")
  
  if (plot_method == "igraph") {
    # Plot method 1
    network_plot <- igraph::plot.igraph(meco_network$res_network,
                                        layout = layout_with_fr(meco_network$res_network),  # Use the Fruchterman-Reingold layout algorithm
                                        vertex.color = "white",  # Set vertex color
                                        vertex.size = 20,  # Set vertex size
                                        vertex.label = TRUE,  # Display vertex labels
                                        vertex.label.color = "black",  # Set vertex label color
                                        vertex.label.dist = 0.5,  # Set distance of vertex labels from vertices
                                        edge.color = "gray",  # Set edge color
                                        edge.width = 2,  # Set edge width
                                        edge.arrow.size = 0.5,  # Set arrowhead size for directed edges
                                        main = "Customized Network Plot"  # Set main title
    )
    return(network_plot)
  } else if (plot_method == "physeq") {
    # Plot method 2
    network_plot <- plot_network(meco_network$res_network,
                                 type = "taxa",label = "scientific_name"
    )
    return(network_plot)
  }
}



