###############################
####    Namer Utilities    ####
###############################


# Utility from namer R-package https://github.com/lockedata/namer
# changes were made to allow parsing chunks for Rmd files as well as Rnw files

#----    quote_label    ----

# function from knitr r-package
# https://github.com/yihui/knitr/blob/2b3e617a700f6d236e22873cfff6cbc3568df568/R/parser.R#L148

# quote the chunk label if necessaryme issues
# Adapted to solve so

quote_label <-  function(x) {
  x <-  gsub('^\\s*,?', '', x)
  if (grepl('^\\s*[^\'"](,|\\s*$)', x)) {
    if(grepl('^\\s*[^\'"],\\s*[^=]*(,|\\s*$)', x)){
      # "r, chucnk_name" ---> "'r chucnk_name'"
      x <- gsub('^\\s*([^\'"]),(\\s*[^=]*)(,|\\s*$)', "'\\1,\\2'\\3", x)
    } else {
      # <<a,b=1>>= ---> <<'a',b=1>>=
      x <-  gsub('^\\s*([^\'"])(,|\\s*$)', "'\\1'\\2", x)
    }

  } else if (grepl('^\\s*[^\'"](,|[^=]*(,|\\s*$))', x)) {
    # <<abc,b=1>>= ---> <<'abc',b=1>>=
    x <-  gsub('^\\s*([^\'"][^=]*)(,|\\s*$)', "'\\1'\\2", x)
  }
  x
}

#----    get_chunk_info    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L72
# adapted to consider rmd and rnw

#' Get chunk info
#' 
#' helper to create a data.frame of chunk info
#'
#' @param lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#'
#' @return  a tibble with \itemize{
#'   \item{language} of the chunk
#'   \item{name} of the chunk
#'   \item{options} of the chunk
#'   \item{starts} the line number of the chunk header
#'   \item{ends} the line number of the chunk end
#'   \item{index} integer index to identify the chunk
#' }
#' Note that in case of "rnw" extension the language is always NA. NULL is
#' returned if no chunk was available.
#' @noRd
#'
#' @examples
#'   # rmd
#'   lines <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   get_chunk_info(lines, info_patterns)
#'   
#'   # rnw
#'   lines <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   get_chunk_info(lines, info_patterns)
#' 

get_chunk_info <- function(lines, info_patterns){
  
  # find which lines are chunk starts and chuck ends
  chunks_range <- get_chunk_range(lines, info_patterns)

  # null if no chunks
  if(length(chunks_range$starts) == 0){
    res <- NULL
  } else {
    # parse these chunk headers
    res <- lapply(chunks_range$starts, FUN = function(x){
      digest_chunk_header(chunk_header_index = x, 
                          lines = lines, 
                          info_patterns = info_patterns)
    })
    res <- do.call("rbind", res)
    
    # return also chunk start/end line indexes
    res$starts <- chunks_range$starts
    res$ends <- chunks_range$ends
    res$index <- seq(length.out = nrow(res))
  }
  
  return(res)
}

#----    parse_chunk_header    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L35

#' Parse chunk header
#' 
#' from a chunk header to a tibble with language, name, option, option values
#' 
#' @param chunk_header a string with the chunk header
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#'
#' @return  a tibble with \itemize{
#'   \item{language} of the chunk
#'   \item{name} of the chunk
#'   \item{options} of the chunk
#' }
#' Note that in case of "rnw" extension the language is always NA
#' @noRd
#'
#' @examples
#'   # rmd
#'   chunk_header_rmd <- "```{r setup, include=FALSE}"
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   parse_chunk_header(chunk_header_rmd, info_patterns)
#'   
#'   # rnw
#'   chunk_header_rnw <- "<<setup, include=FALSE>>="
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   parse_chunk_header(chunk_header_rnw, info_patterns)
#'   

parse_chunk_header <- function(chunk_header, info_patterns){
  
  # remove boundaries 
  chunk_header <- gsub(info_patterns$chunk_header_start, "", chunk_header)
  chunk_header <- gsub(info_patterns$chunk_header_end, "", chunk_header)

  # parse each part
  transform_params(chunk_header, extension = info_patterns$extension)

}

#----    digest_chunk_header    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L45
# adapted to consider rmd and rnw

