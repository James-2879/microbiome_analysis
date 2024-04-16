library(argparse)

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("--options",
                    action = "store_true",
                    help = "list all functions contained within utility")
parser$add_argument("-f", "--function",
                    type = "character",
                    default = NULL,
                    help = "data analysis function to invoke")
parser$add_argument("-d", "--data",
                    type = "character",
                    default = NULL,
                    help = "full path to .tsv file")
parser$add_argument("-e", "--extra",
                    nargs = "+",
                    help = "add function arguments separated by a space")
parser$add_argument("-o", "--output",
                    type = "character",
                    default = NULL,
                    help = "full path to save images to")
args <- parser$parse_args()

if (args$options) {
  message('Available functions')
  message("-------------------")
  message("do_pcoa")
  message("-------------------")
  message("Specify as an argument like '--function function_name'")
  quit()
} else if (is.null(args$data)) {
  message("[!!] No path to data specified in arguments")
  quit()
} else if (is.null(args$f)) {
  message("[!!] No function specified in arguments")
  quit()
}

# Configure session ----
message("> Preparing session and data")

suppressPackageStartupMessages({
  ## Load core library 
  library(tidyverse)
  
  ## Load tools and extra libraries 
  source("tools/data.R")
  source("tools/themes.R")
  source("tools/controls.R")
  source("tools/treemap.R")
  source("tools/density.R")
  source("tools/barplot.R")
  source("tools/pcoa.R")
  source("tools/heatmap.R")
  source("tools/co_network.R")
  source("tools/cross_feeding_network.R")
})

message("[OK] Loaded packages")
message("[OK] Sourced tools")

# Attempt to read in user data
tryCatch({
  user_data <- suppressMessages(read_tsv(args$data))
  message("[OK] Loaded data")
}, error = function(error) {
  message("[!!] Unable to read tsv, see error below...")
  message(error)
  message("[**] Aborting - check input")
  quit()
})

# Check data is in expected format
check_data(user_data)
user_data <- tidy_data(user_data)

message("> Generating plot")

# PCoA
if (args$f == "do_pcoa") {
  jpeg(args$output, height = 2160, width = 3840, res = 300)
  suppressMessages(do_pcoa(data = user_data)) # dev.off() not required
}

message(paste0("[OK] Saved output to ", args$output))
message("> Done, exiting")
quit()

if (args$f == "make_barplot") {
  # unpack args first
  plot <- make_barplot(data = user_data)
} else if (args$f == "make_stacked_barplot") {
  #
}


# TODO Parse out extra arguments
# if (length(args$extra) > 0) {
#   for (arg in args$extra) {
#     print(arg)
#   }
# }