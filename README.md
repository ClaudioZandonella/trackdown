
<!-- README.md is generated from README.Rmd. Please edit that file -->

# trackdown

trackdown provides easy functions to move rmd and rmw files to
googledrive for synchronous collaboration, then return it back to a
local .Rmd/.Rnw for knitting.


# Important News

`trackdown` is undergoing a complete revision. In the `master` branch, you can find the previous version of the package (formerly named `rmdrive`). In the `develop` branch, instead, you can find the new version that icludes support for `.Rmd` and `.Rnw` files and other new feature (e.g., hide chunks code). We are still working on the last aspects and on the package documentation but soon it will be ready.

# Installation

This package is not on CRAN. To use this package please run the
following code:

``` r
devtools::install_github("ekothe/trackdown")
library(trackdown)
```

# How to use

A typical workflow where this package is useful is when:

  - you have a google doc that you or someone else has started  
  - you want to turn it into an R Markdown file so you can write R code
    in there, or simply work on it in your preferred editor  
  - you want to keep the R Markdown file in sync with the Google doc
    while you and others work on them together

Let’s assume there is an existing google doc that you want to bring to
your desktop as an R Markdown file. This function will firstly prompt
you to authenticate, and then it will download the google doc into your
current working directory as an Rmd file:

``` r
download_rmd(file = "my-r-markdown-file-name",  # do not include the .Rmd 
             gfile = "My google doc filename")  # name of google doc file
```

Now let’s imagine you do some work on your Rmd, write some code, etc. At
some point you’ll be ready to update the Google doc so your non-R-using
co-authors can see what you’ve done. This line of code will update the
existing Google doc with the changes you made to the Rmd file:

``` r
update_rmd(file = "my-r-markdown-file-name",    # do not include the .Rmd 
           gfile = "My google doc filename")  # name of google doc file
```

You can run that line often while editing, similar to `git commit` (it
does take about 5-10 seconds to complete the update). Imagine now that
some time passes and your co-author has updated the Google doc while
you’ve been doing other things, and you want to update your local Rmd
with their changes.

Note that code blocks are not decorated like we see them in RStudio or
knitted output. Plus the code is not run as it moves from Rmd to Google
doc, so you will not see any output from the code in your Google doc.
