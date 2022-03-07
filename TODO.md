# TODO

- [x] clean utilities file with `on.exit()` to avoid leaving trash if function fails
- [x] remove `report_pdf`
* save default setting hide_chunks and upload_report for each document so user don't need to specify each time
- [x] change default report name to filename + report
- [x] manage removed chunk from google drive
- [x] do not exclude setup chunk

# Notes

- [x] in `init_rmdrive()` function the argument `local_rmd` is used to print the name. - [x] Code line `proj_name <- sub("\\..*", "", local_rmd)` to remove the file extension is problematic for file name with points in the name (e.g., "trial.file.rmd").

- [x] see `extract_yaml()` the function body is repeated in `hide_chunk()`

- [x] set chunks to NA possible conflict with "NA"? In `hide_chunk()` code line `stringr::str_remove_all(., "NA")`

- [x] in `upload_report()` chunk_info[!stringr::str_detect(temp_chunk$name, stringr::regex('setup', ignore_case = T)), ] # remove echo = F chunks ??

- [x] add message render report; evaluate if to keep separate hide chunk/ upload_report.

- [x] deal with possible errors when compiling.

- [x] cache

# Problems

- [x] problems when chunks have not the `{}` syntax like simply writing raw code to not evaluate

- [x] problems about restoring the first or last chunk



## March

- [X] example_1.Rmd uploaded **as < add name gfile>**!
- evaluate if get_root_id works also for team_drive (in case bind the two conditions)


## April 

- [x] change sarting point header rnw (from 1st line)
- [x] resore documen-header if missing at the top document
- [x] new line first-second chunk
- [x] messages (path drive)
- [x] document restore_file
- [x] unlink() instead of file.remove() within testing functions
- [x] substitute readLines() with readr::read_lines()
- [x] change documentation of download_document(). The input file is suggested without extension (`rmd`)
- check what happens with `library(trackdown)`
- trying a very complicated `rmd` document with a lot of chunks and text

## May

- add "sharedWithMe" option to allow collaborators access shared files (https://github.com/tidyverse/googledrive/issues/154#issuecomment-317755269)


## Future 

- [] Add plug-in functions
- [] gwet sharable links
- [] support md and latex files

 
## March 2022
 
- [] fix recognize indented chunks 