#' Digest chunk header
#' 
#' 
#' @param chunk_header_index integer indicating the line index of the chunch
#'   header
#' @param lines a character vector with the text lines of the file  
#' @param info_patterns a list with the regex pattern according to file
#'   extension, returned by get_extension_patterns() function
#'
#' @return  a tibble with \itemize{
#'   \item{language} of the chunk
#'   \item{name} of the chunk
#'   \item{options} of the chunk
#' }
#' Note that in case of "rnw" extension the language is always NA
#' @noRd
#'
#' @examples
#'   # rmd
#'   lines <- readLines("tests/testthat/test_files/examples/example-1.Rmd")
#'   info_patterns <- get_extension_patterns(extension = "rmd")
#'   chunk_header_index <- which(grepl(info_patterns$chunk_header_start, lines))[1]
#'   digest_chunk_header(chunk_header_index, lines, info_patterns)
#'   
#'   # rnw
#'   lines <- readLines("tests/testthat/test_files/examples/example-1.Rnw")
#'   info_patterns <- get_extension_patterns(extension = "rnw")
#'   chunk_header_index <- which(grepl(info_patterns$chunk_header_start, lines))[1]
#'   digest_chunk_header(chunk_header_index, lines, info_patterns)
#'   

digest_chunk_header <- function(chunk_header_index,
                                lines, 
                                info_patterns){
  # parse the chunk header
  chunk_info <- parse_chunk_header(
    chunk_header = lines[chunk_header_index], 
    info_patterns = info_patterns)

  return(chunk_info)
}

#----    transform_params    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L3
# adapted to consider rmd and rnw

#' Transform Parameters
#' 
#' not elegant, given a part of a header, transform it into the row of a tibble
#' 
#' @param params a string indicating the content of a chunk header
#' @param extension a indicating the extension of the file ("rmd" or "rnw")
#'
#' @return  a tibble with \itemize{
#'   \item{language} of the chunk
#'   \item{name} of the chunk
#'   \item{options} of the chunk
#' }
#' Note that in case of "rnw" extension the language is always NA
#' @noRd
#'
#' @examples
#'   # rmd
#'   params_rmd <- "r setup, include=FALSE"
#'   transform_params(params_rmd, extension = "rmd")
#'   
#'   # rnw
#'   params_rnw <- "setup, include=FALSE"
#'   transform_params(params_rnw, extension = "rnw")
#'   

transform_params <- function(params, extension){
  params_string <- try(eval(parse(text = paste('alist(', quote_label(params), ')'))),
                       silent = TRUE)

  if(inherits(params_string, "try-error")){
    params <- sub(" ", ", ", params)
    params_string <- eval(parse(text = paste('alist(', quote_label(params), ')')))
  }
  
  if (extension == "rmd"){
    res <- parse_label_rmd(params_string, params)
  } else if (extension == "rnw") {
    res <- parse_label_rnw(params_string, params)
  }
  
  return(res)
}

#----    parse_label_rmd    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L20

parse_label_rmd <- function(label, params){
  
  if(length(label) < 1 || (!is.null(names(label)[1]) && names(label)[1]!= "")){
    # chunk with no language e no name only options
    language <-  NA
    name_chunk <-  NA
    options <-  params
  } else {
  language_name <- sub(",?\\s+", "\\/", label[[1]])
  language_name <- unlist(strsplit(language_name, "\\/"))
  
  language <-  trimws(language_name[1])
  name_chunk <- ifelse(length(language_name) == 1L, NA, trimws(language_name[2]))
  options <-  sub(label[[1]], "", params)
  }
  
  data.frame(language = language,
             name = name_chunk,
             options = options, 
             stringsAsFactors = FALSE)
}


#----    parse_label_rnw    ----

parse_label_rnw <- function(label, params){
  
  if(length(label) < 1 || (!is.null(names(label)[1]) && names(label)[1]!= "")){ 
    # empty chunk  (e.g., <<>>=) or 
    # chunk with arguments but not name (e.g., <<eval = TRUE>>=)
    name_chunk <- NA
    options <- params
  } else { # chunk with name
    name_chunk <- trimws(label[1])
    options <- sub(label[[1]], "", params)
  }
  
  data.frame(language = NA,
             name = name_chunk,
             options = options, 
             stringsAsFactors = FALSE)
}

#----
