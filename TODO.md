# TODO

* clean utilities file with `on.exit()` to avoid leaving trash if function fails
  * remove `report_pdf`
* save default setting hide_chunks and upload_report for each document so user don't need to specify each time
* change default report name to filename + report
* manage removed chunk from google drive
* do not exclude setup chunk

# Notes

- in `init_rmdrive()` function the argument `local_rmd` is used to print the name. Code line `proj_name <- sub("\\..*", "", local_rmd)` to remove the file extension is problematic for file name with points in the name (e.g., "trial.file.rmd").

- see `extract_yaml()` the function body is repeated in `hide_chunk()`

- set chunks to NA possible conflict with "NA"? In `hide_chunk()` code line `stringr::str_remove_all(., "NA")`

- in `upload_report()` chunk_info[!stringr::str_detect(temp_chunk$name, stringr::regex('setup', ignore_case = T)), ] # remove echo = F chunks ??

- add message render report; evaluate if to keep separate hide chunk/ upload_report.

- deal with possible errors when compiling.

- cache

# Problems

- problems when chunks have not the `{}` syntax like simply writing raw code to not evaluate

- problems about restoring the first or last chunk



########


#

- example_1.Rmd uploaded **as < add name gfile>**!
- evaluate if get_root_id works also for team_drive (in case bind the two conditions)


## April 

- change sarting point header rnw (from 1st line)
- resore documen-header if missing at the top document
- new line first-second chunk