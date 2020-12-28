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
    stop("file does not exist: ", sQuote(file), call. = FALSE)
  }
}

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

#' Check file identity
#'
#' Compares the contents of a local Rmd file with a file from GoogleDrive
#'
#' @inheritParams upload_rmd 
#' @return `TRUE` if files are identical, `FALSE` otherwise.
#' @noRd
#'
check_identity <- function(file){
  local_file <- paste0(file, ".Rmd")
  temp_file <- paste0(".temp-", basename(file), ".Rmd")
  
  if (file.exists(local_file)){
    md5_file <- unname(tools::md5sum(local_file))
    md5_temp_file <- unname(tools::md5sum(temp_file))
    md5_file == md5_temp_file
  } else {
    FALSE
  }
}

#' Get dribble
#'
#' Gets dribble ("Drive tibble") for the file name, folder, and Team Drive
#'   provided
#'
#' @inheritParams upload_rmd 
#' @return A dribble object.
#' @noRd
#' @seealso [googledrive::dribble()]

get_dribble <- function(gfile, path = NULL, team_drive = NULL) {
  if (!is.null(path)) {
    path_dribble <- get_path_dribble(path = path, team_drive = team_drive)
    
    googledrive::drive_find(q = c(paste0("'", path_dribble$id,"' in parents", collapse = " or "),
                                  paste0("name = '", gfile,"'")),
                            team_drive = team_drive)
    
  } else if (is.null(path) & !is.null(team_drive)) {
    # TODO: revise this part according to team_drive functionality
    googledrive::team_drive_get(team_drive) %>%
      googledrive::drive_ls(pattern = gfile)
  } else {
    googledrive::drive_find(q = c("'root' in parents",
                                  paste0("name = '", gfile,"'")),
                            team_drive = team_drive)
  }
}

get_dribble_old <- function(gfile, path = NULL, team_drive = NULL) {
  if (!is.null(path)) {
    googledrive::drive_get(path = path, team_drive = team_drive) %>%
      googledrive::drive_ls(pattern = gfile)
  } else if (is.null(path) & !is.null(team_drive)) {
    googledrive::team_drive_get(team_drive) %>%
      googledrive::drive_ls(pattern = gfile)
  } else {
    googledrive::drive_ls(path = "~", pattern = gfile)
  }
}

#' Get path dribble
#'
#' Gets dribble ("Drive tibble") for the last folder provided in the path
#' starting from root.
#'
#' @inheritParams upload_rmd
#' @return A dribble object. Note that multiple lines could be returned if
#'   multiple folders  exist  with the same path.
#' @noRd
#' 
get_path_dribble <- function(path , team_drive = NULL){
  # get sequence of folders
  path <- stringr::str_split(path, pattern = "/", simplify = TRUE)[1,]
    
  # get folders id starting from root
  for (i in seq_along(path)){
    id_folders <- if(i == 1L) "root" else dribble$id
    
    dribble <- googledrive::drive_find(
      q = c(paste0("'", id_folders,"' in parents", collapse = " or "), 
            "mimeType = 'application/vnd.google-apps.folder'",
            paste0("name = '", path[i],"'")),
      team_drive = team_drive)
    
    # Check if path is available on drive
    if(nrow(dribble) < 1){
      stop(paste0("Folder ", 
                  sQuote(paste0(path[1:i], sep = "/",  collapse = "")),
                  " does not exists in GoogleDrive."),
           call. = FALSE)
    }
  }
  
  return(dribble)
}

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
    c(., "") %>%
    paste(collapse = "\n") %>%
    stringr::str_replace_all("\n\n\n", "\n\n")
  
  cat(temp, file = gfile) # workaround for the writing problem (TO REVIEW)
}

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
