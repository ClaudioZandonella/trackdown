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
  
  os <- get_os() # get the current os
  
  if(os == "windows"){
    shell(paste("attrib +h", drk_trackdown)) # make the directory hidden in windows
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
#' @return  a tibble with
#'   - **starts** the line number of the chunk header
#'   - **ends** the line number of the chunk end
#' @noRd
#'
#' @examples
#'   # rmd
#'   lines <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   get_chunk_range(lines, info_patterns)
#'   
#'   # rnw
#'   lines <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   get_chunk_range(lines, info_patterns)
#' 

get_chunk_range <- function(lines, info_patterns){
  
  if(info_patterns$extension %in% c("rmd", "qmd")){
    # solve issue of chunks without language and '{}'
    # check for chunk of types '```{...}', '```bash', or '```'
    index <- grep(info_patterns$chunk_start, lines)
    
    if(length(index)>0){
      header_indices <- index[seq(1,length(index),2)]
      end_indices <- index[seq(2,length(index),2)]
    } else {
      header_indices <- integer()
      end_indices <- integer()
    }
  
  } else if(info_patterns$extension == "rnw"){
    # find which lines are chunk starts and chunk ends
    header_indices <- grep(info_patterns$chunk_start, lines)
    # find which lines are chunk ends
    end_indices <- grep(info_patterns$chunk_end, lines)
  }
  
  if(any(header_indices>end_indices))
    stop("There are some issues in the identification of chunk start/end line indexes")
  
  return(data.frame(starts = header_indices,
                    ends = end_indices,
                    stringsAsFactors = FALSE))
}

#----    extract_chunk    ----

#' Extract chunks as list from document
#'
#' @param text_lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#' 
#' @noRd
#' @return  a tibble with 
#'   - **language** of the chunk
#'   - **name** of the chunk
#'   - **options** of the chunk
#'   - **starts** the line number of the chunk header
#'   - **ends** the line number of the chunk end
#'   - **index** integer index to identify the chunk
#'   - **chunk_text** the chunk from header to end (included)
#'   - **name_tag** the name used as tag in the text
#'   
#' Note that in case of "rnw" extension the language is always NA. NULL is
#' returned if no chunk is available.
#' 
#' @examples 
#'   # rmd
#'   text_lines <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   extract_chunk(text_lines, info_patterns)
#'   
#'   # rnw
#'   text_lines <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
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

#----    check_header    ----

#' Check Header
#'
#' @param text_lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#' 
#' @noRd
#' @return  a tibble with
#'   - **starts** the line number of the header start
#'   - **ends** the line number of the header end
#'   - **header_text** the header form start to end (included)
#'   - **name_tag** the name used as tag in the text
#' 
#' @examples 
#'   # rmd
#'   text_lines <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   extract_header(text_lines, info_patterns)
#'   
#'   # rnw
#'   text_lines <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   extract_header(text_lines, info_patterns)
#'   
#'   check_header(text_lines, info_patterns)
#'   

check_header <- function(text_lines, info_patterns){
  
  if(info_patterns$extension %in% c("rmd", "qmd")){
    
    # in rmd start and end header are the same
    delimiters <-  grep(info_patterns$file_header_start, text_lines)
    
    # Based on knitr code (based on the partition_yaml_front_matter and
    # parse_yaml_front_matter functions here:
    # https://github.com/rstudio/rmarkdown/blob/main/R/output_format.R
    # https://github.com/yihui/knitr/blob/237cde1afc1f5b94178069e4ee39debe9d4ece28/R/params.R#L134-L138
    res <- length(delimiters) >= 2 && 
      (delimiters[2] - delimiters[1] > 1) &&
      (delimiters[1] == 1 || is_blank(head(text_lines, delimiters[1] - 1)))
    
  } else if(info_patterns$extension == "rnw"){
    # check if "\documentclass{}" and \begin{document}" are present
    header_start <- grep(info_patterns$file_header_start, text_lines)
    header_end <- grep(info_patterns$file_header_end, text_lines)
    
    if(length(header_start) + length(header_end) == 1L) # if we find only 1 of the two delimiters
      stop("There are some issues in the identification of the document header start/end line indexes",
           call. = FALSE)
    
    res <- length(header_start) == 1L &&
      length(header_end) == 1L
  }
  
  return(res)
  
}


#----    extract_header    ----

#' Extract Header
#'
#' @param text_lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#' 
#' @noRd
#' @return  a tibble with
#'   - **starts** the line number of the header start
#'   - **ends** the line number of the header end
#'   - **header_text** the header form start to end (included)
#'   - **name_tag** the name used as tag in the text
#'   
#'   Note that if no header is available, NULL is returned
#' 
#' @examples 
#'   # rmd
#'   text_lines <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   extract_header(text_lines, info_patterns)
#'   
#'   # rnw
#'   text_lines <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   extract_header(text_lines, info_patterns)
#'

extract_header <- function(text_lines, info_patterns){
  
  has_header <- check_header(text_lines = text_lines, 
                             info_patterns = info_patterns)
  
  if(isTRUE(has_header)){
    # file has header
    if(info_patterns$extension %in% c("rmd", "qmd")){
      # in rmd start and end header are the same
      header_index <- grep(info_patterns$file_header_start, text_lines)
      
      header_start <- header_index[1]
      header_end <- header_index[2]
      
      } else if(info_patterns$extension == "rnw"){
      
        header_start <- 1 # grep(info_patterns$file_header_start, text_lines) # assume first line of the document
        header_end <- grep(info_patterns$file_header_end, text_lines)
      }
    
    res <- data.frame(
      starts = header_start,
      ends = header_end,
      header_text = paste(text_lines[header_start:header_end], collapse = "\n"),
      name_tag = "[[document-header]]", 
      stringsAsFactors = FALSE)
    
    } else {
      
      #file has no header
      res <- NULL
  }
  
  return(res)
}

#----    get_extension_patterns    ----

#' Get extensions pattern
#' 
#' Given the extension (rmd, qmd or rnw), return a list with the regex patterns for
#' the chunk header (start and end), chunk start, chunk end, and file header
#' (start/end).
#' 
#' @param extension string indicating the file extension ("rmd", "qmd", or "rnw")
#'
#' @return a list with the regex pattern that identify
#' - **chunk_header_start** the start of the first line of a chunk
#' - **chunk_header_end** the end of the first line of a chunk
#' - **chunk_start** the start line of a chunk
#' - **chunk_end** the end line of a chunk
#' - **file_header_start** the start line of the file header
#' - **file_header_end** the end line of the file header
#' - **extension** the extension type (rmd, qmd or rnw)
#' 
#' @noRd
#'
#' @examples
#'   get_extension_patterns("rmd")
#'   get_extension_patterns("qmd")
#'   get_extension_patterns("rnw")
#' 

get_extension_patterns <- function(extension =  c("rmd", "qmd", "rnw")){
  extension <- match.arg(extension)
  
  if (extension %in% c("rmd", "qmd")){     # ```{*}   ```bash    ```
    res <- list(chunk_header_start = "^\\s*```\\s*\\{?",   # start with ``` followed by possible white spaces and a possible {
                chunk_header_end = "\\}?\\s*$",        # ends with a possible { and possible white spaces
                chunk_start = "^\\s*```\\s*(\\S*\\s*$|\\{)", # allow "```{...}", "```bash", "```"  
                chunk_end = "^\\s*```\\s*$",
                file_header_start = "^---\\s*$",
                file_header_end = "^---\\s*$",
                extension = extension)
    
  } else if (extension == "rnw"){  # <<*>>=   @
    res <- list(chunk_header_start = "^\\s*<<",
                chunk_header_end = ">>=.*$",
                chunk_start = "^\\s*<<",
                chunk_end = "^\\s*@\\s*$",
                file_header_start = "^\\\\documentclass(\\{|\\[)",
                file_header_end = "^\\\\begin\\{document\\}",
                extension = extension)
  }
  
  return(res)
}


#----    hide_code    ----

#' Remove Code
#'
#' Remove code from the document (chunks and header). Placeholders of  type
#' `"[[chunk-<name>]]"`/`"[[Document-header]]"` are displayed instead.
#'
#' @param document character vector with the lines of the document 
#' @param file_info list with file info returned from get_file_info() function
#'
#' @return a vector with the content of the document (with code removed)
#' @noRd
#'
#' @examples
#'   # rmd
#'   document <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   file_info <- get_file_info("tests/testthat/test_files/examples/example-1.Rmd")
#'   hide_code(document, file_info)
#'   
#'   # rnw
#'   document <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
#'   file_info <- get_file_info("tests/testthat/test_files/examples/example-1.Rnw")
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
  
  #---- header ----
  # extract and save (NULL if no header present)
  header_info <- extract_header(text_lines = document, info_patterns = info_patterns) 
  saveRDS(header_info, file = file.path(file_info$path, ".trackdown",
                                        paste0(file_info$file_name,"-header_info.rds")))
  # replace if no NULL
  if(!is.null(header_info)){
    document[header_info$starts:header_info$ends] <- NA # header space as NA
    document[header_info$starts] <- header_info$name_tag # set header tag
  }
  
  #---- chunks  ----
  # extract and save (NULL if no chunk present)
  chunk_info <- extract_chunk(text_lines = document, info_patterns = info_patterns)
  saveRDS(chunk_info, file = file.path(file_info$path, ".trackdown", 
                                       paste0(file_info$file_name,"-chunk_info.rds")))
  # replace (seq_along() allows to skip if chunk_info is NULL)
  for(i in seq_along(chunk_info$index)){
    document[chunk_info$starts[i]:chunk_info$ends[i]] <- NA # chunk space as NA
    document[chunk_info$starts[i]] <- chunk_info$name_tag[i] # set chunk tag
  }
  
  # remove extra space named as NA
  document <- document[!is.na(document)] 
  
  return(document)
}

