#' Upload `.Rmd` file to Google Drive for collaborative editing
#'
#' Uploads a local `.Rmd` file to Google Drive as a plain text document.
#'   Will only upload the file if it doesn't already exist in the chosen
#'   location. To update an existing file [update_rmd].
#'
#' @param file character. The name (without file extension) of a local `.Rmd`
#'   file.
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param path character. (Sub)directory in My Drive or a Team Drive (optional).
#' @param team_drive character. The name of a Google Team Drive (optional).
#'
#' @return NULL
#' @export
#'
upload_rmd <- function(file,
                       gfile = basename(file),
                       path = NULL,
                       team_drive = NULL,
                       hide_chunks = FALSE,
                       upload_report = FALSE) {
  
  # check whether local file exists
  local_file <- paste0(file, ".Rmd")
  check_file(local_file)
  
  # check whether file on Google Drive exists
  dribble <- get_dribble(gfile, path, team_drive)
  if (nrow(dribble) > 0) {
    stop(
      "a file with this name already exists in GoogleDrive: ",
      sQuote(gfile),
      ". Did you mean to use `update_rmd()`",
      call. = FALSE
    )
  }
  
  # upload local file to Google Drive
  if (!is.null(path)) {
    path <- get_path_dribble(path = path, team_drive = team_drive)
  } else if (is.null(path) & !is.null(team_drive)) {
    path <- googledrive::team_drive_find(team_drive)
  } else {
    path <- "/"
  }
  
  temp_file <- paste0(".temp-", basename(file), ".txt") # create temp file (moved from below)
  file.copy(local_file, temp_file, overwrite = T)
  
  if (hide_chunks) {
    init_rmdrive(local_file) # init .rmdrive folder
    hide_chunk(temp_file)
    
    if (upload_report) {
      
      upload_report()
      
      googledrive::drive_upload(
        media = ".rmdrive/report_temp.pdf",
        path = path,
        name = paste0(gfile, "_report.pdf"),
        overwrite = T
      )
      
      file.remove(".report_temp.Rmd")
      
    }
  }
  googledrive::drive_upload(
    media = temp_file,
    path = path,
    name = gfile,
    type = "document"
  )
  file.remove(temp_file)
}


#' Updates `.Rmd` file in Google Drive
#'
#' Replaces the content of an existing file in Google Drive with the contents of
#'   a local `.Rmd` file.
#'
#' *Use with caution as tracked changes in the Google Drive file will be lost!*
#'
#' @inheritParams upload_rmd
#' @return NULL
#' @export
#'
update_rmd <- function(file,
                       gfile = basename(file),
                       path = NULL,
                       team_drive = NULL,
                       hide_chunks = FALSE,
                       update_report = FALSE) {
  # check whether local file exists
  local_file <- paste0(file, ".Rmd")
  check_file(local_file)
  
  # check whether file on Google Drive exists
  dribble <- get_dribble(gfile, path, team_drive)
  check_gfile(dribble)
  
  # check whether user really wants to replace file in Google Drive
  response <- menu(
    c("Yes", "No"),
    title = paste(
      "Updating the file in Google Drive will overwrite its current content.",
      "You might lose tracked changes. Do you want to proceed?"
    )
  )
  
  if (response == 1) {
    # upload local file to Google Drive
    temp_file <- paste0(".temp-", basename(file), ".txt")
    file.copy(local_file, temp_file, overwrite = T) # overwrite temp file if interrupted
    
    if (hide_chunks) {
      init_rmdrive(local_file) # init .rmdrive folder
      hide_chunk(temp_file)
      
      if(update_report){
        
        upload_report()
        
        dribble_report <- get_dribble(paste0(gfile, "_report.pdf"), path, team_drive)
        
        googledrive::drive_update(
          file = dribble_report,
          media = ".rmdrive/report_temp.pdf"
        )
        
        file.remove(".report_temp.Rmd")
      }
    }
    
    googledrive::drive_update(file = dribble, media = temp_file)
    file.remove(temp_file)
  }
}

#' Downloads `.Rmd` from Google Docs
#'
#' Downloads a text file from Google Drive and saves it as a local `.Rmd`
#'   file if the local file does not exist or differs from file in Google Drive.
#'
#' @inheritParams upload_rmd
#' @return `TRUE` if file from Google Drive was saved, `FALSE` otherwise
#' @export
#'
download_rmd <- function(file,
                         gfile = basename(file),
                         path = NULL,
                         team_drive = NULL,
                         restore_chunks = FALSE) {
  # check whether file on Google Drive exists
  dribble <- get_dribble(gfile, path, team_drive)
  check_gfile(dribble)
  
  # download file from Google Drive
  googledrive::drive_download(
    file = dribble,
    type = "text/plain",
    path = paste0("", ".temp-", basename(file)),
    overwrite = TRUE
  )
  temp_file <- paste0(".temp-", basename(file), ".Rmd")
  file.rename(paste0(".temp-", basename(file), ".txt"), temp_file)
  
  if (restore_chunks) {
    restore_chunk(temp_file)
  }
  
  sanitize_gfile(temp_file)
  
  # compare with and replace local file
  if (!check_identity(file)) {
    file.rename(temp_file, paste0(file, ".Rmd"))
    TRUE
  } else {
    message("The local Rmd file is identical with the file from Google Drive. ",
            "Aborting...")
    file.remove(temp_file)
    FALSE
  }
}

#' Render Rmd file from GoogleDrive
#'
#' Renders Rmd file from GoogleDrive if there have been edits
#'
#' @inheritParams upload_rmd
#' @return NULL
#' @export
#'
render_rmd <- function(file,
                       gfile = basename(file),
                       path = NULL,
                       team_drive = NULL) {
  changed <- download_rmd(file, gfile, path, team_drive)
  if (changed) {
    rmarkdown::render(paste0(file, ".Rmd"))
  }
}

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