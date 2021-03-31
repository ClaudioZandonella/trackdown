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
#' existing file see \code{\link{update_file}}. It is possible to upload also
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
  
  return(res)
}

#----    update_file    ----

#' Updates file in Google Drive
#'
#' Replaces the content of an existing file in Google Drive with the contents of
#'   a local file.
#'
#' \emph{Use with caution as tracked changes in the Google Drive file will be lost!}
#'
#' @inheritParams upload_file
#' 
#' @return NULL
#' @export
#'
update_file <- function(file,
                        gfile = NULL,
                        gpath = "trackdown",
                        team_drive = NULL,
                        hide_code = FALSE,
                        path_output = NULL) {
  
  main_process(paste("Uploading files to", cli::col_magenta("Google Drive")))
  
  #---- check file ----
  # check local file exists and get file info
  check_file(file)
  file_info <- get_file_info(file = file)
  
  # get dribble info and check there is no file with same name in drive 
  gfile <- ifelse(is.null(gfile), yes = file_info$file_basename, no = gfile)
  dribble_file <- get_dribble_info(gfile = gfile,
                                   path = path, 
                                   team_drive = team_drive)
  eval_no_dribble(dribble_file$file, gfile)
  
  
  #---- check output ----
  if (!is.null(path_output)) {
    # check whether output exists and get file info
    check_file(path_output)
    output_info <- get_file_info(file = path_output)
    # check output in drive
    gfile_output <- paste0(gfile, "-output")
    dribble_output <- get_dribble_info(gfile = gfile_output,
                                       path = path, 
                                       team_drive = team_drive)
    eval_no_dribble(dribble_output$file, gfile_output)
  }
  
  #---- upload document ----
  res <- upload_document(
    file = file, 
    file_info = file_info, 
    gfile = gfile, 
    dribble_document = dribble_file, 
    hide_code = hide_code, 
    update = FALSE)
  
  #---- upload output ----
  if (!is.null(path_output)) {
    dribble_output <- upload_output(
      path_output = path_output,
      output_info = output_info, 
      gfile_output = gfile_output,
      dribble_output = dribble_output, 
      update = FALSE)
    
    res <- rbind(res, dribble_output)
  }
  
  #---- end ----
  finish_process("Process completed!")
  
  return(res)
  #-------
  
  # check whether local file exists and get file info
  check_file(file)
  file_info <- get_file_info(file = file)
  
  # check gfile name
  gfile <- ifelse(is.null(gfile), yes = file_info$file_basename, no = gfile)
  
  # check whether file on Google Drive exists
  dribble <- get_dribble_info(gfile, path, team_drive)
  check_gfile(dribble)
  
  # check whether user really wants to replace file in Google Drive
  response <- utils::menu(
    c("Yes", "No"),
    title = paste(
      "Updating the file in Google Drive will overwrite its current content.",
      "You might lose tracked changes. Do you want to proceed?"
    )
  )
  
  if (response == 1) {
    
    main_process(paste("Uploading", emph_file(file), "with local changes..."))
    
    # create .temp-file to upload
    temp_file <- file.path(file_info$path, paste0(".temp-", basename(file), ".txt"))
    file.copy(file, temp_file, overwrite = T)
    # read document lines
    document <- readLines(temp_file, warn = FALSE)
    
    # We need to extract chunks in both cases
    if(isTRUE(hide_code) || isTRUE(path_output)){
      
      start_process("Removing chunks...")
      
      # create .trackdown folder with info about chunks
      init_trackdown(document = document,
                     file_info = file_info)
      
      if (isTRUE(hide_code)) {
        hide_code(document = document,
                  local_path = file_info$path)
        
        finish_process("Chunks removed!")
      }
      
      if (isTRUE(path_output)) {
        
        # knit uploaded pdf named .report_temp.Rmd
        knit_report(local_path = file_info$path) 
        
        # check if the file pdf report is already present
        dribble_report <- get_dribble_info(paste0(gfile, "_report.pdf"), 
                                      path = path, 
                                      team_drive = team_drive) 
    
        if(nrow(dribble_report) < 1){ 
          
          # get dribble of the parent
          path <- get_parent_dribble(path = path, 
                                     team_drive = team_drive)
          
          # upload local file to Google Drive
          googledrive::drive_upload(
            media = file.path(file_info$path, ".trackdown/report_temp.pdf"),
            path = path,
            name = paste0(gfile, "_report.pdf"),
            type = "pdf",
            verbose = F
          )
          
          finish_process(paste(emph_file(file), "pdf report uploaded!"))
          
        } else{
          
          # update local file to Google Drive
          googledrive::drive_update(
            file = dribble_report,
            media = file.path(file_info$path, ".trackdown/report_temp.pdf"),
            verbose = F
          )
          
          finish_process(paste(emph_file(file), "pdf report updated!"))
        }
        
      file.remove(file.path(file_info$path, ".report_temp.Rmd"))
      }
    }
    
    # upload local file to Google Drive
    googledrive::drive_update(file = dribble, 
                              media = temp_file,
                              verbose = F)
    
    invisible(file.remove(temp_file))
  }
  
  finish_process(paste(emph_file(file), "updated!"))
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
#' @param path character. (Sub)directory in My Drive or a Team Drive (optional).
#' @param team_drive character. The name of a Google Team Drive (optional).
#' @param restore_chunks logical value indicating whether to restore code chunks
#'   in the document.
#'   
#' @return `TRUE` if file from Google Drive was saved, `FALSE` otherwise
#' @export
#'
download_file <- function(file,
                          gfile = NULL,
                          path = "trackdown",
                          team_drive = NULL,
                          restore_chunks = FALSE) {
  
  main_process(paste("Downloading", emph_file(file), "with online changes..."))

  # check whether local file exists and get file info
  file_info <- get_file_info(file = file)
  
  # check gfile name
  gfile <- ifelse(is.null(gfile), yes = file_info$file_basename, no = gfile)
  
  # check whether file on Google Drive exists
  dribble <- get_dribble_info(gfile, path, team_drive)
  check_gfile(dribble)
  
  # download file from Google Drive
  googledrive::drive_download(
    file = dribble,
    type = "text/plain",
    path = file.path(file_info$path, paste0(".temp-", basename(file))),
    overwrite = TRUE,
    verbose = F
  )
  temp_file <- file.path(file_info$path, paste0(".temp-", basename(file), ".Rmd"))
  file.rename(file.path(file_info$path, paste0(".temp-", basename(file), ".txt")),
              temp_file)
  
  if (restore_chunks) {
    restore_chunk(temp_file)
  }
  
  sanitize_gfile(temp_file)
  
  # compare with and replace local file
  if (!check_identity(local_path = file_info$path,
                      local_file = file_info$file_name)) {
    file.rename(temp_file, paste0(file, ".Rmd"))
    
    finish_process(paste(emph_file(file), "updated with online changes!"))
    
    changed = TRUE
  } else {
    
    cli::cli_alert_danger(paste("The local", emph_file(file), "is identical with the Google Drive version", cli::col_red("Aborting...")))
    file.remove(temp_file)
    changed = FALSE
  }
  
  return(invisible(changed)) # to retun a invisible TRUE/FALSE for rendering
}

#----    render_file    ----

#' Render file from GoogleDrive
#'
#' Renders file from GoogleDrive if there have been edits
#' 
#' @inheritParams upload_file
#' @param restore_chunks logical value indicating whether to restore code chunks
#'   in the document.
#' @return NULL
#' @export
#'
render_file <- function(file,
                        gfile = basename(file),
                        gpath = "trackdown",
                        team_drive = NULL,
                        restore_chunks = FALSE) {
  
  
  
  changed <- download_file(file = file, 
                           gfile = gfile, 
                           path = gpath, 
                           team_drive = team_drive,
                           restore_chunks =  restore_chunks)
  if (changed) {
    
    rmarkdown::render(paste0(file, ".Rmd"), quiet = T)
    
    finish_process(paste(emph_file(file), "donwloaded and rendered!"))
  }
}

#----    final_file    ----

#' Upload final compiled document on Google Drive
#'
#' Render the final file and upload the overall version to the specified folder
#' 
#' @inheritParams upload_file
#' @return NULL
#' @export
#' 

final_file <- function(file,
                       gpath = "trackdown",
                       team_drive = NULL) {
  
  main_process(paste0("Uploading the final version of ", emph_file(local_file), "..."))
  
  gfile <- basename(file)
  
  # get dribble of the parent
  gpath <- get_dribble_info(gpath)
  
  # check whether local file exists
  local_path <-  dirname(file)
  local_file <- paste0(basename(file), ".Rmd")
  check_file(file.path(local_path, local_file))
  
  # search for gfile_final
  
  dribble <- googledrive::drive_find(q = c(paste0("'", gpath$id,"' in parents", collapse = " and "),
                                paste0("name contains ", "'", gfile, "_final", "'")),
                          team_drive = team_drive)
  
  start_process("Rendering document...")
  
  final_file <- rmarkdown::render(file.path(local_path, local_file),
                                  output_file = paste0(basename(file), "_final"),
                                  quiet = T)
  
  # check if the document is html and if chrome is installed
  
  if (stringr::str_detect(basename(final_file), ".html")){
    if (!is.null(pagedown::find_chrome())) {
      
      # print knitted html to pdf
      final_file <-pagedown::chrome_print(file.path(local_path, basename(final_file)))
      
    } else {
      cli::cli_alert_danger("Google Chrome is not installed, uploading html file...")
    }
  }
  
  if (nrow(dribble) < 1) { 
    
    googledrive::drive_upload(
      media = file.path(local_path, basename(final_file)),
      path = gpath,
      name = basename(final_file),
      verbose = F
    )
    
    finish_process(paste(emph_file(file), "final version uploaded!"))
    
  } else{
    
    update_file <- utils::menu(c("Yes", "No"),
                title = paste("The", basename(final_file), "is already present on Google Drive. Do you want to update it?"))
    
    if (update_file == 1) {
      
      # update local file to Google Drive
      googledrive::drive_update(
        file = dribble,
        media = file.path(local_path, basename(final_file)),
        verbose = F
      )
      
      finish_process(paste(emph_file(file), "final version updated!"))
      
    } else
      
      cli::cli_alert_warning("Updating aborted!")
  }
}
