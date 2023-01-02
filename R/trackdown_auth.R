##############################
####    Trackdown Auth    ####
##############################

# Follow gargle and googledrie recommendations
# https://gargle.r-lib.org/articles/gargle-auth-in-client-package.html
# https://googledrive.tidyverse.org/articles/bring-your-own-app.html

#----    check_from_trackdown    ----

#' Check Call is from trackdown
#'
#' @param env environmet call
#'
#' @return NULL
#' @noRd
#' 

check_from_trackdown <- function (env = parent.frame()){
  
  env <- topenv(env, globalenv())
  
  if (!isNamespace(env)) {
    is_trackdown <- FALSE
  } else {
    nm <- getNamespaceName(env)
    is_trackdown <- nm == "trackdown"
  }
  
  if (!is_trackdown) {
    msg <- c("Attempt to directly access a credential that can only be used within trackdown package.")
    stop(msg, call. = FALSE)
  }
  
  # invisible(env)
}

#----    trackdown_app    -----

#' Get trackdown Client Credentials
#'
#' @return NULL
#' @noRd
#' 

trackdown_app <- function(){
  # priority to user provided app
  user_app <- getOption("trackdown-app")
  if (!is.null(user_app)) {
    return(user_app)
  }
  
  check_from_trackdown(parent.frame())
  .trackdown_auth()
}

#----    active_trackdown_app    ----

#' Set trackdown Client API
#'
#' @return NULL
#' @noRd
#'

active_trackdown_app <- function(){
  googledrive::drive_auth_configure(app = trackdown_app())
}

