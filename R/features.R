########################
####    Features    ####
########################

#----    remove_google_comments    ----

#' Remove Google Comments
#'
#' Remove Google comments from the downloaded file. Comments are all listed at
#' the bottom of the file. They are of type "[a]my comment" and the tag is also
#' present in the text. Tags have character indexes.
#'
#' @param document document character vector with the lines of the document 
#'
#' @return
#' @noRd
#' 
#' @examples
#' document <- readLines("tests/testthat/test_files/examples/Comments-restore.Rmd")
#' remove_google_comments(document)
#' 

remove_google_comments <- function(document){
  
  # Identify comments
  line_comments <- grep("^\\[[a-z]+\\]", x = document, perl = TRUE)
  
  # If the last line is not a comment return
  if(!(length(document)) %in% line_comments){
    start_process("No Google comments found")
    return(document)
  }
  
 
  # Real comments are all at the bottom of the file. Identify them according to
  # index difference, is the last sequence of 1
  seq_comments <- rle(diff(line_comments)) 
  # Identify number of comments
  if(tail(seq_comments$values,1) == 1L){
    n_comments <- tail(seq_comments$lengths,1) + 1 # correct number of elements
  } else {
    n_comments <- 1 # only one comment
  }
  
  # Get correct comments sequence
  line_comments <- tail(line_comments, n_comments)
  
  # Save which comment have issues
  issue_comment <- data.frame(index = vector("character"),
                              line = vector("numeric"))
  
  for(i in line_comments){
    # Extract comment index from comment line
    comment_index <- gsub("^\\[([a-z]+)\\].*", replacement = "\\1", document[i], perl = TRUE)
    pattern <- paste0("\\[",comment_index,"\\]")
    
    # Find comment in the text
    line_with_comment <- grep(pattern, document[-i], perl = TRUE)
    text_comment <- document[line_with_comment[1]]
    
    # Check there is only one pattern occurency in the text
    n_patterns <- length(regmatches(text_comment, gregexpr(pattern, text_comment))[[1]])
    
    if(length(line_with_comment) == 1L && n_patterns == 1L){
      document[line_with_comment[1]] <- gsub(pattern, replacement = "", text_comment)
    } else{
      issue_comment <- rbind(issue_comment, data.frame(index = comment_index, 
                                                       line = i))
    }
  }
  
  if(nrow(issue_comment)>0){
    start_process(paste("Issue in identifying Google comment(s):", 
                    paste0("[", issue_comment$index, "]", collapse = " ")))
  }
  
  # Remove comment from the bottom of the file
  lines_to_remove <- setdiff(line_comments, issue_comment$line)
  if(length(lines_to_remove)>0){
    document <- document[-lines_to_remove]
  }
  
  return(document)
}

#----
