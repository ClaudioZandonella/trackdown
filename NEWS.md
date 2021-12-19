# trackdown (development version)

## trackdown 1.1.1 (CRAN release)

Fix issue encoding in Windows. Now trackdown does not assume `"UTF-8"` encoding but it relies on `"native.enc"`.

## trackdown 1.1.0

New features:
 
- Introduce (experimental) argument `rm_gcomments`in `download_file()` to automatically remove Google comments when downloading the file (See issue #25).   
- Introduce support for child `.Rmd` and `.Rnw` files (documents without headers).

Argument `hide_code = TRUE` can now be used regardless of whether the file contains header code and/or chunks or not. This fixed the issues #22 and #24.

## trackdown 1.0.2

Fix issue [#21](https://github.com/ClaudioZandonella/trackdown/issues/21)

## trackdown 1.0.1

Fix issue [#17](https://github.com/ClaudioZandonella/trackdown/issues/17) and issue [#19](https://github.com/ClaudioZandonella/trackdown/issues/19)

## trackdown 1.0.0 (CRAN release)

Initial CRAN release

Minor changes to fix cran checks:

- `googledrive` dependency set to (> 1.0.1) and `cli` (>= 3.0.0)
- use relative path to specify  `fixture` and `vcr_files` folders in unit-tests


## trackdown 0.1.1

Following the release of `googledrive` version 2.0.0 ([link](https://www.tidyverse.org/blog/2021/07/googledrive-2-0-0/)), on which `trackdown` is based to interact with Google Drive, we updated the internal functions. In particular:

- Set googledrive (>= 2.0.0) in the `Imports` field of the `DESCRIPTION` file.
- Substitute `team_drive_\*()` deprecated functions and `team_drive =` deprecated arguments with the new `shared_drive_*()` functions and `shared_drive = ` argument in all the `googledrive` functions used internally by `trackdown`.
- Remove `verbose = ` deprecated argument from the `googledrive` functions used internally by `trackdown`. Instead, the function `googledrive::local_drive_quiet()` is used.
- Update unit-tests


## trackdown 0.1.0

Stable version after the full revision of the package previously named `rmdrive`

The workflow follows the same idea as before, but there are several new features and changes. The main ones are:

- **File Supported**: Both `.Rmd` and `.Rnw` documents are supported
- **Hide Code**: Code in the header of the document (YAML header or LaTeX preamble) and code chunks can be removed from the document when uploading to Google Drive and will be automatically restored during download. This prevents collaborators from inadvertently making changes to the code which might corrupt the file and allows them to focus on the narrative text.
-  **Upload Output**: The actual output document (i.e., the rendered file) can be uploaded to Google Drive in conjunction with the `.Rmd` (or `.Rnw`) document. This helps collaborators to evaluate the overall layout (including figures and tables) and allows them to add comments to suggest and discuss changes.
- **API Speed**:  Now the upload to and download from Google Drive is faster.
-  **Documentation**: Rich e detailed documentation is available at https://ekothe.github.io/trackdown/
