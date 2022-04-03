################################
####    Utilities Dribble   ####
################################

#----    get_dribble_info    ----

#' Get dribble Info
#'
#' Given the gfile name, folder, and shared drive, gets a list with the dribble
#' ("Drive tibble") for the file and parent folder.
#'
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param path character. (Sub)directory in My Drive or a shared drive.
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#'
#' @return A list with two dribble object:
#' \itemize{
#'  \item{file} dribble object about the gfile
#'  \item{parent} dribble object about the parent item
#' }
#' 
#' @noRd
#' @seealso [googledrive::dribble()]
#' @examples 
#'  get_dribble_info(gfile = "Hello-World")
#'  get_dribble_info(gfile = "Hello-World", path = "reading_folder")
#'  

get_dribble_info <- function(gfile, path = NULL, shared_drive = NULL) {
  
  parent_dribble <- get_parent_dribble(path = path, shared_drive = shared_drive)
  
  file_dribble <- googledrive::drive_find(
    q = c(paste0("'", parent_dribble$id,"' in parents", collapse = " or "),
          paste0("name = '", gfile,"'")),
    shared_drive = shared_drive)
  
  return(list(file = file_dribble,
              parent = parent_dribble))
}

#----    get_path_dribble    ----

#' Get path dribble
#'
#' Gets dribble ("Drive tibble") for the last folder provided in the path
#' starting from root. If the required folder is not available, options to
#' create it is proposed.
#'
#' @param path character. (Sub)directory in My Drive or a shared drive.
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#' @param .response automatic response in non interactive environment on whether
#'   to create new folder if this do not exist (1 = Yes, 2 = No).
#'   
#' @return A dribble object. Note that multiple lines could be returned if
#'   multiple folders  exist  with the same path.
#' @noRd
#' 
#' @examples 
#'   get_path_dribble(path = "unit_tests")
#'   get_path_dribble(path = "unit_tests/utils_dribble")
#' 

get_path_dribble <- function(path, shared_drive = NULL, .response = 1){
  
  # get sequence of folders
  path <- strsplit(path, split = "/")[[1]]
  
  # get folders id starting from root
  for (i in seq_along(path)){
    # get correct initial settings for root folder
    if(i == 1L) {
      dribble_folder <- get_root_dribble(shared_drive = shared_drive)
    } else {
      dribble_folder <- dribble
    }
    
    dribble <- googledrive::drive_find(
      q = c(paste0("'", dribble_folder$id,"' in parents", collapse = " or "), 
            "mimeType = 'application/vnd.google-apps.folder'",
            paste0("name = '", path[i],"'")),
      shared_drive = shared_drive)
    
    # Check if path is available on drive
    if(nrow(dribble) < 1){
      
      if(interactive()){
        # check whether user wants to create folder in Google Drive
        response <- utils::menu(c("Yes", "No"), title = paste0(
          "Folder ", sQuote(paste0(path, sep = "/",  collapse = "")),
          " does not exist in Google Drive.", " Do you want to create it?"))
      } else {
        response <-  .response
      }
      
      if (response == 2){
        stop_quietly("Process aborted")
      } else {
        
        # evaluate if unique parent folder is available
        if(nrow(dribble_folder) > 1){
          stop(paste0("No unique parent folder ", 
                      sQuote(paste0(path[1:(i-1)], sep = "/",  collapse = "")),
                      " exists in Google Drive - Folder ",
                      sQuote(paste0(path[i:length(path)], sep = "/",  collapse = "")),
                      " can not be created automatically"),
               call. = FALSE)
        } else {
          
          # create folder in google drive and return dribble
          dribble <- create_drive_folder(name = path[i:length(path)],
                                         parent_dribble = dribble_folder, 
                                         shared_drive = shared_drive)
          
          finish_process(paste(cli::col_magenta(
            paste0(path, "/", collapse = "")), " folder created on Google Drive!"))
          
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
#' @param path character. (Sub)directory in My Drive or a shared drive.
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#' @param .response automatic response in non interactive environment on whether
#'   to create new folder if this do not exist (1 = Yes, 2 = No).
#'
#' @return A dribble object.
#'
#' @noRd
#' 
get_parent_dribble <- function(path = NULL, shared_drive = NULL, .response = 1){
  
  # get dribble of the parent folder
  if (!is.null(path)) {
    res <- get_path_dribble(path = path, 
                             shared_drive = shared_drive, 
                             .response = .response)
  } else {
    res <- get_root_dribble(shared_drive)
  }
  
  return(res)
}

#----    create_drive_folder    ----

#' Create a folder in Google Drive
#'
#' Create a folder in Google Drive. 
#' 
#'
#' @param name character vector indicating the sequence of folders to create.
#' @param parent_dribble a dribble of the parent folder or NULL (default to indicate root).
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#'
#' @return A dribble object with information of the created folder.
#' @noRd
#' 
#' @examples  
#' create_drive_folder(name = c("main_folder", "nested_folder"),
#'                     parent_id = "root")
#'       
              
create_drive_folder <- function(name,
                                parent_dribble = NULL,
                                shared_drive = NULL){
  
  googledrive::local_drive_quiet() # suppress messages from googledrive
  
  for (i in seq_along(name)){
    #create folder using parent dribble (NULL if is not available)
    dribble_folder <- googledrive::drive_mkdir(name = name[i],
                                               path = parent_dribble)
    
    # use folder id as parent for the next folder
    parent_dribble <- dribble_folder
    
  }
  
  return(dribble_folder)
}

#----    get_root_dribble    ----

#' Get root dribble
#'
#' Gets drive id of the root folder ("My Drive" or, optionally, a Google Drive
#'   shared drive).
#'
#' @param shared_drive character. The name of a Google Drive shared drive
#'   (optional).
#'
#' @return A dribble of object of the root folder.
#' @noRd
#' 
#' @examples
#'   get_root_dribble()
#' 

get_root_dribble <- function(shared_drive = NULL){
  
  googledrive::local_drive_quiet() # suppress messages from googledrive
  
  if (!is.null(shared_drive)) {
    dribble_root <- googledrive::shared_drive_get(shared_drive)
  } else {
    dribble_root <- googledrive::drive_get(id = "root")
  }
  
  return(dribble_root)
}


#----
