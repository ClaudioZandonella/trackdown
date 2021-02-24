#############################
####    Files Manager    ####
#############################

#----    upload_file    ----

#' Upload file to Google Drive for collaborative editing
#'
#' Uploads a local file to Google Drive as a plain text document. Will
#' only upload the file if it doesn't already exist in the chosen location. By
#' default files are uploaded in the folder "rmdrive", if is not available on
#' Google Drive, permission to create is required to the user. To update an
#' existing file \code{\link{update_file}}.
#'
#' @param file character. The path (without file extension) of a local `.Rmd`
#'   file.
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param path character. (Sub)directory in My Drive or a Team Drive (optional).
#'   By default files are uploaded in the folder "rmdrive". To specify another
#'   folder the full path is required (e.g., "rmdrive/my_folder"). Use
#'   \code{NULL} to upload directly at the root level, although it is not
#'   recommended.
#' @param team_drive character. The name of a Google Team Drive (optional).
#' @param hide_chunks logical value indicating whether to remove code chunks
#'   from the text document. Placeholders of  type "[[chunck_<name>]]" are
#'   displayed instead.
#' @param  upload_report logical value indicating whether to upload an
#'   additional pdf file with the chunks output (e.g., figures and tables). Note
#'   that this require the time to compile the document.
#'
#' @return NULL
#' @export
#'
upload_file <- function(file,
                        gfile = NULL,
                        path = "rmdrive",
                        team_drive = NULL,
                        hide_chunks = FALSE,
                        upload_report = FALSE) {
  
  main_process(paste("Uploading files to", cli::col_magenta("Google Drive")))
  
  # check whether local file exists and get file info
  check_file(file)
  file_info <- get_file_info(file = file)
  
  # check gfile name
  gfile <- ifelse(is.null(gfile), yes = file_info$file_basename, no = gfile)
  
  # get file and parent dribble info
  dribble <- get_dribble_info(gfile = gfile,
                              path = path, 
                              team_drive = team_drive)
  
  
  if (nrow(dribble$file) > 0) {
    stop(
      "a file with this name already exists in GoogleDrive: ",
      sQuote(gfile),
      ". Did you mean to use `update_file()`?",
      call. = FALSE
    )
  }
  
  # create .temp-file to upload
  temp_file <- file.path(file_info$path, 
                         paste0(".temp-", file_info$file_basename, ".txt"))
  file.copy(file, temp_file, overwrite = T)
  
  # We need to extract chunks in both cases
  if(isTRUE(hide_chunks) || isTRUE(upload_report)){
    
    # create .rmdrive folder with info about chunks
    init_rmdrive(file_text = temp_file,
                 file_info = file_info)
    
    if (isTRUE(hide_chunks)) {
      
      start_process("Removing chunks...")
      
      hide_chunk(file_text = temp_file,
                 local_path = file_info$path)
      
      finish_process(paste("Chunks removed from", emph_file(file)))
    }
    
    if (isTRUE(upload_report)) {
      
      # function to knit a temporary report named .report_temp.Rmd
      
      knit_report(local_path = file_info$path) 
      
      googledrive::drive_upload(
        media = file.path(file_info$path, ".rmdrive/report_temp.pdf"),
        path = dribble$parent,
        name = paste0(gfile, "_report.pdf"),
        type = "pdf",
        verbose = F
      )
      
      finish_process(paste(emph_file(file), "pdf report uploaded!"))
      
      file.remove(file.path(file_info$path,".report_temp.Rmd"))
    }
  }
  
  start_process("Uploading main file to Google Drive...")
  
  # upload local file to Google Drive
  googledrive::drive_upload(
    media = temp_file,
    path = dribble$parent,
    name = gfile,
    type = "document",
    verbose = F
  )
  invisible(file.remove(temp_file))
  
  finish_process(paste(emph_file(file), "uploaded!"))
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
#' @return NULL
#' @export
#'
update_file <- function(file,
                        gfile = NULL,
                        path = "rmdrive",
                        team_drive = NULL,
                        hide_chunks = FALSE,
                        upload_report = FALSE) {
  
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
    
    # We need to extract chunks in both cases
    if(isTRUE(hide_chunks) || isTRUE(upload_report)){
      
      start_process("Removing chunks...")
      
      # create .rmdrive folder with info about chunks
      init_rmdrive(file_text = temp_file,
                   file_info = file_info)
      
      if (isTRUE(hide_chunks)) {
        hide_chunk(file_text = temp_file,
                   local_path = file_info$path)
        
        finish_process("Chunks removed!")
      }
      
      if (isTRUE(upload_report)) {
        
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
            media = file.path(file_info$path, ".rmdrive/report_temp.pdf"),
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
            media = file.path(file_info$path, ".rmdrive/report_temp.pdf"),
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
                          path = "rmdrive",
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
                        path = "rmdrive",
                        team_drive = NULL,
                        restore_chunks = FALSE) {
  
  
  
  changed <- download_file(file = file, 
                           gfile = gfile, 
                           path = path, 
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
                       path = "rmdrive",
                       team_drive = NULL) {
  
  main_process(paste0("Uploading the final version of ", emph_file(local_file), "..."))
  
  gfile <- basename(file)
  
  # get dribble of the parent
  path <- get_dribble_info(path)
  
  # check whether local file exists
  local_path <-  dirname(file)
  local_file <- paste0(basename(file), ".Rmd")
  check_file(file.path(local_path, local_file))
  
  # search for gfile_final
  
  dribble <- googledrive::drive_find(q = c(paste0("'", path$id,"' in parents", collapse = " and "),
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
      path = path,
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
