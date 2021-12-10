################################
####    Utilities Manager   ####
################################


#----    evaluate_file    ----
#' Evaluate File local and Google Drive Information
#'
#' @param file character indicating the path to the local file (or output)
#' @param gfile character indicating the name of a Google Drive file
#' @param gpath character indicating the path in Google Drive
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#' @param test character indicating whether to test no line in dribble ("none"),
#'   single line in dribble ("single") or both condition accepted ("both")
#'
#' @return a list with relevant information 
#'  \itemize{
#'    \item{file - character indicating the path to the local file (or output)}
#'    \item{file_info - list with file info returned from  get_file_info()
#'    function}
#'    \item{gfile - character indicating the corrected gfile naem for the file}
#'    \item{dribble_info - list with dribble info of the file and parent
#'    returned by get_dribble_info() function}
#'  }
#'  
#' @noRd
#'
#' @examples
#' # file
#' file <- "tests/testthat/test_files/examples/example-1.Rmd"
#' 
#' # output
#' file <- "tests/testthat/test_files/examples/example-1.pdf"
#' 
#' evaluate_file(file)
#' 

evaluate_file <- function(file, 
                          gfile = NULL,
                          gpath = "trackdown", 
                          shared_drive = NULL, 
                          test = c("none", "single", "both")){

  test <-  match.arg(test)
  
  # check local file exists and get file info
  check_file(file)
  file_info <- get_file_info(file = file)
  
  # set correct gfile
  gfile <- ifelse(is.null(gfile), yes = file_info$file_basename, no = gfile)
    
  # get dribble info
  dribble_info <- get_dribble_info(gfile = gfile,
                                   path = gpath, 
                                   shared_drive = shared_drive)
  
  # check there is no file (or a single file) with same name in drive
  check_dribble(dribble_info$file, gfile, test = test)
  
  return(list(file = file,
              file_info = file_info,
              gfile = gfile,
              dribble_info = dribble_info))
}

#----    upload_document    ----

#' Upload (or Update) a Document in Google Drive
#'
#' Internal function to upload (or update) a local file to Google Drive as a
#' plain text document. Local file information and Google Drive document
#' information and have to be provided. Option \code{hide_code} allows to
#' remove code chunks from the text document and option \code{update}
#' indicates whether to update file in Google Drive.
#'
#' @param file character. The path (without file extension) of a local `.Rmd`
#'   file.
#' @param file_info list with file info returned from get_file_info() function
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param gpath character indicating the (sub)directory in Google Drive.
#' @param dribble_document A list with two dribble object regarding the gfile
#'   and the parent item.
#' @param hide_code logical value indicating whether to remove code from the
#'   text document (chunks and header). Placeholders of  type "[[chunk-<name>]]"
#'   are displayed instead.
#' @param update logical value indicating whether to update or upload the
#'   document.
#'
#' @return a dribble of the uploaded (or updated) document
#' @noRd
#'
#' @examples
#' file <- "tests/testthat/test_files/examples/example-1.Rmd"
#' file_info <- get_file_info(file)
#' gfile <- "example-1"
#' dribble_document <- get_dribble_info(gfile = gfile, path = "unit_tests/examples")
#' hide_code <- FALSE
#' upload_document(file, file_info, gfile, gpath = "trackdown/examples",
#'                 dribble_document, hide_code, update = TRUE)
#' 

upload_document <- function(file, file_info, 
                            gfile, gpath, dribble_document, 
                            hide_code, update = FALSE){
  #---- temp file ----
  # create .temp-file to upload
  temp_file <- file.path(file_info$path, 
                         paste0(".temp-", file_info$file_basename, ".txt"))
  file.copy(file, temp_file, overwrite = TRUE)
  
  # remove temp-file on exit
  on.exit(invisible(file.remove(temp_file)), add = TRUE)
  
  # read document lines
  document <-  readLines(temp_file, warn = FALSE)
  
  
  #---- hide code ----
  if(isTRUE(hide_code)){
    start_process("Removing code...")
    document <- hide_code(document = document,
                          file_info = file_info)
    finish_process(paste("Code removed from", emph_file(file_info$file_name)))
  }
  
  
  #---- upload document ----
  
  googledrive::local_drive_quiet() # suppress messages from googledrive
  
  # Format document to a single string
  document <- format_document(document, 
                              file_info = file_info, 
                              hide_code = hide_code)
  cat(document, file = temp_file)
  
  
  if(isTRUE(update)){
    start_process("Updating document with local changes  to Google Drive...")
    
    # Update document
    res <- googledrive::drive_update(
      media = temp_file,
      file = dribble_document$file)
    
    finish_process(paste("Document updated at",
                         cli::col_blue(paste(gpath, gfile, sep = "/"))))
  } else {
    start_process("Uploading document to Google Drive...")
    
    # Upload document
    res <- googledrive::drive_upload(
      media = temp_file,
      path = dribble_document$parent,
      name = gfile,
      type = "document")
    
    finish_process(paste("Document uploaded at",
                         cli::col_blue(paste(gpath, gfile, sep = "/"))))
  }
  
  return(res)
}

