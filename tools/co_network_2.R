library(microeco)
library(file2meco)

data(dataset)

meco_object <- phyloseq2meco(physeq_object)

meco_network <- trans_network$new(
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
meco_network

meco_network$cal_network()
meco_network$cal_module(method = "cluster_fast_greedy")
meco_network$save_network(filepath = "network.gexf")
net <- read.gexf("network.gexf")
# this does work but I could only view the graph in gephi



