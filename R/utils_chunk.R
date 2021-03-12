##########################################
####    Utils for chunk extraction    ####
##########################################

#----    mkdir_trackdown    ----

#' Create .trackdown folder if missing
#'
#' @param local_path string indicating the path where to create the folder
#' @param folder_name string indicating the folder name, default ".trackdown"
#' 
#' @return NULL
#' @noRd
#'
mkdir_trackdown <- function(local_path, folder_name = ".trackdown"){
  
  drk_trackdown <- paste(local_path, folder_name, sep = "/")
  if(!dir.exists(drk_trackdown)){
    dir.create(drk_trackdown) # create the hidden folder for temp files
  }
  
}

#----    get_chunk_range    ----

#' Get chunks start and end lines
#' 
#' Get chunks start and end lines
#'
#' @param lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#'
#' @return  a tibble with \itemize{
#'   \item{starts} the line number of the chunk header
#'   \item{ends} the line number of the chunk end
#' }
#' @noRd
#'
#' @examples
#'   # rmd
#'   lines <- readLines("tests/testthat/test_files/example_1_rmd.txt")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   get_chunk_range(lines, info_patterns)
#'   
#'   # rnw
#'   lines <- readLines("tests/testthat/test_files/example_1_rnw.txt")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   get_chunk_range(lines, info_patterns)
#' 

get_chunk_range <- function(lines, info_patterns){
  
  if(info_patterns$extension == "rmd"){
    # solve issue of chunks without language and '{}'
    # check for chunk of types '```{...}' or '```'
    index <- which(grepl("^```(\\s*$|\\{)", lines))
    
    if(length(index)>0){
      header_indices <- index[seq(1,length(index),2)]
      end_indices <- index[seq(2,length(index),2)]
    } else {
      header_indices <- integer()
      end_indices <- integer()
    }
  
  } else if(info_patterns$extension == "rnw"){
    # find which lines are chunk starts and chuck ends
    header_indices <- which(grepl(info_patterns$chunk_header_start, lines))
    # finde which lines are chuck ends
    end_indices <- which(grepl(info_patterns$chunk_end, lines))
  }
  
  if(any(header_indices>end_indices))
    stop("There are some issues in the identification of chunk start/end line indexes")
  
  return(tibble::tibble(starts = header_indices,
                        ends = end_indices))
}

#----    extract_chunk    ----

#' Extract chunks as list from document
#'
#' @param text_lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#' 
#' @noRd
#' @return  a tibble with \itemize{
#'   \item{language} of the chunk
#'   \item{name} of the chunk
#'   \item{options} of the chunk
#'   \item{starts} the line number of the chunk header
#'   \item{ends} the line number of the chunk end
#'   \item{index} integer index to identify the chunk
#'   \item{chunk_text} the chunk from header to end (included)
#'   \item{name_tag} the name used as tag in the text
#' }
#' Note that in case of "rnw" extension the language is always NA. NULL is
#' returned if no chunk was available.
#' 
#' @examples 
#'   # rmd
#'   text_lines <- readLines("tests/testthat/test_files/example_1_rmd.txt")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   extract_chunk(text_lines, info_patterns)
#'   
#'   # rnw
#'   text_lines <- readLines("tests/testthat/test_files/example_1_rnw.txt")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   extract_chunk(text_lines, info_patterns)
#'

extract_chunk <- function(text_lines, info_patterns){
  
  chunk_info <- get_chunk_info(lines = text_lines, info_patterns = info_patterns)
  
  # return NULL if no chunk was available
  if(is.null(chunk_info)) return(NULL)
  
  index_seq <- seq_len(nrow(chunk_info))
  # Extract chunk from header to end (included) and add '\n' to separate lines
  chunk_text <- vapply(index_seq, function(i){
    paste(text_lines[chunk_info$starts[i]:chunk_info$ends[i]], 
          collapse = "\n")
  }, FUN.VALUE = character(1)) 
  
  # create chunk name to use as tag in the text (solve problem of chunk with non name)
  name_tag <- vapply(index_seq, function(i){
    ifelse(is.na(chunk_info$name[i]),
           yes = paste0("[[", "chunk-", i, "]]"),
           no = paste0("[[", "chunk-", chunk_info$name[i], "]]"))
  }, FUN.VALUE = character(1))
  
  # swap '_' to "-" solve issues LaTeX
  name_tag <- sub("_","-", name_tag)
  
  # add to chunk info 
  chunk_info$chunk_text <- chunk_text
  chunk_info$name_tag <- name_tag

  return(chunk_info)
}

