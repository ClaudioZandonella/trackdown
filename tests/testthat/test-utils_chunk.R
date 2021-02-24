###################################
####    test Utils Dribble     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    mkdir_rmdrive    ----

test_that("check a folder 'My_new_folder' is created", {
  
  ls_files_0 <- list.files(pattern = "^My_new_folder$", file_path)
  mkdir_rmdrive(local_path = file_path, folder_name = "My_new_folder")
  ls_files_1 <- list.files(pattern = "^My_new_folder$", file_path)
  file.remove(paste0(file_path, "My_new_folder"))
  
  expect_identical(length(ls_files_0), 0L)
  expect_identical(length(ls_files_1), 1L)
  

})

#----    get_extension_patterns    ----

test_that("file info are correct", {
  
  ex_rmd <- list(chunk_header_start = "^```(\\s*$|\\{)",
                 chunk_header_end = "\\}\\s*$",
                 chunk_end = "^```\\s*$",
                 file_header_start = "^---",
                 file_header_end = "^---",
                 extension = "rmd")
  ex_rnw <- list(chunk_header_start = "^<<",
                 chunk_header_end = ">>=.*$",
                 chunk_end = "^@\\s*$",
                 file_header_start = "^\\\\documentclass{",
                 file_header_end = "^\\\\begin{document}",
                 extension = "rnw")
  
  expect_identical(get_extension_patterns("rmd"), ex_rmd)
  expect_identical(get_extension_patterns("rnw"), ex_rnw)
  
  expect_error(get_extension_patterns("txt"))

})

#----
