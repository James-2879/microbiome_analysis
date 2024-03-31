library(phyloseq)

# Clean input data
# For all_samples obj
cleaned_df <- all_samples %>% 
  mutate("repeat" = paste0("repeat_", `repeat`)) %>% 
  pivot_wider(names_from = `repeat`, values_from = abundance)

sample_ids <- seq(1, dim(cleaned_df)[1])
sample_ids <- paste0("sample_", sample_ids)

cleaned_df <- cleaned_df %>% 
  add_column(sample_ids) %>%
  column_to_rownames("sample_ids") %>% 
  filter(!is.na(repeat_1) & !is.na(repeat_2) & !is.na(repeat_3))

# Abundance data
otu_mat <- cleaned_df %>% 
  select(c(repeat_1, repeat_2, repeat_3)) %>% 
  as.matrix()

# Taxonomy (annotations)
tax_mat <- cleaned_df %>% 
  select(-c(scientific_name, Taxa, day, location, type, repeat_1, repeat_2, repeat_3)) %>% 
  as.matrix()

# Convert to phyloseq objects
OTU = otu_table(otu_mat, taxa_are_rows = TRUE)
TAX = tax_table(tax_mat)
physeq_object <- phyloseq(OTU, TAX)

# Clear up
remove(sample_ids)
remove(cleaned_df)
remove(TAX, OTU)

# ---------------------

# For testing
# plot_bar(physeq_object, fill = "genus")

# For when other annotations are available
# sampledata = sample_data(data.frame(
#   Location = sample(LETTERS[1:4], size=nsamples(physeq), replace=TRUE),
#   Depth = sample(50:1000, size=nsamples(physeq), replace=TRUE),
#   row.names=sample_names(physeq),
#   stringsAsFactors=FALSE
# ))
# sampledata

# ---------------------

# Clean input data
# For all_samples obj
cleaned_df <- test_microbiome %>% 
  filter(!is.na(abundance))

sample_ids <- seq(1, dim(cleaned_df)[1])
sample_ids <- paste0("sample_", sample_ids)

cleaned_df <- cleaned_df %>% 
  add_column(sample_ids) %>%
  column_to_rownames("sample_ids")

# Abundance data
otu_mat <- cleaned_df %>% 
  select(c(abundance)) %>% 
  as.matrix()

# Taxonomy (annotations)
tax_mat <- cleaned_df %>% 
  select(-c(scientific_name, taxonomy, confidence, abundance)) %>% 
  as.matrix()

# Convert to phyloseq objects
OTU = otu_table(otu_mat, taxa_are_rows = TRUE)
TAX = tax_table(tax_mat)
physeq_object <- phyloseq(OTU, TAX)

# Clear up
remove(sample_ids)
remove(cleaned_df)
remove(TAX, OTU)

# Example functions ------------------------------------------------------------

set.seed(123)

ig <- make_network(physeq_object, dist.fun="bray", max.dist=0.3)
plot_network(ig, physeq_object, line_weight=0.4, label=NULL)

