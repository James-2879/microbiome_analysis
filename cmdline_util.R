library(argparse)

parser <- ArgumentParser(description = "R microbiome analysis utility")
parser$add_argument("-o", "--options",
                    action = "store_true",
                    help = "list all functions contained within utility")
parser$add_argument("-f", "--function",
                    type = "integer",
                    default = 0,
                    help = "data analysis function to invoke")
parser$add_argument("-d", "--data",
                    type = "character",
                    default = NULL,
                    help = "full path to .tsv file")
parser$add_argument("-e", "--extra",
                    nargs = "+",
                    help = "Add function arguments separated by a space")
args <- parser$parse_args()


if (args$options) {
  message('Available functions')
  message("-------------------")
  message("0 - Empty")
  message("1 - Function 1")
  message("0 - Function 2")
  message("-------------------")
  message("Specify as an argument like '--function 0'")
  quit()
} else if (is.null(args$data)) {
  message("[!!] No path to data specified in arguments")
  quit()
} else if (args$f == 0) {
  message("[!!] No function specified in arguments")
  quit()
}

if (args$f == 0) {
  # 
} else if (args$f == 1) {
  #
}


# Parse out extra arguments
if (length(args$extra) > 0) {
  for (arg in args$extra) {
    print(arg)
  }
}