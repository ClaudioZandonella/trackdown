#########################
####    trackdown    ####
#########################

#----    Package documentation    ----

#' trackdown - R package for collaborative writing and editing
#'
#' The \code{trackdown} package offers a simple answer to collaborative writing
#' and editing of R Markdown (or Sweave) documents. Using \code{trackdown}, the
#' local \code{.Rmd} (or \code{.Rnw}) file is uploaded as plain-text in Google
#' Drive where, thanks to the easily readable Markdown (or LaTeX) syntax and the
#' well-known online interface offered by Google Docs, collaborators can easily
#' contribute to the writing and editing of the document. After integrating all
#' authors’ contributions, the final document can be downloaded and rendered
#' locally.
#'
#' @section The trackdown Workflow:
#'  When collaborating on the writing of a \code{.Rmd} (or \code{.Rnw}) document
#'  it is important to consider separately code and prose:
#'
#'  \itemize{ 
#'   \item{\strong{Code} - Collaborative code writing is done efficiently
#'   following traditional \strong{Git} workflow based on an online repository
#'   (e.g., GitHub or GitLab)}
#'   \item{\strong{Prose} - Collaborative
#'   prose writing is done efficiently on \strong{Google Docs} where the familiar
#'   and simple online interface allows multiple users to simultaneously write
#'   and edit the same document} 
#'   }
#'
#'  Thus, the workflow main idea is very simple: upload the \code{.Rmd} (or
#'  \code{.Rnw}) document to Google Drive for collaborative prose writing in
#'  Google Docs and download the document locally to continue working on the
#'  code using Git. This iterative process of uploading to and downloading from
#'  Google Drive continues until the desired results are obtained. The workflow
#'  can be summarized as:
#'
#'  \emph{Collaborative \strong{code} writing using \strong{Git} and
#'  collaborative \strong{prose} writing on \strong{Google Docs}}
#'   
#' @section Functions:
#'  The package \code{trackdown} offers simple functions to manage the workflow:
#'  \itemize{
#'   \item{\code{\link{upload_file}} - upload a file for the first time to Google
#'         Drive}
#'   \item{\code{\link{update_file}} - update the content of an existing file in
#'         Google Drive with the contents of a local file}
#'   \item{\code{\link{download_file}} - download edited version of a file from Google
#'         Drive updating the local version}
#'   \item{\code{\link{render_file}} - download and render a file from Google Drive}
#'  }
#'  
#' @section Special Features:
#' The Package \code{trackdown} offers special features to facilitate the
#' collaborative writing and editing of a document on Google Docs. In
#' particular, it is possible to:
#' \itemize{
#'   \item{\strong{Hide Code} - The header code (YAML or LaTeX settings) and
#'   code chunks are removed from the document when uploaded to Google Drive and
#'   automatically restored when downloaded. This prevents collaborators from
#'   inadvertently making changes to the code that might corrupt the file and it
#'   allows collaborators to focus only on the plain text ignoring code jargon.}
#'   \item{\strong{Upload Output} - The actual output (i.e., the resulting
#'   complied document) can be uploaded in Google Drive together with the \code{.Rmd}
#'   (or \code{.Rnw}) document. This helps collaborators to evaluate the overall
#'   layout, figures and tables and it allows them to use comments to propose
#'   and discuss suggestions.}
#'   \item{\strong{Google Team Drive} - The documents can be uploaded on your
#'   personal Google Drive or on a shared Google Team Drive to facilitate
#'   collaboration.}
#'  }
#'  
#' @section Advantages of Google Docs:
#'  Google Docs offers a familiar, intuitive, and free online interface that
#'  allows multiple users to simultaneously write and edit the same document. In
#'  Google Docs is it possible to:
#'  \itemize{
#'   \item{easily track changes}
#'   \item{add comments to propose and discuss suggestions}
#'   \item{check spelling and grammar errors (also using Grammarly)}
#'  }
#'  Moreover, Google Docs  allows anyone to collaborate on the document as no
#'  programming experience is required, they only have to focus on the plain
#'  text ignoring code jargon.
#'  
#'  Note that a Google account is not required for all collaborators (although
#'  recommended to access all Google Docs features). Only the person who manages
#'  the \code{trackdown} workflow requires a Google account to upload files in Google
#'  Drive. Other collaborators can be invited to contribute to the document
#'  using a shared link.
#'  
#' @section Documentation and Vignettes:
#'  All the documentation is available at \url{https://ekothe.github.io/trackdown/}.
#'  
#'  To know more about the \code{trackdown} see:
#'  \itemize{
#'   \item{\code{vignette("trackdown-features")} - for detailed description of the
#'   functions arguments and features}
#'   \item{\code{vignette("trackdown-workflow")} - for a workflow example and a
#'   discussion about collaboration on prose and code}
#'   \item{\code{vignette("trackdown-tech-notes")} - for details regarding
#'   technical aspects as authentication and file management}
#'  }
#'
#' @importFrom utils tail
#'
#' @docType package
#' @name trackdown-package
NULL



#----
