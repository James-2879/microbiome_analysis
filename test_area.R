library(tidyverse)

file_path <- "/home/james/Documents/microbiome_analysis/data/input/luke/M1_MM-50_ST-0_Q-0.6_KKc-0.01_KKhg-4.tsv"
dir_path <- "/home/james/Documents/microbiome_analysis/data/input/luke/"

file_data <- load_user_data(file_path)
dir_data <- load_user_data_dir(dir_path)

check_data(file_data)
check_data(dir_data)

library("roxygen2")
roxygen2::roxygenise(package.dir = "/home/james/Documents/microbiome_analysis/")