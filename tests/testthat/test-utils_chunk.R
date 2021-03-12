###################################
####    test Utils Dribble     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    mkdir_reviewdown    ----

test_that("check a folder 'My_new_folder' is created", {
  
  ls_files_0 <- list.files(pattern = "^My_new_folder$", file_path)
  mkdir_reviewdown(local_path = file_path, folder_name = "My_new_folder")
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
                 file_header_start = "^---\\s*$",
                 file_header_end = "^---\\s*$",
                 extension = "rmd")
  ex_rnw <- list(chunk_header_start = "^<<",
                 chunk_header_end = ">>=.*$",
                 chunk_end = "^@\\s*$",
                 file_header_start = "^\\\\documentclass\\{",
                 file_header_end = "^\\\\begin\\{document\\}",
                 extension = "rnw")
  
  expect_identical(get_extension_patterns("rmd"), ex_rmd)
  expect_identical(get_extension_patterns("rnw"), ex_rnw)
  
  expect_error(get_extension_patterns("txt"))

})

#----    extract_chunk    ----

test_that("get the correct extract_chunk", {
  # rmd
  lines_rmd <- readLines(paste0(file_path, "example_1_rmd.txt"))
  info_patterns_rmd <- get_extension_patterns(extension = "rmd")
  expect_snapshot_output(extract_chunk(lines_rmd, info_patterns_rmd))
  
  # rnw
  lines_rnw <- readLines(paste0(file_path, "example_1_rnw.txt"))
  info_patterns_rnw <- get_extension_patterns(extension = "rnw")
  expect_snapshot_output(extract_chunk(lines_rnw, info_patterns_rnw))
  
  # no chunks
  lines_no_chunk <- c("A file with no chunks")
  expect_null(extract_chunk(lines_no_chunk, info_patterns_rmd))
  expect_null(extract_chunk(lines_no_chunk, info_patterns_rnw))
  
})

#----    extract_header    ----

test_that("get the correct extract_header", {
  # rmd
  lines_rmd <- readLines(paste0(file_path, "example_1_rmd.txt"))
  info_patterns_rmd <- get_extension_patterns(extension = "rmd")
  expect_snapshot_output(extract_header(lines_rmd, info_patterns_rmd))
  
  # rnw
  lines_rnw <- readLines(paste0(file_path, "example_1_rnw.txt"))
  info_patterns_rnw <- get_extension_patterns(extension = "rnw")
  expect_snapshot_output(extract_header(lines_rnw, info_patterns_rnw))
  
  # no chunks
  lines_no_chunk <- c("A file with no chunks")
  expect_error(extract_header(lines_no_chunk, info_patterns_rmd))
  expect_error(extract_header(lines_no_chunk, info_patterns_rnw))

})


#----    hide_code    ----

test_that("get the correct hide_code", {
  
  # rmd
  document <- readLines(paste0(file_path, "example_1_rmd.txt"))
  file_info <- get_file_info(paste0(file_path, "example_1.Rmd"))
  expect_snapshot_output(hide_code(document, file_info))
  
  # rnw
  document <- readLines(paste0(file_path, "example_1_rnw.txt"))
  file_info <- get_file_info(paste0(file_path, "example_1.Rnw"))
  expect_snapshot_output(hide_code(document, file_info))
  
  # tests
  ls_files_1 <- list.files(paste0(file_path, ".reviewdown"))
  expect_identical(length(ls_files_1), 4L)
  expect_true(all(c("example_1.Rmd-chunk_info.rds", "example_1.Rmd-header_info.rds",
                    "example_1.Rnw-chunk_info.rds", "example_1.Rnw-header_info.rds") %in% ls_files_1))
  
  # remove files
  file.remove(paste0(file_path, ".reviewdown/",ls_files_1))
  file.remove(paste0(file_path, ".reviewdown"), recursive = TRUE)
})

#----