#----    upload_output    ----

#' Upload (or Update) a Document in Google Drive
#'
#' Internal function to upload (or update) a local file to Google Drive as a
#' plain text document. Local file information and Google Drive document
#' information and have to be provided. Option \code{hide_code} allows to
#' remove code chunks from the text document and option \code{update}
#' indicates whether to update file in Google Drive.
#'
#' @param path_output character. The path (without file extension) of a local
#'   `.Rmd` file.
#' @param output_info list with file info returned from get_file_info() function
#' @param gfile_output character. The name of a Google Drive file (defaults to
#'   local file name).
#' @param gpath character indicating the (sub)directory in Google Drive.
#' @param dribble_output A list with two dribble object regarding the gfile and
#'   the parent item.
#' @param update logical value indicating whether to update or upload the
#'   document.
#' @param .response integer indicating automatic response in non interactive
#'   environment on whether to convert html to pdf (1 = Yes, 2 = No).
#'
#' @return a dribble of the uploaded (or updated) output
#' @noRd
#'
#' @examples
#' # pdf
#' path_output <- "tests/testthat/test_files/examples/example_1.pdf"
#' 
#' # html
#' path_output <- "tests/testthat/test_files/example-1.html"
#' 
#' output_info <- get_file_info(path_output)
#' gfile_output <- "example_1-output"
#' dribble_output <- get_dribble_info(gfile = gfile_output, path = "trackdown/examples")
#' upload_output(path_output, output_info, gfile_output, gpath = "trackdown/examples",
#'               dribble_output, update = FALSE)
#'

upload_output <- function(path_output, output_info, 
                          gfile_output, gpath, dribble_output, 
                          update = FALSE, .response = 2L){
  
  # check if the document is html 
  if (output_info$extension == "html"){
    
    # check if pagedown is available and if chrome is installed
    if(requireNamespace("pagedown", quietly = TRUE) && !does_error(pagedown::find_chrome())){
      
      if(interactive()){
        html2pdf <- utils::menu(c("Yes", "No"),
                                title = paste("Transform HTML to PDF output before uploading?"))
      } else {
        html2pdf <- .response
      }
      
      if(html2pdf == 1L){
        start_process("Converting output to pdf...")
        
        # convert html to pdf
        path_output <- pagedown::chrome_print(path_output,
                                              output = file.path(output_info$path,
                                                                 paste0("temp-output-", output_info$file_basename, ".pdf")))
        output_info <- get_file_info(file = path_output)
        
        # remove temp-output on exit
        on.exit(invisible(file.remove(path_output)), add = TRUE)
      }
      
    } else {
      cli::cli_alert_info("Install package \"pagedown\" to automatically convert HTML to PDF output (Google Chrome is required)")
    }
  }
  
  googledrive::local_drive_quiet() # suppress messages from googledrive
  
  if(isTRUE(update)){
    start_process("Updating output with local changes to Google Drive...")
    
    # Update output
    res <- googledrive::drive_update(
      media = path_output,
      file = dribble_output$file)
    
    finish_process(paste("Output updated at",
                         cli::col_blue(paste(gpath, gfile_output, sep = "/"))))
  } else {
    start_process("Uploading output to Google Drive...")
    
    # Upload output
    res <- googledrive::drive_upload(
      media = path_output,
      path = dribble_output$parent,
      name = gfile_output,
      type = output_info$extension)
    
    finish_process(paste("Output uploaded at",
                         cli::col_blue(paste(gpath, gfile_output, sep = "/"))))
  }
  
  return(res)
}


#----
