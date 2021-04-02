###################################
####    test Utils Dribble     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    mkdir_trackdown    ----

test_that("check a folder 'My_new_folder' is created", {
  
  ls_files_0 <- list.files(pattern = "^My_new_folder$", file_path)
  mkdir_trackdown(local_path = file_path, folder_name = "My_new_folder")
  ls_files_1 <- list.files(pattern = "^My_new_folder$", file_path)
  #file.remove(paste0(file_path, "My_new_folder"))
  unlink(paste0(file_path, "My_new_folder"), recursive = TRUE)
  
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
  ls_files_1 <- list.files(paste0(file_path, ".trackdown"))
  expect_identical(length(ls_files_1), 4L)
  expect_true(all(c("example_1.Rmd-chunk_info.rds", "example_1.Rmd-header_info.rds",
                    "example_1.Rnw-chunk_info.rds", "example_1.Rnw-header_info.rds") %in% ls_files_1))
  
})

#----    restore_chunk    ----

# Note that hunk info are created  in the hide_code test section and deleted at the end

test_that("get that restore_chunk works properly", {
  
  #---- Rmd ----
  document <- readLines(paste0(file_path, "restore_example_1.Rmd"), warn = FALSE)
  chunk_info <- load_code("example_1.Rmd", path = file_path, type = "chunk")
  index_header <- 9
  
  # complete
  expect_snapshot_output(restore_chunk(document = document, chunk_info = chunk_info, 
                                       index_header = index_header))
  
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_chunk(document = document[-c(12, 39, 48, 51, 57)], 
                                       chunk_info = chunk_info, index_header = index_header))
  
  
  #---- Rnw ----
  document <- readLines(paste0(file_path, "restore_example_1.Rnw"), warn = FALSE)
  chunk_info <- load_code("example_1.Rnw", path = file_path, type = "chunk")
  index_header <- 12
  
  # complete
  expect_snapshot_output(restore_chunk(document = document, chunk_info = chunk_info, 
                                       index_header = index_header))
  
  # missing multiple chunks (1°,3°,4°, 6°)
  expect_snapshot_output(restore_chunk(document = document[-c(37, 52, 55, 61)], 
                                       chunk_info = chunk_info, index_header = index_header))
  
})


#----    restore_code    ----

# Note that hunk info are created  in the hide_code test section and deleted at the end

test_that("get that restore_code works properly", {
  
  #---- Rmd ----
  file_name <- "example_1.Rmd"
  document <- readLines(file.path(file_path, paste0("restore_", file_name)), warn = FALSE)
  
  # complete
  expect_snapshot_output(restore_code(document = document, file_name = file_name, 
                                      path = file_path))
  
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_code(document = document[-c(12, 39, 48, 51, 57)], 
                                      file_name = file_name, path = file_path))
  
  
  #---- Rnw ----
  file_name <- "example_1.Rnw"
  document <- readLines(file.path(file_path, paste0("restore_", file_name)), warn = FALSE)
  
  # complete
  expect_snapshot_output(restore_code(document = document, file_name = file_name, 
                                      path = file_path))
  
  # missing multiple chunks (1°,3°,4°, 6°)
  expect_snapshot_output(restore_code(document = document[-c(37, 52, 55, 61)], 
                                      file_name = file_name, path = file_path))
  
})

#---- remove flolder  .trackdown ----

# remove files
ls_files_1 <- list.files(paste0(file_path, ".trackdown"))
#(paste0(file_path, ".trackdown/",ls_files_1))
#file.remove(paste0(file_path, ".trackdown"), recursive = TRUE)
unlink(paste0(file_path, ".trackdown"), recursive = TRUE)
#----

