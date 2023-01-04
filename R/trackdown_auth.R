##############################
####    Trackdown Auth    ####
##############################

# Follow gargle and googledrie recommendations
# https://gargle.r-lib.org/articles/gargle-auth-in-client-package.html
# https://googledrive.tidyverse.org/articles/bring-your-own-app.html

# This file is the interface between trackdown and the auth functionality in
# gargle.

#----    Settings    ----

# Initialization happens in .onLoad()
.auth <- NULL

## The roxygen comments for these functions are mostly generated from data
## in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "trackdown",
  YOUR_STUFF  = "your trackdown files",
  PRODUCT     = "trackdown",
  API         = "trackdown API",
  PREFIX      = "trackdown"
)

#----    trackdown_auth    ----

#' Authorize trackdown
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params()
#'
#' @family auth functions
#' @export
#'
#' @examples
#' \dontrun{
#' # load/refresh existing credentials, if available
#' # otherwise, go to browser for authentication and authorization
#' trackdown_auth()
#'
#' # see user associated with current token
#' trackdown_user()
#'
#' # force use of a token associated with a specific email
#' trackdown_auth(email = "myemail@example.com")
#' trackdown_user()
#'
#' # force a menu where you can choose from existing tokens or
#' # choose to get a new one
#' trackdown_auth(email = NA)
#'
#' # use a 'read only' scope, so it's impossible to edit or delete files
#' # NOTE thaat this will allow only to download files from the drive 
#' trackdown_auth(
#'   scopes = "https://www.googleapis.com/auth/drive.readonly"
#' )
#'
#' # use a service account token
#' trackdown_auth(path = "foofy-83ee9e7c9c48.json")
#' }
trackdown_auth <- function(email = gargle::gargle_oauth_email(),
                           path = NULL,
                           scopes = "https://www.googleapis.com/auth/drive",
                           cache = gargle::gargle_oauth_cache(),
                           use_oob = gargle::gargle_oob_default(),
                           token = NULL) {
  
  cred <- gargle::token_fetch(
    scopes = scopes,
    app = trackdown_oauth_app() %||% trackdown_app(),
    email = email,
    path = path,
    package = "trackdown",
    cache = cache,
    use_oob = use_oob,
    token = token
  )
  if (!inherits(cred, "Token2.0")) {
    stop(
      "Can't get Google credentials.\n",
      "Are you running trackdown in a non-interactive session? Consider:\n",
      "  * Call `trackdown_auth()` directly with all necessary specifics.\n",
      "See gargle's \"Non-interactive auth\" vignette for more details:\n",
      "https://gargle.r-lib.org/articles/non-interactive-auth.html",
      call. = FALSE
    )
  }
  
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)
  
  invisible()
}

#----    trackdown_deauth    ----

#' Clear current token
#'
#' Clears any currently stored token. The next time trackdown needs a token, the
#' token acquisition process starts over, with a fresh call to
#' [trackdown_auth()] and, therefore, internally, a call to
#' [gargle::token_fetch()]. Unlike some other packages that use gargle,
#' trackdown is not usable in a de-authorized state. Therefore, calling
#' `trackdown_deauth()` only clears the token, i.e. it does NOT imply that
#' subsequent requests are made with an API key in lieu of a token.
#' 
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' trackdown_deauth()
#' trackdown_user()
#' }
#' 

trackdown_deauth <- function() {
  .auth$clear_cred()
  invisible()
}

#----    trackdown_token    ----

#' Produce configured token
#'
#' @eval gargle:::PREFIX_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_token_return()
#'
#' @family low-level API functions
#' @export
#' @examples
#' \dontrun{
#' trackdown_token()
#' }
#' 

trackdown_token <- function() {
  if (!trackdown_has_token()) {
    trackdown_auth()
  }
  httr::config(token = .auth$cred)
}

#----    trackdown_has_token    ----

#' Is there a token on hand?
#'
#' @eval gargle:::PREFIX_has_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_has_token_return()
#'
#' @family low-level API functions
#' @export
#'
#' @examples
#' trackdown_has_token()
trackdown_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

#----    trackdown_auth_configure    ----

#' Edit and view auth configuration
#'
#' @eval gargle:::PREFIX_auth_configure_description(gargle_lookup_table, .has_api_key = FALSE)
#' @eval gargle:::PREFIX_auth_configure_params(.has_api_key = FALSE)
#' @eval gargle:::PREFIX_auth_configure_return(gargle_lookup_table, .has_api_key = FALSE)
#'
#' @family auth functions
#' @export
#' @examples
#' # see the current user-configured OAuth app (probaby `NULL`)
#' trackdown_oauth_app()
#'
#' if (require(httr)) {
#'
#'   # store current state, so we can restore
#'   original_app <- trackdown_oauth_app()
#' 
#'   # bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   trackdown_auth_configure(app = google_app)
#'
#'   # confirm current app
#'   trackdown_oauth_app()
#'   
#'   # restore original state
#'   trackdown_auth_configure(app = original_app)
#'   trackdown_oauth_app()
#' }
#' 
#' \dontrun{
#' # bring your own app via JSON downloaded from Google Developers Console
#' trackdown_auth_configure(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
#' 

trackdown_auth_configure <- function(app, path) {
  if (!missing(app) && !missing(path)) {
    stop("Must supply exactly one of `app` and `path`", call. = FALSE)
  }
  
  if (!missing(path)) {
    stopifnot(is_string(path))
    app <- gargle::oauth_app_from_json(path)
  }
  stopifnot(is.null(app) || inherits(app, "oauth_app"))
  
  .auth$set_app(app)
  
  # Configure googledrive authorization to force using the same app credentials
  googledrive::drive_auth_configure(app = app)
  
  invisible(.auth)
}

#----    trackdown_oauth_app    ----

#' @export
#' @rdname trackdown_auth_configure
trackdown_oauth_app <- function() .auth$app

#----    trackdown_user    ----

#' Get info on current user
#'
#' @eval gargle:::PREFIX_user_description()
#' @eval gargle:::PREFIX_user_seealso()
#' @eval gargle:::PREFIX_user_return()
#'
#' @export
#' @examples
#' \dontrun{
#' trackdown_user()
#' }
#' 

trackdown_user <- function() {
  if (trackdown_has_token()) {
    gargle::token_email(trackdown_token())
  } else {
    NULL
  }
}

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
  check_from_trackdown(parent.frame())
  .trackdown_auth()
}

#----    active_trackdown_app    ----

#' Set trackdown Client API
#' 
#' Check first if personal app specified via environmental variable
#' 'TRACKDOWN_APP' indicating the path to the JSON file with the credentials.
#' Otherwise, use currently specified app or use internal default trackdown
#' credentials.
#' 
#' It also forces googledrive to use the same app credentials.
#' 
#' @return NULL
#' @noRd
#'

active_trackdown_app <- function(){
  
  # Check if environmental variable is set for the JSON file of personal app
  path <- Sys.getenv("TRACKDOWN_APP", unset = NA)
  if(!is.na(path)){
    trackdown_auth_configure(path = path)
  } else {
    
    # Set Client using app info
    # If current app is null use internal default trackdown credentials
    app <-  trackdown_oauth_app() %||% trackdown_app()
    trackdown_auth_configure(app = app)
  }
  
  invisible()
}

