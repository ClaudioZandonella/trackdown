#############################
####    Files Manager    ####
#############################

#----    upload_file    ----

#' Upload file to Google Drive for collaborative writing and editing
#'
#' Uploads a local file to Google Drive as a plain text document. Will only
#' upload the file if it doesn't already exist in the chosen location. By
#' default files are uploaded in the folder "trackdown", if is not available on
#' Google Drive, permission to create it is required to the user. To update an
#' already existing file see \code{\link{update_file}}. It is also possible to
#' upload the output (pdf or html) of the file specifying the \code{path_output}
#' argument. In case of html files, if \code{pagedown} package and Chrome are
#' available, users can decide to upload a pdf version of the html file.\cr\cr
#' To know more about \code{trackdown} workflow and features see
#' \code{\link{trackdown-package}} help page.
#' 
#' @param file character. The path of a local `.Rmd` or `.Rnw` file.
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param gpath character. (Sub)directory in My Drive or a shared drive
#'   (optional). By default files are uploaded in the folder "trackdown". To
#'   specify another folder the full path is required (e.g., 
#'   "trackdown/my_folder"). Use \code{NULL} to upload directly at the root
#'   level, although it is not recommended.
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#' @param hide_code logical value indicating whether to remove code from the
#'   text document (chunks and header). Placeholders of type "[[chunk-<name>]]"
#'   are displayed instead.
#' @param  path_output default \code{NULL}, specify the path to the output to upload
#'   together with the other file. PDF are directly uploaded, HTML can be first
#'   converted into PDF if package \code{pagedown} and Chrome are available.
#'   
#' @return a dribble of the uploaded file (and output if specified)
#' 
#' @export
#' 

upload_file <- function(file,
                        gfile = NULL,
                        gpath = "trackdown",
                        shared_drive = NULL,
                        hide_code = FALSE,
                        path_output = NULL) {
  
  main_process(paste("Uploading files to", cli::col_magenta("Google Drive")))
  
  gpath <- sanitize_path(gpath) # remove possible final "/"
  
  #---- check document info ----
  document <- evaluate_file(file = file, 
                            gfile = gfile, 
                            gpath = gpath, 
                            shared_drive = shared_drive, 
                            test = "none")
  
  check_supported_documents(document$file_info)
  
  #---- check output info----
  if (!is.null(path_output)) {
    output <- evaluate_file(file = path_output, 
                            gfile = paste0(document$gfile, "-output"),  # name based on the correct gfile of the document
                            gpath = gpath, 
                            shared_drive = shared_drive, 
                            test = "none")
  }
  
  #---- upload document ----
  res <- upload_document(
    file = document$file, 
    file_info = document$file_info, 
    gfile = document$gfile,
    gpath = gpath,
    dribble_document = document$dribble_info, 
    hide_code = hide_code, 
    update = FALSE)
  
  #---- upload output ----
  if (!is.null(path_output)) {
    dribble_output <- upload_output(
      path_output = output$file,
      output_info = output$file_info, 
      gfile_output = output$gfile,
      gpath = gpath,
      dribble_output = output$dribble_info, 
      update = FALSE)
    
    res[2, ] <- dribble_output
    res <- googledrive::as_dribble(res)
  }
  
  #---- end ----
  finish_process("Process completed!")
  
  return(invisible(res))
}

#----    update_file    ----

#' Updates file in Google Drive
#'
#' Replaces the content of an existing file in Google Drive with the contents of
#' a local file. It is also possible to update (or upload if not already
#' present) the output (pdf or html) of the file specifying the
#' \code{path_output} argument. In case of html files, if \code{pagedown}
#' package and Chrome are available, users can decide to upload a pdf version of
#' the html file.\cr\cr
#' \emph{Use with caution as tracked changes in the Google Drive file will be
#' lost!}\cr\cr 
#' To know more about \code{trackdown} workflow and features see
#' \code{\link{trackdown-package}} help page.
#'
#' @inheritParams upload_file
#' 
#' @return a dribble of the uploaded file (and output if specified)
#' @export
#'

