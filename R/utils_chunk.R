##########################################
####    Utils for chunk extraction    ####
##########################################

#----    init_rmdrive    ----

#' Title create .rmdrive folder if missing
#'
#' @param local_rmd character indicating the name of the file without extension
#'
#' @return NULL
#'
init_rmdrive <- function(local_rmd){
  
  if(!dir.exists(".rmdrive")){
    dir.create(".rmdrive") # create the hidden folder for temp files
    message(paste(proj_name, "setup completed!"))
  }
  
}

#----    extract_chunk    ----

# Extract chunk as list

extract_chunk <- function(local_rmd){

  #paper <- readLines(con = local_rmd) # read file
  
  chunk_info <- get_chunk_info(local_rmd)
  
  # Extract Chunk
  
  starts <- which(startsWith(local_rmd, "```{")) # chunk start
  ends <- which(local_rmd == "```") # chunk end
  
  chunk_info$ends <- ends
  
  chunk_info$index <- 1:nrow(chunk_info)
  
  chunk_info$chunk_text <- sapply(seq_along(starts), function(i){
    paste(local_rmd[starts[i]:ends[i]], collapse = "\n")
  }) # extract chunk and apply a \n

  return(chunk_info)
}

#----    extract_yaml    ----

# Extract yaml header

extract_yaml <- function(local_rmd){
  
  yaml_index <- which(paper == "---") # chunk start
  
  yaml_header <- paste(paper[yaml_index[1]:yaml_index[2]], collapse = "\n")
  
  saveRDS(yaml_header, file = file.path(".rmdrive","yaml_header.rds"))
}

#----    hide_chunk    ----

# remove chunks from .rmd file

hide_chunk <- function(local_rmd){
  
  #proj_name <- sub("\\..*", "", local_rmd) # get project name
  
  #init_rmdrive(local_rmd)
  
  paper <- readLines(local_rmd, warn = F)
  
  chunk_info <- extract_chunk(paper)
  
  # Extract Yaml
  
  yaml_index <- which(paper == "---") # chunk start
  
  yaml_header <- paste(paper[yaml_index[1]:yaml_index[2]], collapse = "\n")
  
  saveRDS(yaml_header, file = file.path(".rmdrive","yaml_header.rds"))
  
  # Save chunk info
  
  saveRDS(chunk_info, file = file.path(".rmdrive", "chunk_info.rds"))
  
  # starts <- which(startsWith(paper, "```{")) # chunk start
  # ends <- which(paper == "```") # chunk end
  
  for(i in seq_along(chunk_info$index)){
    paper[chunk_info$starts[i]:chunk_info$ends[i]] <- NA # chunk space as NA
    
    if(is.na(chunk_info$name[i])){
      paper[chunk_info$starts[i]] <- paste0("[[chunk_", i, "]]") # rename empty name chunks
    }else{
      paper[chunk_info$starts[i]] <- paste0("[[", "chunk_", chunk_info$name[i], "]]")
    }
  }
  
  paper <- paper[!is.na(paper)] # remove extra space named as NA
  
  paper %>% 
    paste(., collapse = "\n") %>% 
    stringr::str_remove_all(., "NA") %>% 
    stringr::str_replace_all(., "\n\n\n", "\n\n") %>% 
    cat(., file = local_rmd)
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
  
  temp_paper <- temp_paper %>% 
    c(., "") %>% 
    paste(., collapse = "\n") %>% 
    stringr::str_remove_all(., "NA") %>% # remove NA
    stringr::str_replace_all(., "\n\n\n", "\n\n") # remove extra spaces
  
  cat(temp_paper, file = local_rmd)
  
}


#----    upload_report    ----

# upload report

upload_report <- function(){

  chunk_info <- readRDS(".rmdrive/chunk_info.rds")
  
  yaml_header <- readRDS(".rmdrive/yaml_header.rds")
  
  temp_chunk <- chunk_info
  
  #setup_chunk <- temp_chunk[stringr::str_detect(temp_chunk$name, stringr::regex('setup', ignore_case = T)), ]
  
  temp_chunk <- chunk_info[!stringr::str_detect(temp_chunk$name, stringr::regex('setup', ignore_case = T)), ] # remove echo = F chunks
  
  temp_chunk <- paste0(paste("###", temp_chunk$name, "\n\n"), temp_chunk$chunk_text)
  
  temp_chunk %>% 
    paste0(., collapse = "\n\n") %>% 
    cat(yaml_header, ., sep = "\n\n", file = ".report_temp.Rmd")
  
  rmarkdown::render(".report_temp.Rmd", output_format = "pdf_document", output_file = ".rmdrive/report_temp.pdf", quiet = T)
}