#----    extract_header    ----

#' Extract Header
#'
#' @param text_lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#' 
#' @noRd
#' @return  a tibble with \itemize{
#'   \item{starts} the line number of the header start
#'   \item{ends} the line number of the header end
#'   \item{header_text} the header form start to end (included)
#'   \item{name_tag} the name used as tag in the text
#' }
#' 
#' @examples 
#'   # rmd
#'   text_lines <- readLines("tests/testthat/test_files/example_1_rmd.txt")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   extract_header(text_lines, info_patterns)
#'   
#'   # rnw
#'   text_lines <- readLines("tests/testthat/test_files/example_1_rnw.txt")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   extract_header(text_lines, info_patterns)
#'

extract_header <- function(text_lines, info_patterns){
  
  if(info_patterns$extension == "rmd"){
    # in rmd start and end header are the same
    header_index <- which(grepl(info_patterns$file_header_start, text_lines))
    
    if(length(header_index) != 2) 
      stop("There are some issues in the identification of YAML start/end line indexes")
    
    header_start <- header_index[1]
    header_end <- header_index[2]
    
  } else if(info_patterns$extension == "rnw"){
    header_start <- which(grepl(info_patterns$file_header_start, text_lines))
    header_end <- which(grepl(info_patterns$file_header_end, text_lines))
    
    if(length(header_start) != 1 || length(header_end) != 1) 
      stop("There are some issues in the identification of the document header start/end line indexes")
  }
  
  res <- tibble::tibble(
    starts = header_start,
    ends = header_end,
    header_text = paste(text_lines[header_start:header_end], collapse = "\n"),
    name_tag = "[[document-header]]")
  
  return(res)
}

#----    get_file_metadata    ----

#' Get File Metadata
#' 
#' Save valuable info that can help to restore chunk and header
#'
#' @param file_info list with file info returned from get_file_info() function
#'
#' @return a tibble with \itemize{
#'   \item{file_name} name of the file with extension
#'   \item{file_path} path to the file
#'   \item{extension} file extension
#'   \item{google_id} google id initialized at ""
#'   \item{name_chunk_info} name of the object where chunk info are saved
#'   \item{name_header_info} name of the object where header info are saved
#' }
#' @noRd
#'
#' @examples
#'   file_info <- get_file_info("tests/testthat/test_files/example_1.Rmd")
#'   get_file_metadata(file_info)
#' 

get_file_metadata <- function(file_info){
  tibble::tibble(file_name = file_info$file_name,
                 file_path = file_info$path,
                 extension = file_info$extension,
                 google_id = "",
                 name_chunk_info = paste0(file_info$file_name,"-chunk_info.rds"),
                 name_header_info = paste0(file_info$file_name,"-header_info.rds"))
  
}

#----    get_extension_patterns    ----

#' Get extensions pattern
#' 
#' Given the extension (rmd or rnw), return a list with the regex patterns for
#' the chunk header (start and end), chunk end , and file header (start/end).
#' 
#' @param extension string indicating the file extension ("rmd" or "rnw")
#'
#' @return a list with the regex pattern that identify \itemize{
#' \item{chunk_header_start} the start of the first line of a chunk
#' \item{chunk_header_end} the end of the first line of a chunk
#' \item{chunk_end} the end line of a chunk
#' \item{file_header_start} the start line of the file header
#' \item{file_header_end} the end line of the file header
#' \item{extension} the extension type (rmd or rnw)
#' }
#' @noRd
#'
#' @examples
#'   get_extension_patterns("rmd")
#'   get_extension_patterns("rnw")
#' 

get_extension_patterns <- function(extension =  c("rmd", "rnw")){
  extension <- match.arg(extension)
  
  if (extension == "rmd"){     # ```{*}   ```
    res <- list(chunk_header_start = "^```(\\s*$|\\{)",
                chunk_header_end = "\\}\\s*$",
                chunk_end = "^```\\s*$",
                file_header_start = "^---\\s*$",
                file_header_end = "^---\\s*$",
                extension = extension)
    
  } else if (extension == "rnw"){  # <<*>>=   @
    res <- list(chunk_header_start = "^<<",
                chunk_header_end = ">>=.*$",
                chunk_end = "^@\\s*$",
                file_header_start = "^\\\\documentclass\\{",
                file_header_end = "^\\\\begin\\{document\\}",
                extension = extension)
  }
  
  return(res)
}


