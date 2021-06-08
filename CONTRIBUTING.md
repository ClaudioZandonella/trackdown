# Contributing to trackdown

Please note that the `trackdown` package is released under a [Contributor Code of Conduct](https://www.contributor-covenant.org/). By contributing to this project, 
you agree to abide by its terms.

## Issues

When opening an [issue](), please try to include a minimal reproducible example so that the problem can be quickly verified and it is possible to figure out how to fix it. To make your example reproducible include:

- command that generated the problem
- copy of the local document 
- `.trackdown` folder (if available)
- copy of the Google Drive document (if available)
- `session_info()$platform` output

If possible, include the entire project folder removing private information and all files not related to the issue. This would allow the evaluation of issues related to path definitions and file locations.

Note, however, that some problems may be Operative System specific or depend on other computer global settings. Thus, it is possible that the problem would not be reproducible on other computers.

## Pull requests

To contribute to `trackdown`, create a pull request.

Follow these general rules when proposing a change:

- consistently works on the three main Operative Systems (i.e., macOS, Linux, and Windows)
- document any function with [roxygen](https://github.com/klutometis/roxygen)
- test any function with [testthat](https://github.com/r-lib/testthat)
- minimize dependencies 

