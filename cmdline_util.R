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
parser$add_argument
args <- parser$parse_args()


if (args$options) {
  message('Available functions')
  message("-------------------")
  message("0 - Empty")
  message("1 - Function 1")
  message("0 - Function 2")
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

tryCatch({
  # try
  user_data <- read_tsv(args$data)
}, error = function(error) {
  # error handling
  message("[!!] Unable to read tsv, see error below...")
  message(error)
})


if (args$f == "make_barplot") {
  # unpack args first
  plot <- make_barplot(data = user_data)
} else if (args$f == "make_stacked_barplot") {
  #
}


# Parse out extra arguments
if (length(args$extra) > 0) {
  for (arg in args$extra) {
    print(arg)
  }
}