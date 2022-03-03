###############################
####    Rich Text Utils    ####
###############################

#====    highlight Text    ====

#----    get_param_highlight_text    ----

#' Get the Highlight Text Request Parameters
#'
#' Get an UN-NAMED list with all the "updateTextStyle" requests. Each request
#' highlights a document text section. Sections to highlight are found according
#' to patterns defined in get_patterns_highlight() function. The structure of
#' each request is defined in template_highlight_text(). 
#' 
#' If "rgb_color" element is specified in the "rich_text_par" list argument, it
#' is used to customize the hihglihg color. The rgb_color element has to be a
#' list with elements red, green, and blue specifying has to be a numeric value
#' between 0 and 1.
#'
#' See example structure request at
#' https://developers.google.com/docs/api/how-tos/format-text
#'
#' @param text a single string with the parsed document that has been uploaded
#'   to Google Drive.
#' @param extension string indicating the file extension ("rmd" or "rnw").
#' @param rich_text_par list with custom settings of the parameters of the API
#'   request.
#'
#' @return UN-NAMED list with all the requests and their specific paraameters.
#'
#' @noRd
#' @examples
#' file <- "tests/testthat/test_files/examples/example-rich-text.Rmd"
#' file_info <- get_file_info(file)
#' text <- format_document(readLines(file), file_info = file_info, hide_code = FALSE)
#' extension = "rmd"
#' rich_text_par = NULL
#'
#' get_param_highlight_text(text = text, extension = extension)
#' 

get_param_highlight_text <- function(text, 
                                     extension,
                                     rich_text_par = NULL){
  
  # Set default colour if not specified
  if(is.null(rich_text_par[["rgb_color"]])){
    # Opaque yellow
    rgb_color <- list(red = 255/255,
                      green = 204/255,
                      blue = 102/255)
  } else {
    rgb_color <- rich_text_par[["rgb_color"]]
  }
  
  # Find indexes of text sections to highlight according to specific patterns 
  patterns <- get_patterns_highlight(extension = extension)
  
  indexes_list <- lapply(patterns, function(x)
    get_range_index(pattern = x, text = text))
  
  indexes <- do.call("rbind", indexes_list)
  
  # Get an UN-NAMED list of all the requests with their parameters
  res <- apply(indexes, MARGIN = 1, function(x){
    template_highlight_text(start_index = x["start_index"], 
                            end_index = x["end_index"], 
                            rgb_color = rgb_color)
  })
  
  return(res)
}

#----    get_patterns_highlight    ----

#' Get Regex Patterns to Highlight
#'
#' Get the regex patterns used to find the important text to highlight. These
#' include the instructions added at the top of the document and the code chunk
#' place-holders. Plus, according to the document extension ("rmd" or "rnw"),
#' there are specific patterns for the header of the document (YAML header or
#' LaTeX preamble), code chunks, and in-line code.
#'
#' @param extension string indicating the file extension ("rmd" or "rnw").
#'
#' @return a character vector
#' @noRd
#'
#' @examples
#' get_patterns_highlight(extension = "rmd")
#' 

get_patterns_highlight <- function(extension){
  
  # Regex notes:
  # -  [\s\S]* all characters including new line (\s matches white spaces)
  # -  .*? non-greedy
  # -  (?<=a)b Positive lookbehind: Matches "b" if is preceded by "a"
  # -  (?<!a)b Negative lookbehind: Matches "b" if is NOT preceded by "a"
  
  if(extension == "rmd"){
    patterns <- c(
      # Header: all lines included between "---" and "---". Must be preceded by "#----End Instructions----#"
      "(?<=#----End Instructions----#\n)---[\\s\\S]*?\n---",
      # Chunks: all lines included between "```" and "```". Must be on different lines
      "(?<=\n)```[^`]*\n[\\s\\S]*?```",
      # In-line Code
      "`r [^`]+`"
    )
  } else {
    patterns <- c(
      # Header: all lines included between "\documentclass{" and "\begin{document}". Must not be preceded by other "\" to avoid match possible document text
      "(?<!\\\\)\\\\documentclass\\{[\\s\\S]*?\\\\begin\\{document\\}",
      # Chunks: all lines included between "<<...>>=" and "@".
      "<<.*?>>=[\\s\\S]*?\\s*@\\s*?",
      # In-line Code
      "\\\\Sexpr{.+?}"
    )
  }
  
  res <- c(
    # Instructions: all lines included between "#----Trackdown Instructions----#" and "#----End Instructions----#"
    "#----Trackdown Instructions----#[\\s\\S]*#----End Instructions----#",
    # Place-Holders: find place-holders of type [[document-*]] or [[chunk-*]]
    "(?<=\n)\\[\\[(document|chunk)-.+?\\]\\]",
    patterns
  )
  
  return(res)
}


#----    get_range_index    ----

#' Get Range Index
#'
#' Get the starting end ending index position of each regex pattern match that
#' occurs in the text.
#'
#' @param pattern string indicating the regex used to find the important text to
#'   highlight. This is an element of the vector of patterns obtained from
#'   get_patterns_highlight().
#' @param text a single string with the parsed document that has been uploaded
#'   to Google Drive.
#'
#' @return a data frame indicating for each match:\itemize{ 
#'   \item{start_index} starting position index  
#'   \item{end_index} ending position index  
#'   }
#'
#' @noRd
#' @examples
#' file <- "tests/testthat/test_files/examples/example-rich-text.Rmd"
#' file_info <- get_file_info(file)
#' text <- format_document(readLines(file), file_info = file_info, hide_code = FALSE)
#' pattern <- get_patterns_highlight("rmd")[1]
#' get_range_index(pattern = pattern, text = text)
#' 


get_range_index <- function(pattern, text){
  
  matches <- gregexpr(pattern = pattern, 
                      text = text, perl = TRUE)[[1]]
  
  match_length <- attr(matches, which = "match.length")
  
  res <- data.frame(start_index = matches,
                    end_index = matches + match_length)
  
  # keep only actual matches; -1 is returned if no match 
  res <- res[matches >= 0,]
  
  return(res)
}

#----    template_highlight_text    ----

#' Template Highlight Text
#' 
#' Template of updateTextStyle API request to highlight a text section given its
#' starting and ending position indexes. See updateTextStyle request structure
#' at https://developers.google.com/docs/api/reference/rest/v1/documents/request#updatetextstylerequest
#'
#' @param start_index numeric value indicating the starting position index
#' @param end_index numeric value indicating the ending position index
#' @param rgb_color list with red, green, and blue elements used to define the
#'   highlight colour
#'   
#' @return a named list with all the parameters used in a updateTextStyle API
#'   request to highlight a text section.
#' 
#' @noRd
#' @examples
#' start_index <- 1
#' end_index <- 10
#' template_highlight_text(start_index = start_index, end_index = end_index)
#' 

template_highlight_text <- function(start_index, 
                                    end_index, 
                                    rgb_color = list(red = 255/255,
                                                     green = 204/255,
                                                     blue = 102/255)){
  
  res <- list(
    updateTextStyle = list(
      range = list(
        startIndex = start_index,
        endIndex = end_index
      ),
      textStyle = list(
        backgroundColor = list(
          color = list(
            rgbColor = rgb_color
          )
        )
      ),
      fields = "*")
  )
  
  return(res)
}


#====    Insert Image    ====

# [TODO]

#----