update_file <- function(file,
                        gfile = NULL,
                        gpath = "trackdown",
                        shared_drive = NULL,
                        hide_code = FALSE,
                        path_output = NULL) {
  
  main_process(paste("Updating files to", cli::col_magenta("Google Drive")))
  
  gpath <- sanitize_path(gpath) # remove possible final "/"
  
  #---- check document info ----
  document <- evaluate_file(file = file, 
                            gfile = gfile, 
                            gpath = gpath, 
                            shared_drive = shared_drive, 
                            test = "single")
  
  check_supported_documents(document$file_info)
  
  #---- check output info----
  if (!is.null(path_output)) {
    output <- evaluate_file(file = path_output, 
                            gfile = paste0(document$gfile, "-output"),  # name based on the correct gfile of the document
                            gpath = gpath, 
                            shared_drive = shared_drive, 
                            test = "both")
  }
  
  #---- check user ----
  
  # check whether user really wants to replace file in Google Drive
  if(interactive()){
    response <- utils::menu(c("Yes", "No"),
      title = paste("Updating the file in Google Drive will overwrite its current content.",
                    "You might lose tracked changes. Do you want to proceed?"))
    
    if (response == 2L) {
      cli::cli_alert_danger("Process arrested")
      return(NULL)
    }
  }
  
  #---- upload document ----
  res <- upload_document(
    file = document$file, 
    file_info = document$file_info, 
    gfile = document$gfile, 
    gpath = gpath,
    dribble_document = document$dribble_info, 
    hide_code = hide_code, 
    update = TRUE)
  
  #---- upload output ----
  if (!is.null(path_output)) {
    update <- ifelse(nrow(output$dribble_info$file) > 0, 
                     yes = TRUE, no = FALSE)
    
    dribble_output <- upload_output(
      path_output = output$file,
      output_info = output$file_info, 
      gfile_output = output$gfile,
      gpath = gpath,
      dribble_output = output$dribble_info, 
      update = update)
    
    res[2, ] <- dribble_output
    res <- googledrive::as_dribble(res)
  }
  
  #---- end ----
  finish_process("Process completed!")
  
  return(invisible(res))
}

#----    download_file    ----

#' Downloads from Google Docs
#'
#' Download edited version of a file from Google Drive updating the local
#' version with the new changes.\cr\cr
#' \emph{Use with caution as local version of the file will be
#' overwritten!}\cr\cr 
#' To know more about \code{trackdown} workflow and features see
#' \code{\link{trackdown-package}} help page.
#'
#' @inheritParams upload_file
#'
#' @return `TRUE` if file from Google Drive was saved, `FALSE` otherwise
#' 
#' @export
#' 

download_file <- function(file,
                          gfile = NULL,
                          gpath = "trackdown",
                          shared_drive = NULL) {
  
  main_process(paste("Downloading", emph_file(file), "with online changes..."))
  
  gpath <- sanitize_path(gpath) # remove possible final "/"
  
  #---- check document info ----
  document <- evaluate_file(file = file, 
                            gfile = gfile, 
                            gpath = gpath, 
                            shared_drive = shared_drive, 
                            test = "single")
  
  check_supported_documents(document$file_info)
  
  #---- check user ----
  
  # check whether user really wants to download file from Google Drive
  if(interactive()){
    response <- utils::menu(
      c("Yes", "No"),
      title = paste("Downloading the file from Google Drive will overwrite local file.",
                    "Do you want to proceed?"))
    
    if (response == 2L) {
      cli::cli_alert_danger("Process arrested")
      return(NULL)
    }
  }
  
  #---- download document ----

  # sub_process("Downloading...")
  
  downloaded_file <- file.path(document$file_info$path,
                               paste0(".temp-", document$file_info$file_basename, ".txt"))
  
  googledrive::local_drive_quiet() # suppress messages from googledrive
  
  # download file from Google Drive
  googledrive::drive_download(
    file = document$dribble_info$file,
    type = "text/plain",
    path = downloaded_file,
    overwrite = TRUE)
  
  temp_file <- file.path(document$file_info$path, 
                         paste0(".temp-", document$file_info$file_name))
  file.rename(downloaded_file, temp_file)
  
  #---- restore file ----
  
  restore_file(temp_file = temp_file, 
               file_name = document$file_info$file_name,
               path = document$file_info$path)

  
  #---- compare and replace ----
  
  if (!check_identity(temp_file = temp_file, local_file = document$file)) {
    file.rename(temp_file, document$file)
    finish_process(paste(cli::col_blue(file), "updated with online changes!"))
    finish_process("Process completed!")
    changed <- TRUE
  } else {
    cli::cli_alert_danger(paste("The local", cli::col_blue(file), "is identical with the Google Drive version", cli::col_red("Aborting...")))
    # remove temp-file
    invisible(unlink(temp_file))
    changed <-  FALSE
  }
  
  #---- end ----
  return(invisible(changed)) # to retun a invisible TRUE/FALSE for rendering
}

#----    render_file    ----

#' Render file from Google Drive
#'
#' Render file from Google Drive if there have been edits\cr\cr
#' To know more about \code{trackdown} workflow and features see
#' \code{\link{trackdown-package}} help page.
#' 
#' @inheritParams upload_file
#' 
#' @return `TRUE` if file from Google Drive was saved and rendered, `FALSE`
#'   otherwise
#' @export
#'

render_file <- function(file,
                        gfile = basename(file),
                        gpath = "trackdown",
                        shared_drive = NULL) {
  
  gpath <- sanitize_path(gpath) # remove possible final "/"
  
  changed <- download_file(file = file, 
                           gfile = gfile, 
                           gpath = gpath, 
                           shared_drive = shared_drive)
  if (changed) {
    rmarkdown::render(file, quiet = TRUE)
    finish_process(paste(cli::col_blue(file), "donwloaded and rendered!"))
  }
  
  return(invisible(changed))
}

#----