#----    restore_file    ----

#' Restore the Downloaded File with Code Info
#'
#' Restore placeholders of type `"[[chunk-<name>]]"`/`"[[Document-header]]"` with
#' the actual code and sanitize file.
#'
#' @param temp_file character indicating the path to the downloaded file
#' @param file_name character indicating the current file name
#' @param path character indicating the folder of the original file
#' @param rm_gcomments (experimental) logical value indicating whether or not to
#'   remove Google comments
#'
#' @return a single string with the content of the document
#' @noRd
#' 

restore_file <- function(temp_file, file_name, path, rm_gcomments = FALSE){
  
  # read document lines
  document <- readLines(temp_file, warn = FALSE)
  
  # remove Google comments
  if(isTRUE(rm_gcomments)){
    document <- remove_google_comments(document)
  }
  
  # eval instructions
  instructions <- eval_instructions(document = document, file_name = file_name)
  
  # remove instructions if indexes are available
  if(!is.null(instructions$start) & !is.null(instructions$end)){
    document <- document[-c(instructions$start:instructions$end)]
  }
  
  # restore code
  if(isTRUE(instructions$hide_code)){
    document <- restore_code(document = document,
                             file_name = instructions$file_name,
                             path = path)
  }
  
  # sanitize document
  document <- sanitize_document(document)
  
  cat(document, file = temp_file)
  
  return(invisible(document))
}

