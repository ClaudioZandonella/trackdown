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

#----    get_dribble    ----

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

#----    get_path_dribble    ----

#' Get path dribble
#'
#' Gets dribble ("Drive tibble") for the last folder provided in the path
#' starting from root. If the required folder is not available, options to
#' create it is proposed.
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
      # check whether user wants to create folder in Google Drive
      response <- utils::menu(c("Yes", "No"), title = paste0(
          "Folder ", sQuote(paste0(path, sep = "/",  collapse = "")),
          " does not exists in GoogleDrive.", " Do you want to create it?"
        )
      )
      
      if (response == 2){
        stop_quietly("Process arrested")
      } else{
        
        # evaluate if unique parent folder is available
        if(length(id_folders) != 1){
          stop(paste0("No unique parent folder ", 
                      sQuote(paste0(path[1:(i-1)], sep = "/",  collapse = "")),
                      " exists in GoogleDrive. Folder ",
                      sQuote(paste0(path[i:length(path)], sep = "/",  collapse = "")),
                      " can not be created automatically."),
               call. = FALSE)
        } else {
          
          # create folder in google drive and return dribble
          dribble <- create_drive_folder(name = path[i:length(path)], 
                                         parent_id = id_folders, 
                                         team_drive = team_drive)
          
          return(dribble)
        }
      }
    }
  }
  
  return(dribble)
}

#----    get_parent_dribble    ----

#' Get parent dribble
#' 
#' Get the dribble of the parent folder or root if path is not specified
#' 
#' @param path character. (Sub)directory in My Drive or a Team Drive
#' @param team_drive character. The name of a Google Team Drive (optional).
#'
#' @return A dribble object.
#'
#' @noRd
#' 
get_parent_dribble <- function(path = NULL, team_drive = NULL){
  # get dribble of the parent folder
  if (!is.null(path)) {
    path <- get_path_dribble(path = path, team_drive = team_drive)
  } else if (is.null(path) & !is.null(team_drive)) {
    path <- googledrive::team_drive_find(team_drive)
  } else {
    path <- get_root_id()
  }
  return(path)
}

#----    create_drive_folder    ----

#' Create a folder in Googledrive
#'
#' Create a folder in Googledrive. 
#' 
#' !TODO! evaluate possible problems when using team_drive.
#'
#' @param name character vector indicating the sequence of folders to create
#' @param parent_id a string indicating the Google Drive id of the parent folder
#' @param team_drive a string indicating the name of a Google Team Drive
#'   (optional).
#'
#' @return A dribble object with information of the created folder.
#' @noRd
#' 
create_drive_folder <- function(name, parent_id = NULL, team_drive = NULL){
  
  if(parent_id == "root") parent_id <- get_root_id(team_drive = team_drive)
  
  # if root id was not available
  if(is.null(parent_id)){
    
    # create folder using full path
    googledrive::drive_mkdir(name = paste0(name, collapse = "/"))
    
    dribble_folder <- googledrive::drive_find()
    
  } else {
    
    for (i in seq_along(name)){
      #create folder using parent id
      googledrive::drive_mkdir(name = name[i],
                               path = googledrive::as_id(parent_id))
      cat("\n")
      
      # get folder dribble
      dribble_folder <- googledrive::drive_find(
        q = c(paste0("'", parent_id,"' in parents"), 
              "mimeType = 'application/vnd.google-apps.folder'",
              paste0("name = '", name[i],"'")),
        team_drive = team_drive)
      
      # use folder id as parent for the next folder
      parent_id <- dribble_folder$id
    }
  }
  
  return(dribble_folder)
}

#----    get_root_id    ----

#' Get root id
#'
#' Gets drive id of the root folder. The id is obtained from the 'parents' field
#' in the dribble object listing elements in the root directory. If no element
#' is available in the root folder, id can not be retrieved.
#'
#' @inheritParams upload_rmd
#' @return A drive_id string with the id of the root folder. Note that NULL is
#'   returned, instead, if no element was available in the root folder.
#' @noRd
#' 
get_root_id <- function(team_drive = NULL){
  
  # get elements with root as parent folder
  dribble <- googledrive::drive_find(q = c("'root' in parents"),
                                     team_drive = team_drive)
  
  if (nrow(dribble) > 0){
    id_root <- googledrive::as_id(dribble$drive_resource[[1]]$parents[[1]])
  } else {
    id_root <- NULL
  }
  
  return(id_root)
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

# Messages Utils -----

main_process <- function(message){
  cat(cli::cat_rule(message), "\n")
}

emph_file <- function(file){
  cli::col_blue(basename(file))
} 

sub_process <- function(message){
  cli::cli_li(message)
}

start_process <- function(message){
  cli::cat_bullet(bullet_col = "#8E8E8E", message)
}

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