#----    hide_code    ----

#' Remove code
#'
#' Remove code from the document (chunks and header). Placeholders of  type
#' "[[chunk-<name>]]"/"[[Document-header]]" are displayed instead.
#'
#' @param document character vector with the lines of the document 
#' @param file_info list with file info returned from get_file_info() function
#'
#' @return a vector with the content of the document (with code removed)
#' @noRd
#'
#' @examples
#'   # rmd
#'   document <- readLines("tests/testthat/test_files/example_1_rmd.txt")
#'   file_info <- get_file_info("tests/testthat/test_files/example_1.Rmd")
#'   hide_code(document, file_info)
#'   
#'   # rnw
#'   document <- readLines("tests/testthat/test_files/example_1_rnw.txt")
#'   file_info <- get_file_info("tests/testthat/test_files/example_1.Rnw")
#'   hide_code(document, file_info)
#'   
#'   # remove files
#'   ls_files_1 <- list.files(paste0(file_path, ".trackdown"))
#'   file.remove(paste0(file_path, ".trackdown/",ls_files_1))
#'   file.remove(paste0(file_path, ".trackdown"), recursive = TRUE)
#' 

hide_code <- function(document, file_info){
  
  # create .trackdown folder to save info about chunks and header
  mkdir_trackdown(local_path = file_info$path) 
  
  info_patterns <- get_extension_patterns(extension = file_info$extension)
  
  #---- Extract and save ----
  #code chunks
  chunk_info <- extract_chunk(text_lines = document, info_patterns = info_patterns)
  saveRDS(chunk_info, file = file.path(file_info$path, ".trackdown", 
                                       paste0(file_info$file_name,"-chunk_info.rds")))
  # header
  header_info <- extract_header(text_lines = document, info_patterns = info_patterns) 
  saveRDS(header_info, file = file.path(file_info$path, ".trackdown",
                                        paste0(file_info$file_name,"-header_info.rds")))
  
  #---- replace in file with tag ----
  # chunks
  for(i in seq_along(chunk_info$index)){
    document[chunk_info$starts[i]:chunk_info$ends[i]] <- NA # chunk space as NA
    document[chunk_info$starts[i]] <- chunk_info$name_tag[i] # set chunk tag
  }
  # header
  document[header_info$starts:header_info$ends] <- NA # header space as NA
  document[header_info$starts] <- header_info$name_tag # set header tag
  
  
  # remove extra space named as NA
  document <- document[!is.na(document)] 
  
  return(document)
}

#----    restore_chunk    ----

# add chunk at the placeholder position
# TODO consider also YAML_header

restore_chunk <- function(local_file){
  
  local_path <-  dirname(local_file)
  local_file <- basename(local_file)
  
  chunk_info <- readRDS(file = file.path(local_path,".trackdown","chunk_info.rds"))
  temp_paper <- readLines(local_file, warn = F)
  
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
  
  cat(temp_paper, file = local_file)
  
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
  chunk_info <- readRDS(file = file.path(local_path, ".trackdown","chunk_info.rds"))
  yaml_header <- readRDS(file = file.path(local_path, ".trackdown","yaml_header.rds"))
  
  setup_chunk <- chunk_info[stringr::str_detect(chunk_info$name, stringr::regex('setup', ignore_case = T)), ]
  
  temp_chunk <- chunk_info[!stringr::str_detect(chunk_info$name, stringr::regex('setup', ignore_case = T)), ] # remove echo = F chunks
  
  temp_chunk <- paste0(paste("###", temp_chunk$name, "\n\n"), temp_chunk$chunk_text) %>% 
    paste0(collapse = "\n\n")
  
  cat(yaml_header, temp_chunk, sep = "\n\n", file = file.path(local_path, ".report_temp.Rmd"))
  
  start_process("Compiling pdf report...")
  
  rmarkdown::render(file.path(local_path, ".report_temp.Rmd"), 
                    output_format = "pdf_document", 
                    output_file = ".trackdown/report_temp.pdf",
                    quiet = T)
}

#----
