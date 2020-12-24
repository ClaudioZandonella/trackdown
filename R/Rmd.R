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
                       team_drive = NULL) {
  # check whether local file exists
  local_file <- paste0(file, ".Rmd")
  check_file(local_file)
  
  # check whether file on Google Drive exists
  dribble <- get_dribble(gfile, path, team_drive)
  if (nrow(dribble) > 0){
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
  temp_file <- paste0(".temp-", basename(file), ".txt")
  file.copy(local_file, temp_file)
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
                       team_drive = NULL) {
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
    file.copy(local_file, temp_file)
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
                         team_drive = NULL) {
  # check whether file on Google Drive exists
  dribble <- get_dribble(gfile, path, team_drive)
  check_gfile(dribble)
  
  # download file from Google Drive
  googledrive::drive_download(
    file = dribble,
    type = "text/plain",
    path = paste0(".temp-", basename(file)),
    overwrite = TRUE
  )
  temp_file <- paste0(".temp-", basename(file), ".Rmd")
  file.rename(paste0(".temp-", basename(file), ".txt"), temp_file)
  sanitize_gfile(temp_file)
  
  # compare with and replace local file
  if (!check_identity(file)) {
    file.rename(temp_file, paste0(file, ".Rmd"))
    TRUE
  } else {
    message(
      "The local Rmd file is identical with the file from Google Drive. ",
      "Aborting..."
    )
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
