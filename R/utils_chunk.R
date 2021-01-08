##########################################
####    Utils for chunk extraction    ####
##########################################

#----    mkdir_rmdrive    ----

#' Create .rmdrive folder if missing
#'
#' @param local_path string indicating the path where to create the folder
#' 
#' @return NULL
#'
mkdir_rmdrive <- function(local_path){
  
  drk_rmdrive <- paste(local_path, ".rmdrive", sep = "/")
  if(!dir.exists(drk_rmdrive)){
    dir.create(drk_rmdrive) # create the hidden folder for temp files
  }
  
}

#----    extract_chunk    ----

#' Extract chunks as list from document
#'
#' @param local_rmd character indicating the name of the file without extension
#'
#' @return TODO
#'
extract_chunk <- function(local_rmd){

  #paper <- readLines(con = local_rmd) # read file
  
  chunk_info <- get_chunk_info(local_rmd)
  
  # Extract Chunk
  
  starts <- which(startsWith(local_rmd, "```{")) # chunk start
  ends <- which(local_rmd == "```") # chunk end
  
  chunk_info$ends <- ends
  
  chunk_info$index <- seq(length.out = nrow(chunk_info))
  
  chunk_info$chunk_text <- sapply(seq_along(starts), function(i){
    paste(local_rmd[starts[i]:ends[i]], collapse = "\n")
  }) # extract chunk and apply a \n

  return(chunk_info)
}

#----    extract_yaml    ----

# Extract yaml header

extract_yaml <- function(local_rmd){
  
  yaml_index <- which(local_rmd == "---") # chunk start
  
  res <- paste(local_rmd[yaml_index[1]:yaml_index[2]], collapse = "\n")
  
  return(res)
}

#----    init_rmdrive    ----

#' Init rmdrive
#' 
#' Create .rmdrive folder with info about chunks 
#' 
#' @param file_text sting indicating the file path
#' @param local_path sting indicating the local path where to create .rmdrive
#'   folder
#'   
#' @noRd
init_rmdrive <- function(file_text, local_path){
  # create .rmdrive folder 
  mkdir_rmdrive(local_path = local_path) 
  
  # read file
  paper <- readLines(file_text, warn = F)
  
  # Extract and save code chunks
  chunk_info <- extract_chunk(paper)
  saveRDS(chunk_info, file = file.path(local_path, ".rmdrive", "chunk_info.rds"))
  
  # Extract and save Yaml header
  yaml_header <- extract_yaml(paper) 
  saveRDS(yaml_header, file = file.path(local_path, ".rmdrive","yaml_header.rds"))
  
  message(paste("Document setup completed!\n"))
}


#----    hide_chunk    ----

# remove chunks from .rmd file
# TODO remove also YAML ??

hide_chunk <- function(file_text, local_path){
  
  # read file
  paper <- readLines(file_text, warn = F)
  
  # get saved chunks info
  chunk_info <- readRDS(file = file.path(local_path, ".rmdrive","chunk_info.rds"))
  
  # replace chunks in file
  for(i in seq_along(chunk_info$index)){
    paper[chunk_info$starts[i]:chunk_info$ends[i]] <- NA # chunk space as NA
    
    if(is.na(chunk_info$name[i])){
      paper[chunk_info$starts[i]] <- paste0("[[chunk_", i, "]]") # rename empty name chunks
    }else{
      paper[chunk_info$starts[i]] <- paste0("[[", "chunk_", chunk_info$name[i], "]]")
    }
  }
  
  paper <- paper[!is.na(paper)] # remove extra space named as NA
  
  # sanitize paper
  paper <- paper %>% 
    paste(collapse = "\n") %>% 
    stringr::str_replace_all("\n\n\n", "\n\n")
  
  cat(paper, file = file_text)
}



#----    restore_chunk    ----

# add chunk at the placeholder position

restore_chunk <- function(local_rmd){
  
  chunk_info <- readRDS(file = file.path(".rmdrive","chunk_info.rds"))
  
  temp_paper <- readLines(local_rmd, warn = F)
  
  index <- which(startsWith(temp_paper, "[[chunk")) # check each chunk
  
  for(i in seq_along(chunk_info$chunk_text)){
    temp_paper[index[i]] <- chunk_info$chunk_text[[i]]
  }
  
  # sanitize paper
  temp_paper <- temp_paper %>% 
    c("") %>% 
    paste(collapse = "\n") %>% 
    stringr::str_remove_all("NA") %>% # remove NA
    stringr::str_replace_all("\n\n\n", "\n\n") # remove extra spaces
  
  cat(temp_paper, file = local_rmd)
  
}


#----    knit_report    ----

# knit_report report

knit_report <- function(local_path){
  
  # get saved chunks info
  chunk_info <- readRDS(file = file.path(local_path, ".rmdrive","chunk_info.rds"))
  yaml_header <- readRDS(file = file.path(local_path, ".rmdrive","yaml_header.rds"))
  
  setup_chunk <- chunk_info[stringr::str_detect(chunk_info$name, stringr::regex('setup', ignore_case = T)), ]
  
  temp_chunk <- chunk_info[!stringr::str_detect(chunk_info$name, stringr::regex('setup', ignore_case = T)), ] # remove echo = F chunks
  
  temp_chunk <- paste0(paste("###", temp_chunk$name, "\n\n"), temp_chunk$chunk_text) %>% 
    paste0(collapse = "\n\n")
  
  cat(yaml_header, temp_chunk, sep = "\n\n", file = file.path(local_path, ".report_temp.Rmd"))
  
  rmarkdown::render(file.path(local_path, ".report_temp.Rmd"), 
                    output_format = "pdf_document", 
                    output_file = ".rmdrive/report_temp.pdf",
                    quiet = T)
}

#----
