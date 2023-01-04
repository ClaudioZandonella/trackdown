##################################
####    Rich Text Features    ####
##################################

# Follow gargle recommendations
# https://gargle.r-lib.org/articles/request-helper-functions.html

#----    run_rich_text    ----

#' Run Rich Text
#'
#' Build and make Google Docs API request to obtain a rich document. The
#' important text that should not be changed is highlighted in the Docs
#' document. This includes, added Instructions at the top of the document,
#' Placeholders hiding the code, header of the document (YAML header or LaTeX
#' preamble), code chunks, and in-line code. The `rich_text_par` argument is
#' used to pass custom values used to generate the API request.
#'
#' @param text a single string with the parsed document that has been uploaded
#'   to Google Drive.
#' @param document_ID string indicating the Docs file ID.
#' @param extension string indicating the file extension ("rmd" or "rnw").
#' @param rich_text_par list with custom settings of the parameters of the API
#'   request.
#'
#' @return list with the response content of the request returned by
#'   gargle::response_process() function.
#'
#' @noRd
#' @examples
#'
#' file <- "tests/testthat/test_files/examples/example-rich-text.Rmd"
#' file_info <- get_file_info(file)
#' text <- format_document(readLines(file), file_info = file_info, hide_code = FALSE)
#' document_ID <- "1Kcx5-F8b7RQBmndTZ7YHhlGH2DTgwdM9gLy0MoHtOPc"
#' extension = "rmd"
#' rich_text_par = NULL
#'
#' run_rich_text(text = text, document_ID = document_ID, extension = extension)
#' 

run_rich_text <-  function(text, 
                           document_ID, 
                           extension = c("rmd", "rnw"),
                           rich_text_par = NULL){
  
  extension <- match.arg(extension)
  
  param_request <- get_param_request(text = text,
                                     document_ID = document_ID,
                                     extension = extension,
                                     rich_text_par = rich_text_par)
  
  request <- build_request(endpoint = "docs.documents.batchUpdate",
                           params = param_request,
                           key = NULL,
                           token = trackdown_token(),
                           base_url = "https://docs.googleapis.com")
  
  response <- gargle::request_make(request)
  res <- gargle::response_process(response)

  return(res)
}

#----    get_param_request    ----

#' Get Parameters of API Request
#'
#' Create a named list with all the information required to generate the API
#' request. We need to specify the document ID and the requests elements. The
#' requests element is an UN-NAMED list where each element is a specific request
#' with all its arguments. For an example of request structure, see
#' https://developers.google.com/docs/api/how-tos/format-text  and
#' https://developers.google.com/docs/api/reference/rest/v1/documents/request
#' for available requests.
#' 
#' Schema:
#'   - documentId
#'   - requests
#'          |- request #1
#'          |- request #2
#'          |- ...
#'
#' Currently, only highlight text (through updateTextStyle) is implemented.
#'
#' @param text a single string with the parsed document that has been uploaded
#'   to Google Drive.
#' @param document_ID string indicating the Docs file ID.
#' @param extension string indicating the file extension ("rmd" or "rnw").
#' @param rich_text_par list with custom settings of the parameters of the API
#'   request.
#'
#' @return a list with with all the parameters required to generate the API
#'   request.
#'
#' @noRd
#'
#' @examples
#' file <- "tests/testthat/test_files/examples/example-rich-text.Rmd"
#' file_info <- get_file_info(file)
#' text <- format_document(readLines(file), file_info = file_info, hide_code = FALSE)
#' document_ID <- "1Kcx5-F8b7RQBmndTZ7YHhlGH2DTgwdM9gLy0MoHtOPc"
#' extension = "rmd"
#' rich_text_par = NULL
#'
#' get_param_request(text = text, document_ID = document_ID, extension = extension)
#' 

get_param_request <-  function(text, 
                               document_ID, 
                               extension, 
                               rich_text_par = NULL){
  
  # Highlight text
  param_highlight_text <- get_param_highlight_text(text = text,
                                                   extension = extension,
                                                   rich_text_par = rich_text_par)
  
  # Insert images
  param_insert_image <- NULL
  
  res <- list(
    documentId = document_ID,
    requests = c(param_highlight_text,
                 param_insert_image)
  )
  
  return(res)
}

#----    build_request    ----

#' Build the Google API Request
#'
#' Build the Google API request. This is a general function to create any API
#' request. However, only Google Docs API are currently available. Available
#' endpoints (Google API Methods) and their required parameters info are stored
#' in the package internal object ".endpoints", this includes
#' "docs.documents.batchUpdate", "docs.documents.get", and
#' "docs.documents.batchUpdate". For more details, see
#' https://gargle.r-lib.org/articles/request-helper-functions.html.
#'
#' @param endpoint string indicating the endpoint (method of the Google API)
#' @param params named list with all the information used to generate the API
#'   request. This is obtained from get_param_request().
#' @param key string indicating the API key required for requests that don't
#'   contain a token [currently not implemented].
#' @param token Token used for API authentication
#' @param base_url string indicating the API base URL
#'
#' @return named list with \itemize{
#'   \item{method} string indicating the hTTP method (GET or POST) 
#'   \item{url} string indicating the full URL used for the query
#'   \item{body} named list with the body of the query
#'   \item{token} Token used for API authentication
#' }
#' 
#' @noRd
#' @examples
#' file <- "tests/testthat/test_files/examples/example-rich-text.Rmd"
#' file_info <- get_file_info(file)
#' text <- format_document(readLines(file), file_info = file_info, hide_code = FALSE)
#' document_ID <- "1Kcx5-F8b7RQBmndTZ7YHhlGH2DTgwdM9gLy0MoHtOPc"
#' 
#' params <- get_param_request(text = text, document_ID = document_ID, extension = "rmd")
#' endpoint <- "docs.documents.batchUpdate"
#' 
#' build_request(endpoint = endpoint, params = params)
#' 

build_request <- function(endpoint = character(),
                          params = list(),
                          key = NULL,
                          token = trackdown_token(),
                          base_url = "https://docs.googleapis.com"){
  
  # .endpoint is a package internal object with the endpoints available
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop(sprintf("Endpoint '%s' not recognized", endpoint), call. = FALSE)
  }
  
  ## modifications specific to googledrive package
  # params$key <- key %||% params$key %||% drive_api_key()
  # if (!is.null(ept$parameters$supportsTeamDrives)) {
  #   params$supportsTeamDrives <- TRUE
  # }
  
  request <- gargle::request_develop(endpoint = ept, 
                                     params = params,
                                     base_url = base_url)
  
  res <- gargle::request_build(
    path = request$path,
    method = request$method,
    params = request$params,
    body = request$body,
    token = token,
    base_url = base_url)
  
  return(res)
}

#----



