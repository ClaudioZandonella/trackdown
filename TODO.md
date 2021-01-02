# TODO

* check `regex()` dep
* remove `.temp*` files if the script fail



# Notes

- in `init_rmdrive()` function the argument `local_rmd` is used to print the name. Code line `proj_name <- sub("\\..*", "", local_rmd)` to remove the file extension is problematic for file name with points in the name (e.g., "trial.file.rmd").

- see `extract_yaml()` the function body is repeated in `hide_chunk()`

- set chunks to NA possible conflict with "NA"? In `hide_chunk()` code line `stringr::str_remove_all(., "NA")`

- in `upload_report()` chunk_info[!stringr::str_detect(temp_chunk$name, stringr::regex('setup', ignore_case = T)), ] # remove echo = F chunks ??

- add message render report; evaluate if to keep separate hide chunk/ upload_report.

- deal with possible errors when compiling.

- cache
