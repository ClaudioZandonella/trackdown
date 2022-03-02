###############################
####    Rich Text Utils    ####
###############################

#====    highlight Text    ====

#----    get_param_highlight_text    ----

get_param_highlight_text <- function(text, 
                                     extension,
                                     rich_text_par = NULL){
  
  # Set default colour if not specified
  if(is.null(rich_text_par["rgb_color"])){
    # Opaque yellow
    rgb_color <- list(red = 255/255,
                      green = 204/255,
                      blue = 102/255)
  } else {
    rgb_color <- rich_text_par[["rgb_color"]]
  }
  
  patterns <- get_patterns_highlight(text = text,
                                     extension = extension)
  
  indexes_list <- lapply(patterns, function(x)
    get_range_index(pattern = x, text = text))
  
  indexes <- do.call("rbind", indexes_list)
  
  res <- apply(indexes, MARGIN = 1, function(x){
    template_highlight_text(start_index = x["start_index"], 
                            end_index = x["end_index"], 
                            rgb_color = rgb_color)
  })
  
  return(res)
}

#----    get_patterns_highlight    ----

get_patterns_highlight <- function(text, extension){
  
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
    patterns <- NULL
  }
  
  res <- c(
    # Instructions: all lines included between "#----Trackdown Instructions----#" and "#----End Instructions----#"
    "#----Trackdown Instructions----#[\\s\\S]*#----End Instructions----#",
    patterns
  )
  
  return(res)
}


#----    get_range_index    ----

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
