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
  
  all <- which(grepl("```", local_rmd)) # chunk start
  
  # The start index is odd and the end is even
  
  starts <- all[seq(1, length(all), 2)] # chunk start
  ends <- all[seq(2, length(all), 2)] # chunk ends
  
  
  # Check if chunk without language exist
  
  if(nrow(chunk_info) != length(starts)) {
    
    extra_starts <- setdiff(starts, chunk_info$starts) # check missing starts
    
    # add empty rows to chunk table
    chunk_info[(nrow(chunk_info)+1):(nrow(chunk_info) + length(extra_starts)), ] <- NA
    
    chunk_info$starts <- ifelse(is.na(chunk_info$starts), extra_starts, chunk_info$starts) # replace starts
    
    chunk_info <- chunk_info[order(chunk_info$starts), ] # reorder chunk info
    
  }
  
  chunk_info$ends <- ends
  
  chunk_info$index <- seq(length.out = nrow(chunk_info))
  
  chunk_info$chunk_text <- sapply(seq_along(starts), function(i){
    paste(local_rmd[starts[i]:ends[i]], collapse = "\n")
  }) # extract chunk and apply a \n
  
  chunk_info$chunk_name_file <- sapply(seq_along(chunk_info$name), function(i){
    ifelse(is.na(chunk_info$name[i]),
           yes = paste0("[[", "chunk_", i, "]]"),
           no = paste0("[[", "chunk_", chunk_info$name[i], "]]"))
  })

  return(chunk_info)
}

#----    extract_yaml    ----

# Extract yaml header

extract_yaml <- function(local_rmd, collapse = TRUE){
  
  yaml_index <- which(local_rmd == "---") # chunk start
  
  if(isTRUE(collapse)){
  
    res <- paste(local_rmd[yaml_index[1]:yaml_index[2]], collapse = "\n")
  } else{
    res <- local_rmd[yaml_index[1]:yaml_index[2]]
  }
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
  
  #message(paste("Document setup completed!\n"))
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
# TODO consider also YAML_header

restore_chunk <- function(local_rmd){
  
  local_path <-  dirname(local_rmd)
  local_file <- basename(local_rmd)
  
  chunk_info <- readRDS(file = file.path(local_path,".rmdrive","chunk_info.rds"))
  temp_paper <- readLines(local_rmd, warn = F)
  
  index <- which(startsWith(temp_paper, "[[chunk")) # chunk index
  
  if (length(index) < nrow(chunk_info)) {
    temp_paper <- repair_chunks(temp_paper, chunk_info, index)
  } else{
    
    for(i in seq_along(chunk_info$index)) {
      temp_paper[index[i]] <- chunk_info$chunk_text[i]
    }
  }
  
# sanitize paper
  temp_paper <- temp_paper %>% 
    c("") %>% 
    paste(collapse = "\n") %>% 
    stringr::str_remove_all("NA") %>% # remove NA
    stringr::str_replace_all("\n\n\n", "\n\n") # remove extra spaces
  
  cat(temp_paper, file = local_rmd)
  
}

#----    repair_chunks    ----

# Repairs chunk if missing from the online file

repair_chunks <- function(temp_paper, chunk_info, index){
  
  name <- stringr::str_extract(temp_paper, pattern = "\\[(.*?)\\]\\]") # extract available names
  
  name <- name[!is.na(name)] # clean
  
  name <- ifelse(chunk_info$chunk_name_file %in% name, chunk_info$chunk_name_file, NA)
  
  temp_yaml <- extract_yaml(temp_paper, collapse = F)
  
  end_yaml <- which(temp_yaml == "---")[2]
  
  count <- 0
  index <- rev(index)
  
  for(i in nrow(chunk_info):1){
    
    if(is.na(name[i])) {
      temp[index[count]] <- paste0(chunk_info$chunk_text[i], "\n\n", temp[index[count]])
    }else{
      count <- count + 1
      temp[index[count]] <- chunk_info$chunk_text[i]
    }
    
  }
  
  return(temp_paper)
  
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
  
  start_process("Compiling pdf report...")
  
  rmarkdown::render(file.path(local_path, ".report_temp.Rmd"), 
                    output_format = "pdf_document", 
                    output_file = ".rmdrive/report_temp.pdf",
                    quiet = T)
}

#----
