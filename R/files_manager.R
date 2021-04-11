#############################
####    Files Manager    ####
#############################

#----    upload_file    ----

#' Upload file to Google Drive for collaborative writing and editing
#'
#' Uploads a local file to Google Drive as a plain text document. Will only
#' upload the file if it doesn't already exist in the chosen location. By
#' default files are uploaded in the folder "trackdown", if is not available on
#' Google Drive, permission to create is required to the user. To update an
#' existing file see \code{\link{update_file}}. It is also possible to upload
#' the output (pdf or html) of the file specifying the \code{path_output}
#' argument. In case of html files, if Chrome is available, users can decide to
#' upload a pdf version of the html file.
#'
#' @param file character. The path of a local `.Rmd` or `Rnw` file.
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param gpath character. (Sub)directory in My Drive or a Team Drive (optional).
#'   By default files are uploaded in the folder "trackdown". To specify another
#'   folder the full path is required (e.g., "trackdown/my_folder"). Use
#'   \code{NULL} to upload directly at the root level, although it is not
#'   recommended.
#' @param team_drive character. The name of a Google Team Drive (optional).
#' @param hide_code logical value indicating whether to remove code from the
#'   text document (chunks and header). Placeholders of type "[[chunk-<name>]]"
#'   are displayed instead.
#' @param  path_output default NULL, specify the path to the output to upload
#'   together with the other file. PDF are directly uploaded, HTML can be first
#'   converted into PDF if Chrome is available.
#'   
#' @return a dribble of the uploaded file (and output if specified)
#' 
#' @export
#' 

upload_file <- function(file,
                        gfile = NULL,
                        gpath = "trackdown",
                        team_drive = NULL,
                        hide_code = FALSE,
                        path_output = NULL) {
  
  main_process(paste("Uploading files to", cli::col_magenta("Google Drive")))
  
  #---- check document info ----
  document <- evaluate_file(file = file, 
                            gfile = gfile, 
                            gpath = gpath, 
                            team_drive = team_drive, 
                            test = "none")
  
  
  #---- check output info----
  if (!is.null(path_output)) {
    output <- evaluate_file(file = path_output, 
                            gfile = paste0(document$gfile, "-output"),  # name based on the correct gfile of the document
                            gpath = gpath, 
                            team_drive = team_drive, 
                            test = "none")
  }
  
  #---- upload document ----
  res <- upload_document(
    file = document$file, 
    file_info = document$file_info, 
    gfile = document$gfile, 
    dribble_document = document$dribble_info, 
    hide_code = hide_code, 
    update = FALSE)
  
  #---- upload output ----
  if (!is.null(path_output)) {
    dribble_output <- upload_output(
      path_output = output$file,
      output_info = output$file_info, 
      gfile_output = output$gfile,
      dribble_output = output$dribble_info, 
      update = FALSE)
    
    res <- rbind(res, dribble_output)
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
#' \code{path_output} argument.
#'
#' \emph{Use with caution as tracked changes in the Google Drive file will be lost!}
#'
#' @inheritParams upload_file
#' 
#' @return a dribble of the uploaded file (and output if specified)
#' @export
#'

update_file <- function(file,
                        gfile = NULL,
                        gpath = "trackdown",
                        team_drive = NULL,
                        hide_code = FALSE,
                        path_output = NULL) {
  
  main_process(paste("Updating files to", cli::col_magenta("Google Drive")))
  
  #---- check document info ----
  document <- evaluate_file(file = file, 
                            gfile = gfile, 
                            gpath = gpath, 
                            team_drive = team_drive, 
                            test = "single")
  
  
  #---- check output info----
  if (!is.null(path_output)) {
    output <- evaluate_file(file = path_output, 
                            gfile = paste0(document$gfile, "-output"),  # name based on the correct gfile of the document
                            gpath = gpath, 
                            team_drive = team_drive, 
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
      dribble_output = output$dribble_info, 
      update = update)
    
    res <- rbind(res, dribble_output)
  }
  
  #---- end ----
  finish_process("Process completed!")
  
  return(invisible(res))
}

#----    download_file    ----

#' Downloads from Google Docs
#'
#' Downloads a text file from Google Drive and saves it as a local
#'   file if the local file does not exist or differs from file in Google Drive.
#'
#' @param file character. The path (without file extension) of a local `.Rmd`
#'   file.
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param gpath character. (Sub)directory in My Drive or a Team Drive (optional).
#' @param team_drive character. The name of a Google Team Drive (optional).
#'   
#' @return `TRUE` if file from Google Drive was saved, `FALSE` otherwise
#' @export
#' 

download_file <- function(file,
                          gfile = NULL,
                          gpath = "trackdown",
                          team_drive = NULL) {
  
  main_process(paste("Downloading", emph_file(file), "with online changes..."))
  
  #---- check document info ----
  document <- evaluate_file(file = file, 
                            gfile = gfile, 
                            gpath = gpath, 
                            team_drive = team_drive, 
                            test = "single")
  
  
  #---- check user ----
  
  # check whether user really wants to replace file in Google Drive
  if(interactive()){
    response <- utils::menu(
      c("Yes", "No"),
      title = paste("Updating the file in Google Drive will overwrite its current content.",
                    "You might lose tracked changes. Do you want to proceed?"))
    
    if (response == 2L) {
      cli::cli_alert_danger("Process arrested")
      return(NULL)
    }
  }
  
  #---- download document ----

  # sub_process("Downloading...")
  
  downloaded_file <- file.path(document$file_info$path,
                               paste0(".temp-", document$file_info$file_basename, ".txt"))
  
  # download file from Google Drive
  googledrive::drive_download(
    file = document$dribble_info$file,
    type = "text/plain",
    path = downloaded_file,
    overwrite = TRUE,
    verbose = F
  )
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
    finish_process(paste(emph_file(file), "updated with online changes!"))
    changed = TRUE
  } else {
    cli::cli_alert_danger(paste("The local", emph_file(file), "is identical with the Google Drive version", cli::col_red("Aborting...")))
    # remove temp-file
    invisible(unlink(temp_file))
    changed = FALSE
  }
  
  #---- end ----
  finish_process("Process completed!")
  return(invisible(changed)) # to retun a invisible TRUE/FALSE for rendering
}

#----    render_file    ----

#' Render file from GoogleDrive
#'
#' Renders file from GoogleDrive if there have been edits
#' 
#' @inheritParams upload_file
#' @return NULL
#' @export
#'

render_file <- function(file,
                        gfile = basename(file),
                        gpath = "trackdown",
                        team_drive = NULL) {
  
  
  
  changed <- download_file(file = file, 
                           gfile = gfile, 
                           gpath = gpath, 
                           team_drive = team_drive)
  if (changed) {
    
    rmarkdown::render(paste0(file, ".Rmd"), quiet = T)
    
    finish_process(paste(emph_file(file), "donwloaded and rendered!"))
  }
}

#----
