#' Uploads raw rmarkdown for collaborative editing on Google Docs
#'
#' Allows upload of an .Rmd file as to Google Docs as a plain text document
#'
#' @param file The name (without file extension) of an .Rmd you want to upload to Google Docs
#' @param gfile The name (current or desired) of a Google Docs file (must be unique in your google docs account)
#'
#' @return NULL
#' @export
#'
#' @examples
#' upload_rmd(file = "testingfile", gfile = "testingfile-1234")
upload_rmd <- function(file, gfile) {
  file.copy(paste0(file, ".Rmd"), paste0(file, ".txt"))
  googledrive::drive_upload(media = paste0(file, ".txt"), name=gfile, type= "document")
  file.remove(paste0(file, ".txt"))
}

#' Updates raw rmarkdown for collaborative editing on Google Docs
#'
#' Updates the content of an existing Google Docs file with the name gfile
#'
#' @param file The name (without file extension) of an .Rmd you want to upload to Google Docs
#' @param gfile The name (current or desired) of a Google Docs file (must be unique in your google docs account)
#'
#' @return NULL
#' @export
#'
#' @examples
#' update_rmd(file = "testingfile", gfile = "testingfile-1234")
update_rmd <- function(file, gfile) {
  file.copy(paste0(file, ".Rmd"), paste0(file, ".txt"))
  googledrive::drive_update(media = paste0(file, ".txt"), file=gfile)
  file.remove(paste0(file, ".txt"))
}

#' Downloads raw rmarkdown from Google Docs
#'
#' Downloads a Google Docs file and changes the file extension to .Rmd
#'
#' @param file The name (without file extension) of an .Rmd you want to upload to Google Docs
#' @param gfile The name (current or desired) of a Google Docs file (must be unique in your google docs account)
#'
#' @return NULL
#' @export
#'
#' @examples
#' download_rmd(file = "testingfile", gfile = "testingfile-1234")
download_rmd <- function(file, gfile) {
  googledrive::drive_download(file = gfile, type= "text/plain", path = file, overwrite = TRUE)
  file.rename(paste0(file, ".txt"), paste0(file, ".Rmd"))
}
