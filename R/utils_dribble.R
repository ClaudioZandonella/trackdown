################################
####    Utilities Dribble   ####
################################

#----    get_dribble_info    ----

#' Get dribble Info
#'
#' Given the gfile name, folder, and Team Drive, gets a list with the dribble
#' ("Drive tibble") for the file and parent folder.
#'
#' @param gfile character. The name of a Google Drive file (defaults to local
#'   file name).
#' @param path character. (Sub)directory in My Drive or a Team Drive.
#' @param team_drive character. The name of a Google Team Drive (optional).
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

get_dribble_info <- function(gfile, path = NULL, team_drive = NULL) {
  
  parent_dribble <- get_parent_dribble(path = path, team_drive = team_drive)
  
  file_dribble <- googledrive::drive_find(
    q = c(paste0("'", parent_dribble$id,"' in parents", collapse = " or "),
          paste0("name = '", gfile,"'")),
    team_drive = team_drive)
  
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
#' @param path character. (Sub)directory in My Drive or a Team Drive.
#' @param team_drive character. The name of a Google Team Drive (optional).
#' @param .response automatic response in non interactive environment on whether
#'   to create new folder if this do not exist (1 = Yes, 2 = No).
#'   
#' @return A dribble object. Note that multiple lines could be returned if
#'   multiple folders  exist  with the same path.
#' @noRd
#' 
#' @examples 
#'   get_path_dribble(path = "reading_folder")
#'   get_path_dribble(path = "reading_folder/my_folder")
#' 

get_path_dribble <- function(path, team_drive = NULL, .response = 1){
  # get sequence of folders
  path <- stringr::str_split(path, pattern = "/", simplify = TRUE)[1,]
  
  # get folders id starting from root
  for (i in seq_along(path)){
    # get correct initial settings for root folder
    if(i == 1L) {
      dribble_folder <- get_root_dribble(team_drive = team_drive)
    } else {
      dribble_folder <- dribble
    }
    
    dribble <- googledrive::drive_find(
      q = c(paste0("'", dribble_folder$id,"' in parents", collapse = " or "), 
            "mimeType = 'application/vnd.google-apps.folder'",
            paste0("name = '", path[i],"'")),
      team_drive = team_drive)
    
    # Check if path is available on drive
    if(nrow(dribble) < 1){
      
      if(interactive()){
        # check whether user wants to create folder in Google Drive
        response <- utils::menu(c("Yes", "No"), title = paste0(
          "Folder ", sQuote(paste0(path, sep = "/",  collapse = "")),
          " does not exists in GoogleDrive.", " Do you want to create it?"))
      } else {
        response = .response
      }
      
      if (response == 2){
        stop_quietly("Process arrested")
      } else {
        
        # evaluate if unique parent folder is available
        if(nrow(dribble_folder) > 1){
          stop(paste0("No unique parent folder ", 
                      sQuote(paste0(path[1:(i-1)], sep = "/",  collapse = "")),
                      " exists in GoogleDrive - Folder ",
                      sQuote(paste0(path[i:length(path)], sep = "/",  collapse = "")),
                      " can not be created automatically"),
               call. = FALSE)
        } else {
          
          # create folder in google drive and return dribble
          dribble <- create_drive_folder(name = path[i:length(path)],
                                         parent_dribble = dribble_folder, 
                                         team_drive = team_drive)
          
          finish_process(paste(cli::col_magenta(
            paste0(path, "/", collapse = "")), "folder created on Google Drive!"))
          
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
#' @param path character. (Sub)directory in My Drive or a Team Drive.
#' @param team_drive character. The name of a Google Team Drive (optional).
#' @param .response automatic response in non interactive environment on whether
#'   to create new folder if this do not exist (1 = Yes, 2 = No).
#'
#' @return A dribble object.
#'
#' @noRd
#' 
get_parent_dribble <- function(path = NULL, team_drive = NULL, .response = 1){
  # get dribble of the parent folder
  if (!is.null(path)) {
    path <- get_path_dribble(path = path, 
                             team_drive = team_drive, 
                             .response = .response)
    
  } else if (is.null(path) & !is.null(team_drive)) {
    # TODO evaluate if get_root_dribble works also for team_drive (in case bind the two conditions)
    path <- googledrive::team_drive_get(team_drive)
    
  } else {
    path <- get_root_dribble()
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
#' @param name character vector indicating the sequence of folders to create.
#' @param parent_dribble a dribble of the parent folder or NULL (default to indicate root).
#' @param team_drive a string indicating the name of a Google Team Drive
#'   (optional).
#'
#' @return A dribble object with information of the created folder.
#' @noRd
#' 
#' @examples  
#' create_drive_folder(name = c("main_folder", "nested_folder"),
#'                     parent_id = "root")
#'       
              
create_drive_folder <- function(name, parent_dribble = NULL, team_drive = NULL){
  
  if(parent_dribble$id == "root"){
    parent_dribble <- NULL
  } 
    
  for (i in seq_along(name)){
    #create folder using parent dribble (NULL if is not available)
    dribble_folder <- googledrive::drive_mkdir(name = name[i],
                                               path = parent_dribble,
                                               verbose = F)
    
    # use folder id as parent for the next folder
    parent_dribble <- dribble_folder
    
  }
  
  return(dribble_folder)
}

#----    get_root_dribble    ----

#' Get root dribble
#'
#' Gets drive id of the root folder. The id is obtained from the 'parents' field
#' in the dribble object listing elements in the root directory. If no element
#' is available in the root folder, id can not be retrieved, a dataframe with id
#' = "root" is returned instead.
#'
#' @param team_drive character. The name of a Google Team Drive (optional).
#'
#' @return A dribble of object of the root folder. Note that a dataframe with id
#'   = "root" is returned, instead, if no element was available in the root
#'   folder.
#' @noRd
#' 
#' @examples
#'   get_root_dribble()
#' 

get_root_dribble <- function(team_drive = NULL){
  
  # get elements with root as parent folder
  dribble <- googledrive::drive_find(q = c("'root' in parents"),
                                     team_drive = team_drive)
  
  if (nrow(dribble) > 0){
    id_root <- googledrive::as_id(dribble$drive_resource[[1]]$parents[[1]])
    dribble_root <- googledrive::as_dribble(id_root)
  } else {
    dribble_root <- data.frame(id = "root")
  }
  
  return(dribble_root)
}


