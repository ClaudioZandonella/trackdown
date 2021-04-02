############################
####    Helper Tests    ####
############################

#----    get_auth_credentials    ----

#' Get credential for tests
#'
#' Api functions are tested using the r package \code{vcr}
#' \link{https://books.ropensci.org/http-testing/vcr.html} but authentication is
#' still neded. Credentials of the user trackdown.rpackage@gmail.com are saved in a
#' binary file "tests/testthat/secrets/secret_credentials". To use it the
#' correct token-name is required. This is saved as secret
#' \code{"trackdown-testing-name"} in the package. See
#' \link{https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html}
#' for instruction and settings to write and read secrets. The
#' \code{TRACKDOWN_PASSWORD} is provided by claudiozandonella@gmail.com.
#'
#' This function allows to get the token-name and set the authentication options.
#' Remember that secrets are available only after building the package. So
#' developers require a installed copy of the package (click "Install and
#' Restart" from the build pannel in R-Studio)
#'
#' @return NULL
#'
#' @noRd
#' 

get_auth_credentials <- function(){
  if (gargle:::secret_can_decrypt("trackdown")) {
    file_path <- ifelse(interactive(), "tests/testthat/", "")
    
    token_name <- gargle:::secret_read("trackdown", "trackdown-testing-name")
    
    token_name <- token_name[!token_name=='00']
    token_name <- rawToChar(token_name)
    
    file.rename(from = paste0(file_path, "secrets/secret_credentials"),
                to = paste0(file_path, "secrets/", token_name))
    
    # set options 
    options(
      gargle_oauth_cache = paste0(file_path, "secrets"),
      gargle_oauth_email = "trackdown.rpackage@gmail.com"
    )
    
    googledrive::drive_auth()
    
    file.rename(from = paste0(file_path, "secrets/", list.files(paste0(file_path, "secrets/"))),
                to = paste0(file_path, "secrets/secret_credentials"))
  }
}

#----    skip_if_no_token    ----

#' Skip Test if Token is not Available
#'
#' Internal function form googledrive r-package
#' \link{https://github.com/tidyverse/googledrive/blob/20ffe8cb87ef180246fd3a94e00010879117aaa1/tests/testthat/helper.R#L8}
#'
#' @return NULL
#' @noRd
#' 

skip_if_no_token <- function() {
  testthat::skip_if_not(googledrive::drive_has_token(), "No Drive token")
}

#----