#----    restore_code    ----

#' Restore Header and Chunks Code
#' 
#' Given the document, the co
#'
#' @param document character vector with the lines of the document 
#' @param file_name character indicating the name of the file used to load code
#'   info
#' @param path character indicating the path to the file 
#'
#' @return character vector with the lines of the document 
#' @noRd
#'
#' @examples
#' # Rmd
#' file_name <- "example_1.Rmd"
#'                            
#' # Rnw
#' file_name <- "example_1.Rnw"
#' 
#' path <- "tests/testthat/test_files/examples"
#' document <- readLines(file.path(path, paste0("restore_", file_name)), warn = FALSE)
#' restore_code(document, file_name, path)
#' 

restore_code <- function(document, file_name, path){
  
  # Check .trackdown folder is available
  if(!dir.exists(file.path(path,".trackdown")))
    stop(paste0("Failed restoring code. Folder .trackdown is not available in ", path), call. = FALSE)
    
  # load code info 
  header_info <- load_code(file_name = file_name, path = path, type = "header")
  chunk_info <- load_code(file_name = file_name, path = path, type = "chunk")
  
  #---- restore header ----
  
  if(is.null(header_info)){
    # Skip and set index_header to allow document[seq_len(index_header)]
    # in restore_chunk to return nothing
    index_header <- 0L     
  } else {
    # Find "[[document-header]]" tag
    index_header <- grep("^\\[\\[document-header\\]\\]", document)
    
    if(length(index_header) != 1L) {
      warning("Failed retrieving [[document-header]] placeholder, code added at first line", call. = FALSE)
      document <- c(header_info$header_text, document)
      index_header <- 1L
    } else {
      document[index_header] <- header_info$header_text
    }
  }
  
  #---- restore chunks ----
  
  if(!is.null(chunk_info)){
    document <- restore_chunk(document = document,
                              chunk_info = chunk_info,
                              index_header = index_header)
  }
  
  return(document)
  
}

