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

#----    check_identity    ----

#' Check file identity
#'
#' Compares the contents of a local Rmd file with a file from GoogleDrive
#'
#' @inheritParams upload_rmd 
#' @return `TRUE` if files are identical, `FALSE` otherwise.
#' @noRd
#'
check_identity <- function(temp_file, local_file){
  
  if (file.exists(local_file)){
    md5_file <- unname(tools::md5sum(local_file))
    md5_temp_file <- unname(tools::md5sum(temp_file))
    res <- md5_file == md5_temp_file
  } else {
    res <- FALSE
  }
  
  return(res)
}

#----    sanitize_document    ----

#' Sanitize Rmd file downloaded from GoogleDrive
#'
#' Adds a final EOL and removes double linebreaks added when downloading file
#' from GoogleDrive.
#'
#' @inheritParams upload_rmd 
#' @return Sanitized file from Google Drive.
#' @noRd
#'
sanitize_document <- function(file) {
  file <- c(file, "")
  res <- gsub("\n\n\n", "\n\n", paste(file, collapse = "\n"))
  return(res)
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
#' @noRd
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
  extension <- strsplit(file_name, split = "\\.")[[1]]
  extension <- tail(extension, n = 1)
  
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
#' @param file_info list with file info returned from get_file_info() function
#' @param hide_code logical value indicating whether the code was from the
#'   text document
#'
#' @return a string with the instructions 
#' @noRd
#'
#' @examples
#'   file_info <- get_file_info("tests/testthat/test_files/example_1.Rmd")
#'   get_instructions(file_info, TRUE)
#' 

get_instructions <- function(file_info, hide_code){
  
  language <- switch(file_info$extension,
                     "rmd" = "Markdown",
                     "rnw" = "LaTeX")
  

  placeholder1 <- switch(hide_code,
                         "TRUE" = 'Please do not remove placeholders of type "[[chunk-<name>]]" or "[[document-header]]"',
                         "FALSE" = NULL)
  placeholder2 <- c(sprintf("FILE-NAME: %s",file_info$file_name),
                    sprintf("HIDE-CODE: %s", hide_code))
  
  instructions <- c(
    "#----Trackdown Instructions----#",
    sprintf("This is not a common Document. The Document includes properly formatted %s syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code.",
            language),
    placeholder1,
    "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all.",
    "You must not modify or remove these lines, we will do it for you ;)",
    placeholder2,
    "#----End Instructions----#")
  
  return(instructions)
}

#----    format_document    ----

#' Format the document as a single string
#'
#' @param document a vector with the content of the document
#' @param file_info list with file info returned from get_file_info() function
#' @param hide_code logical value indicating whether the code was from the
#'   text document
#'
#' @return a string with the content of the document 
#' @noRd 
#'
#' @examples
#'   document <- readLines("tests/testthat/test_files/example_1_rmd.txt")
#'   file_info <- get_file_info("tests/testthat/test_files/example_1.Rmd")
#'   format_document(document, file_info = file_info, hide_code = FALSE)
#'   

format_document <- function(document, file_info, hide_code){
  
  # Add instructions
  document <- c(get_instructions(file_info = file_info, 
                                 hide_code = hide_code), document)
  
  # sanitize document
  document <- sanitize_document(document)
    
  
  return(document)
}

#----    check_dribble    ----

#' Eval No Dribble
#' 
#' Stop if a file is already present in drive
#'
#' @param dribble dribble object of the files resulting from get_dribble_info()
#'   function
#' @param gfile string indicating the name of the gfile
#' @param test string indicating whether to test no line in dribble ("none"),
#'   single line in dribble ("single") or both condition accepted ("both")
#'
#' @return NULL
#' @noRd
#'
#' @examples
#' gfile <- "Hello-world"
#' dribble <- get_dribble_info(gfile = gfile, path = "reading_folder")
#' check_dribble(dribble$file, gfile)
#' 

check_dribble <- function(dribble, gfile, test = c("none", "single", "both")){
  test <- match.arg(test)
  
  if(test == "none") {
    if (nrow(dribble) > 0) {
      stop(
        "A file with this name already exists in GoogleDrive: ",
        sQuote(gfile),
        ". Did you mean to use `update_file()`?",
        call. = FALSE
      )
    }
  } else if (test == "single") {
    if (nrow(dribble) > 1L) {
        # multiple files
        stop("More than one file with this name already exists in GoogleDrive: ",
             sQuote(gfile),".",
             call. = FALSE)
      } else if (nrow(dribble) < 1L) {
        # no files
        stop("No file with this name exists in GoogleDrive: ",
             sQuote(gfile),". Did you mean to use `upload_file()`?",
             call. = FALSE)
      }
  } else if (test == "both") {
    if (nrow(dribble) > 1L) {
      # multiple files
      stop("More than one file with this name already exists in GoogleDrive: ",
           sQuote(gfile),".",
           call. = FALSE)
    }
  }
}

#----    eval_instructions    ----

#' Evaluate Docuemnt Instructions
#' 
#' Given the document (vector with the text lines) retrieve instructions indexes
#' and the FILE-NAME and HIDE-CODE options
#'
#' @param document character vector with the lines of the document 
#'
#' @return a list with:
#' \itemize{
#'   \item{instruction_start - integer inidicating the instructions initial line}
#'   \item{instruction_end - integer inidicating the instructions end line}
#'   \item{file_name - character indicating the file name}
#'   \item{hide_code - logical indicating whether code was removed}
#' }
#' 
#' @noRd 
#'
#' @examples
#' 
#' document <- readLines("tests/testthat/test_files/example_instructions.txt", warn = FALSE)
#' eval_instructions(document)
#' 
#' # no instructions delimiters
#' eval_instructions(document[-1])
#' 
#' # no file_name
#' eval_instructions(document[-6])
#' 
#' # no hide_code
#' eval_instructions(document[-7])
#' 

eval_instructions <- function(document, file_name = NULL){
  
  # get instruction lines
  instruction_start <- which(grepl("#----Trackdown Instructions----#", document))
  instruction_end <- which(grepl("#----End Instructions----#", document))
  
  # test retrieve instructions
  my_test <- length(c(instruction_start, instruction_end))
  if (my_test!= 2L){
    warning("Failed retrieving instructions delimiters. ",
            "Intructions delimiters at the beginning shuld not be removed.", call. = FALSE)
    instruction <- document # search options in the whole document
    instruction_start <- NULL
    instruction_end <- NULL
  } else {
    instruction <- document[instruction_start:instruction_end]
  }
  
  
  # get file-name and hide-code options lines
  line_file_name <- which(grepl("^FILE-NAME:", instruction)) 
  line_hide_code <- which(grepl("^HIDE-CODE: ", instruction))
  
  # test retrieve FILE-NAME
  if (length(line_file_name)!= 1L){
    warning("Failed retrieving FILE-NAME, current file name is used instead.", call. = FALSE)
    old_file_name <- file_name
  } else {
    old_file_name <- gsub("^FILE-NAME:\\s*(.*)\\s*","\\1", instruction[line_file_name])
  }
  
  # test retrieve HIDE-CODE
  if (length(line_hide_code)!= 1L){
    warning("Failed retrieving HIDE-CODE. Considering presence of code tags instead.", call. = FALSE)
    hide_code <- any(grepl("^\\[\\[(document-header|chunk-.*)\\]\\]", document))
  } else {
    hide_code <- as.logical(gsub("^HIDE-CODE:\\s*(.*)\\s*","\\1", instruction[line_hide_code]))
  }
  
  res <- list(start = instruction_start,
              end = instruction_end,
              file_name = old_file_name,
              hide_code = hide_code)
  
  return(res)
}

#----    load_code    ----

#' Load Code from .trackdown Folder
#'
#' Try to load header_info or chunck_info from .trackdown Folder. Meaningful
#' error message is returned if case of error or wanring
#' 
#' @param file_name character indicating the name of the file
#' @param path character indicating the path where the folder ".trackdown" is located
#' @param type character indicating the required code, header or chunk
#'
#' @return a dataframe with the loaded code info
#' 
#' @noRd
#'

load_code <- function(file_name, path, type = c("header", "chunk")){
  
  type <- match.arg(type)
  
  data_path <- file.path(path,".trackdown",paste0(file_name, "-", type, "_info.rds"))
  
  tryCatch({data <- readRDS(file = data_path)},
    error = function(e) stop("Failed restoring code, ",
                             data_path," is not available.", call. = FALSE),
    warning = function(w) stop("Failed restoring code, ",
                               data_path," is not available.", call. = FALSE)
  )
  
  return(data)
}

#----    does_error    ----

#' Evaluate if Function returns error
#'
#' Function from https://adv-r.hadley.nz/conditions.html
#' 
#' @param expr expression to evaluate
#'
#' @return logical value
#' @noRd
#'

does_error <- function(expr) {
  tryCatch(
    error = function(cnd) TRUE,
    {
      expr
      FALSE
    }
  )
}

#----    sanitize_path    ----

#' Sanitize Path
#' 
#' Remove last "/" from path if present
#' 
#' @param path a string indicating the path
#'
#' @return a string
#' @noRd
#'

sanitize_path <- function(path){
  if(is.null(path)){
    res <- NULL
  } else {
    res <- gsub("/$", "", path)
  }
  
  return(res)
}

#----    check_supported_documents    ----

#' Check Supported Documents
#' 
#' Only .Rmd and .Rnw fiels are supported
#' 
#' @param file_info list with file info returned from get_file_info() function
#'
#' @return NULL
#' @noRd
#'
#' @examples
#' file_info <- get_file_info("my-report.txt")
#' check_supported_documents(file_info)
#' 

check_supported_documents <- function(file_info){
  if(!(file_info$extension %in% c("rmd", "rnw"))) # check supported files
    stop(paste(file_info$file_name, "not supported file type (only .Rmd or .Rnw)"), 
         call. = FALSE)
}

#----    get_os    ----

#' Get the current operating system
#' 
#' @return the current os as string
#' @noRd
#'
#' @examples
#' os <- get_os()
#' 

get_os <- function(){
  return(.Platform$OS.type)
}

#----

