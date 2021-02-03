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
  if (!file.exists(file)) {
    stop("file does not exist: ", sQuote(file), 
         ".\nRemember to specify name without extension ;)", call. = FALSE)
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

#----