#----    restore_chunk    ----

#' Restore Chunk Code
#'
#' Given the document, chunk info and header line index, restore chunks in the
#' document. Allow to fix possible missing chunk-tags in the document by adding
#' them right after the previous matching chunk. In case the first one is
#' missing, chunk is added after the header. Note that actual chunks restoring
#' process starts from the end going backwards.
#'
#' @param document character vector with the lines of the document 
#' @param chunk_info dataframe with the chunk information to restore previously
#'   saved
#' @param index_header integer indicating the line index of th header
#'
#' @return character vector with the lines of the document 
#' @noRd
#'
#' @examples
#' 
#' # Rmd
#' file <- "tests/testthat/test_files/examples/example-1-restore.Rmd"
#' chunk_info <- load_code("example-1.Rmd", path = "tests/testthat/test_files/examples", 
#'                           type = "chunk")
#' index_header <- 9
#' 
#' # Rnw
#' file <- "tests/testthat/test_files/examples/example-1-restore.Rnw"
#' chunk_info <- load_code("example-1.Rnw", path = "tests/testthat/test_files/examples", 
#'                           type = "chunk")
#' index_header <- 12
#' 
#' document <- readLines(file, warn = FALSE)
#' restore_chunk(document, chunk_info, index_header)
#' 

restore_chunk <- function(document, chunk_info, index_header){
  
  index_chunks <- grep("^\\[\\[chunk-.+\\]\\]", document)
  # extract names [[chunk-*]] removing possible spaces
  names_chunks <- gsub("^\\s*(\\[\\[chunk-.+\\]\\])\\s*","\\1", document[index_chunks])
  
  match <- chunk_info$name_tag %in% names_chunks
  
  
  my_seq <- rev(seq_len(nrow(chunk_info))) # revers order start form last chunk
  unmatched <- NULL
  for (i in my_seq){
    if(isFALSE(match[i])){
      unmatched <- c(chunk_info$chunk_text[i], unmatched)
      
      # test if is the last remaining chunk
      if(i == 1L){
        document <- c(document[seq_len(index_header)],  # if no header index_header is 0
                      paste0(unmatched, collapse = "\n\n"), 
                      document[(index_header + 1):length(document)])
        unmatched <- NULL
      }
      
    } else {
      # get correct index_chunk matching names in document
      line_index <- index_chunks[names_chunks == chunk_info$name_tag[i]]
      
      # restore chunk together with previous unmatched chunks
      document[line_index] <- paste0(c(chunk_info$chunk_text[i], unmatched),  collapse = "\n\n")
      unmatched <- NULL # reset
    }
  }
  
  return(document)
}

#----
