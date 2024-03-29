% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trackdown_auth.R
\name{trackdown_deauth}
\alias{trackdown_deauth}
\title{Clear current token}
\usage{
trackdown_deauth()
}
\description{
Clears any currently stored token. The next time trackdown needs a token, the
token acquisition process starts over, with a fresh call to
\code{\link[=trackdown_auth]{trackdown_auth()}} and, therefore, internally, a call to
\code{\link[gargle:token_fetch]{gargle::token_fetch()}}. Unlike some other packages that use gargle,
trackdown is not usable in a de-authorized state. Therefore, calling
\code{trackdown_deauth()} only clears the token, i.e. it does NOT imply that
subsequent requests are made with an API key in lieu of a token.
}
\examples{
\dontrun{
trackdown_deauth()
trackdown_user()
}

}
\seealso{
Other auth functions: 
\code{\link{trackdown_auth_configure}()},
\code{\link{trackdown_auth}()}
}
\concept{auth functions}
