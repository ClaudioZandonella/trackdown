#########################
####    Utilities    ####
#########################

#----    check_file    ----

#' Check whether local file exists
#'
#' Checks whether the specified local file exists, stops otherwise.
#'
#' @inheritParams upload_rmd 
#' @return NULL
#' @noRd
#'
check_file <- function(file) {
  # check file is a single string
  if(!(is.character(file) && length(file) == 1L))
    stop("file has to be a single string")
  
  if (!file.exists(file)) {
    stop('file does not exist: "', file,'"', call. = FALSE)
  }
}

#----    check_gfile    ----

#' Check whether file exists in Google Drive
#'
#' Checks whether the specified file exists in Google Drive, stops otherwise.
#'
#' @inheritParams upload_rmd 
#' @return NULL
#' @noRd
#'
check_gfile <- function(dribble) {
  if (nrow(dribble) == 0){
    stop(
      "file does not exists in GoogleDrive.",
      call. = FALSE
    )
  } else if (nrow(dribble) > 1) {
    stop(
      "more than one file with this name exists in GoogleDrive.",
      call. = FALSE
    )
  }
}


#----    check_identity    ----

#' Check file identity
#'
#' Compares the contents of a local Rmd file with a file from GoogleDrive
#'
#' @inheritParams upload_rmd 
#' @return `TRUE` if files are identical, `FALSE` otherwise.
#' @noRd
#'
check_identity <- function(local_path, local_file){
  temp_file <- file.path(local_path, paste0(".temp-", local_file))
  local_file <- file.path(local_path, local_file)
  
  if (file.exists(local_file)){
    md5_file <- unname(tools::md5sum(local_file))
    md5_temp_file <- unname(tools::md5sum(temp_file))
    md5_file == md5_temp_file
  } else {
    FALSE
  }
}

#----    sanitize_gfile    ----

#' Sanitize Rmd file downloaded from GoogleDrive
#'
#' Adds a final EOL and removes double linebreaks added when downloading file
#' from GoogleDrive.
#'
#' @inheritParams upload_rmd 
#' @return Sanitized file from Google Drive.
#' @noRd
#'
sanitize_gfile <- function(gfile) {
  temp <- readLines(gfile, warn = FALSE) %>%
    c("") %>%
    paste(collapse = "\n") %>%
    stringr::str_replace_all("\n\n\n", "\n\n")
  
  cat(temp, file = gfile) # workaround for the writing problem (TO REVIEW)
}

#----    stop_quietly    ----

#' Stop quietly
#' 
#' Stop a function without throwing an error.
#' Function adapted from https://stackoverflow.com/a/42945293/12481476
#'
#' @param text a string indicating the message to display 
#'
#' @return NULL
#'
stop_quietly <- function(text = NULL) {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  message(text)
  stop()
}

#----    Messages Utils    ----

# main_process
main_process <- function(message){
  cat(cli::cat_rule(message), "\n")
}

# emph_file
emph_file <- function(file){
  cli::col_blue(basename(file))
} 

# sub_process
sub_process <- function(message){
  cli::cli_li(message)
}

# start_process
start_process <- function(message){
  cli::cat_bullet(bullet_col = "#8E8E8E", message)
}

# finish_process
finish_process <- function(message){
  cli::cat_bullet(bullet = "tick", bullet_col = "green", message)
}

#----    pipe operator    ----

#' pipe operator
#'
#' See \code{magrittr::\link[magrittr]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname operator_pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

#----    get_file_info    ----

#' Get file info
#' 
#' Given the path to a file, get file information about path, file-name, file
#' extension, file-basename.
#'
#' @param file a string indicating the path to a file
#'
#' @return a list with
#' \itemize{
#'   \item{path: the path to the file. If there is no path \code{"."} is
#'   returned}
#'   \item{file_name: file name with extension}
#'   \item{extension: the file extension without point and all lowercase}
#'   \item{file_basename: the file name without extesion}
#' }
#' 
#' @noRd
#' 
#' @examples
#' get_file_info("my_folder/my_file.txt")
#' get_file_info("my.file.txt")
#' 

get_file_info <- function(file){
  # check file is a single string
  if(!(is.character(file) && length(file) == 1L))
    stop("file has to be a single string")
  
  # get info
  path <- dirname(file)
  file_name <- basename(file)
  
  # ensure there is extension
  if(!grepl(pattern = "\\.", file_name))
    stop("file do not include extension")
  
  # get extension as last element split "."
  extension <- stringr::str_split(file_name, pattern = "\\.")[[1]] %>%
    tail(n = 1)
  
  file_basename <- sub(pattern = paste0("\\.", extension), replacement = "",
                       file_name)
  
  return(list(path = path,
              file_name = file_name,
              extension = tolower(extension), # get lowercase
              file_basename = file_basename))
}

#----    get_instructions    ----

#' Add Instructions
#' 
#' Add instruction on top of document to explain reviewdown
#'
#' @param extension string indicating the file extension
#' @param hide_code logical value indicating whether the code was from the
#'   text document
#'
#' @return a string with the instructions 
#' @noRd
#'
#' @examples
#'   get_instructions("rmd", TRUE)
#' 

get_instructions <- function(extension, hide_code){
  
  language <- switch(extension,
                     "rmd" = "Markdown",
                     "rnw" = "LaTeX")
  
  placeholder <- switch(hide_code,
                        "TRUE" = 'Please avoid do not remove placeholders of type "[[chunk-<name>]]" or "[[document-header]]',
                        "FALSE" = NULL)
  
  instructions <- c(
    "#----Reviewdown Instructions----#",
    sprintf("This is not a common Document. The Document includes proper formatted %s syntax and R code. Please be aware and responsible in making corrections as you could brake the code. Limit change to plain text and avoid to the specific command.",
            language),
    placeholder,
    "Once the review is terminated accept all changes: Tools -> Review suggested edits -> Accept all.",
    "You do not need to remove these lines they will be automatically removed.",
    "#----End Instructions----#")
  
  return(instructions)
}

#----    format_document    ----

#' Format the document as a single string
#'
#' @param document a vector with the content of the document
#' @param extension string indicating the file extension
#' @param hide_code logical value indicating whether the code was from the
#'   text document
#'
#' @return a string with the content of the document 
#' @noRd 
#'
#' @examples
#'   document <- readLines("tests/testthat/test_files/example_1_rmd.txt")
#'   format_document(document, extension = "rmd", hide_code = FALSE)
#'   

format_document <- function(document, extension, hide_code){
  
  # Add instructions
  document <- c(get_instructions(extension = extension, 
                                 hide_code = hide_code), document)
  
  # sanitize paper
  document <- document %>% 
    paste(collapse = "\n") %>% 
    stringr::str_replace_all("\n\n\n", "\n\n")
  
  return(document)
}

#----


