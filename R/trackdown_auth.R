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
    client = trackdown_oauth_client() %||% trackdown_client(),
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
#' # see the current user-configured OAuth client (probaby `NULL`)
#' trackdown_oauth_client()
#'
#' if (require(httr)) {
#'
#'   # store current state, so we can restore
#'   original_client <- trackdown_oauth_client()
#' 
#'   # bring your own client via client id (aka key) and secret
#'   google_client <- gargle::gargle_oauth_client(
#'     id = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz",
#'     name = "my-awesome-google-api-wrapping-package",
#'   )
#'   trackdown_auth_configure(client = google_client)
#'
#'   # confirm current client
#'   trackdown_oauth_client()
#'   
#'   # restore original state
#'   trackdown_auth_configure(client = original_client)
#'   trackdown_oauth_client()
#' }
#' 
#' \dontrun{
#' # bring your own client via JSON downloaded from Google Developers Console
#' trackdown_auth_configure(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
#' 

trackdown_auth_configure <- function(client, path,  app = deprecated()) {
  if (lifecycle::is_present(app)) {
    lifecycle::deprecate_warn(
      "1.5.1",
      "trackdown_auth_configure(app)",
      "trackdown_auth_configure(client)"
    )
    client <- app
  }
  
  if (!missing(client) && !missing(path)) {
    stop("Must supply exactly one of `client` and `path`", call. = FALSE)
  }
  if (!missing(path)) {
    stopifnot(is_string(path))
    # The transition from OAuth "app" to OAuth "client" is fully enacted from
    # gargle 1.4.0.900
    if (packageVersion('gargle') >= '1.4.0.900'){
      client <- gargle::oauth_client_from_json(path)
    } else {
      client <- gargle::oauth_app_from_json(path)
    }
    
  }
  
  stopifnot(missing(client) || is.null(client) || inherits(client, "gargle_oauth_client"))
  
  # The transition from OAuth "app" to OAuth "client" is fully enacted from
  # gargle 1.4.0.900
  if (packageVersion('gargle') >= '1.4.0.900'){
    .auth$set_client(client)
  } else {
    .auth$set_app(client)
  }
  
  # Configure googledrive authorization to force using the same client credentials
  googledrive::drive_auth_configure(client = client)
  
  invisible(.auth)
}

#----    trackdown_oauth_client    ----

#' @export
#' @rdname trackdown_auth_configure
trackdown_oauth_client <- function() {
  # The transition from OAuth "app" to OAuth "client" is fully enacted from
  # gargle 1.4.0.900
  if (packageVersion('gargle') >= '1.4.0.900'){
    res <- .auth$client
  } else {
    res <- .auth$app
  }
  return(res)
}

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

#----    trackdown_client    -----

#' Get trackdown Client Credentials
#'
#' @return NULL
#' @noRd
#' 

trackdown_client <- function(){
  check_from_trackdown(parent.frame())
  .trackdown_auth()
}

#----    active_trackdown_client    ----

#' Set trackdown Client API
#' 
#' Check first if personal client specified via environmental variable
#' 'TRACKDOWN_CLIENT' indicating the path to the JSON file with the credentials.
#' Otherwise, use currently specified client or use internal default trackdown
#' credentials.
#' 
#' It also forces googledrive to use the same client credentials.
#' 
#' @return NULL
#' @noRd
#'

active_trackdown_client <- function(){
  
  # Check if environmental variable is set for the JSON file of personal client
  path <- Sys.getenv("TRACKDOWN_CLIENT", unset = NA)
  if(!is.na(path)){
    trackdown_auth_configure(path = path)
  } else {
    
    # Set Client using client info
    # If current client is null use internal default trackdown credentials
    client <-  trackdown_oauth_client() %||% trackdown_client()
    trackdown_auth_configure(client = client)
  }
  
  invisible()
}

