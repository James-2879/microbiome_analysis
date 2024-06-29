# load_data <- ..
# maybe do this for controls

# Attempt to load data and print messages to stdout
load_user_data <- function(path) {
  #' Read a single TSV file.
  #' 
  #' File should contain three columns (species, taxonomy, abundance) in any order, but is case-sensitive.
  #' For loading multiple files at once, use load_user_data_dir().
  #'
  #' @param path path to single file as string
  #' @return a data frame with five columns (input columns plus 'entry_id' and 'source')
  
  tryCatch({
    user_data <- suppressMessages(read_tsv(path)) %>% 
      mutate(source = basename(path)) %>% 
      mutate(entry_id = row_number())
    message("[OK] Loaded data")
  }, error = function(error) {
    message("[!!] Unable to read tsv, see error below...")
    message(error)
    message("[**] Aborting - check input")
    stop()
  })
  return(user_data)
}

process_directory <- function(directory) {
  tryCatch({
    files <- list.files(directory)
    message(paste0("[OK] Found ", length(files), " files"))
    all_data <- imap_dfr(.x = files,
                         .f = function(file, i) {
                           cat(paste0("[>>] Loading file ", i, " of ", length(files), "\r"))
                           tsv <- suppressMessages(read_tsv(paste0(directory, file))) %>% 
                             mutate(source = file)
                         })
    message("\n[OK] Loaded data")
  }, error = function(error) {
    message("[!!] Unable to read tsv(s), see error below...")
    message(error)
    message("[**] Aborting - check input")
    stop()
  })
  return(all_data)
}

load_user_data_dir <- function(path) {
  #' Read multiple TSV files from a directory.
  #' 
  #' Files should contain three columns (species, taxonomy, abundance) in any order, but is case-sensitive.
  #' Directory should contain only TSV files to be loaded. Filenames will be used to create a 'source' column.
  #' For loading a single file, use load_user_data().
  #'
  #' @param path path to a directory as string
  #' @return a data frame with five columns (input columns plus 'entry_id' and 'source')
  
  # for (directory in args$data) {
  #   if (dir.exists(directory)) {
  #     process_directory(directory)
  #     }
  #   }
  
  directories <- path
  
  all_directories <- imap_dfr(.x = directories,
                       .f = function(directory, i) {
                         message(paste0("[>>] Loading directory ", i, " of ", length(directories)))
                         data <- process_directory(directory)
                         if (length(directories) > 1) {
                           data <- data %>% 
                             mutate(source = basename(directory))
                         }
                         data
                       }) %>% 
    mutate(entry_id = row_number())
  
  return(all_directories)
  
}

# Check loaded data is in correct format
check_data <- function(data) {
  #' Check user data for correct format.
  #' 
  #' Check that all specified columns are present, but additional columns are ignored.
  #' 
  #' @param data data frame
  
  expected_cols <- c("species", "taxonomy", "abundance", "entry_id", "source")
  if (sum(expected_cols %in% tolower(colnames(data))) == length(expected_cols)) {
    message("[OK] Found expected columns in data")
  } else {
    message("[!!] Unable to find all expected columns")
    missing_cols <- expected_cols[!expected_cols %in% tolower(colnames(data))]
    message(paste0("     Missing: ", missing_cols))
    message("[**] Aborting - check input")
    stop()
  }
}
