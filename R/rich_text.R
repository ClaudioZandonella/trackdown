##################################
####    Rich Text Features    ####
##################################

# Follow gargle recommendations
# https://gargle.r-lib.org/articles/request-helper-functions.html

#----    run_rich_text    ----

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
                           token = googledrive::drive_token(),
                           base_url = "https://docs.googleapis.com")
  
  response <- gargle::request_make(request)
  res <- gargle::response_process(response)
  
  return(res)
}

#----    get_param_request    ----

get_param_request <-  function(text, 
                               document_ID, 
                               extension, 
                               rich_text_par = NULL){
  
  
  param_highlight_text <- get_param_highlight_text(text = text,
                                                   extension = extension,
                                                   rich_text_par = rich_text_par)
  
  param_insert_image <- NULL
  
  res <- list(
    documentId = document_ID,
    requests = c(param_highlight_text,
                 param_insert_image)
  )
  
  return(res)
}

#----    build_request    ----

build_request <- function(endpoint = character(),
                          params = list(),
                          key = NULL,
                          token = googledrive::drive_token(),
                          base_url = "https://docs.googleapis.com"){
  
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop(sprintf("\nEndpoint not recognized:\n  * %s", endpoint))
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
    token = googledrive::drive_token(),
    base_url = base_url)
  
  return(res)
}

#----



