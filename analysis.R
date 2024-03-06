script_dir <- "/home/james/Documents/microbiome_analysis/"
setwd(script_dir)

source("tools/clean.R")
source("tools/barplot.R")
source("tools/pcoa.R")
source("tools/heatmap.R")
source("tools/co_network.R")
source("tools/cross_feeding_network.R")

library(tidyverse)

data <- clean_data(type = "long")

make_barplot(data)
make_stacked_barplot(data)
make_horizontal_stacked_barplot(data)
make_compressed_stacked_barplot(data)

make_heatmap(data)
make_univar_heatmap(data)
make_multivar_heatmap(data)

do_pcoa(data)


# density plot to show distribution of abundance



# plot to analyze niormalization



# phylogram of the bacteria species for ordering the bar plot
# plot to show cahnge in abundance