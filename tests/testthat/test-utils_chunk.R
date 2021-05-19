###################################
####    test Utils Dribble     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    mkdir_trackdown    ----

test_that("check a folder 'My_new_folder' is created", {
  
  ls_files_0 <- list.files(pattern = "^My_new_folder$", file_path)
  mkdir_trackdown(local_path = file_path, folder_name = "My_new_folder")
  ls_files_1 <- list.files(pattern = "^My_new_folder$", file_path)

  # remove folder
  unlink(paste0(file_path, "My_new_folder"), recursive = TRUE)
  
  expect_identical(length(ls_files_0), 0L)
  expect_identical(length(ls_files_1), 1L)
  

})

#----    get_chunk_range    ----

test_that("check get_chunk_range works correctly", {
  
  # rmd
  lines <- readLines(paste0(file_path, "example_1_rmd.txt"), encoding = "UTF-8")
  info_patterns <- get_extension_patterns(extension = "rmd")
  
  expect_true(nrow(get_chunk_range(lines[1:7], info_patterns)) == 0)
 
  expect_error(get_chunk_range(c("```", lines[8:10]), info_patterns))
  
  
})

#----    extract_chunk    ----

# rmd
lines_rmd <- readLines(paste0(file_path, "example_1_rmd.txt"), encoding = "UTF-8")
info_patterns_rmd <- get_extension_patterns(extension = "rmd")

# rnw
lines_rnw <- readLines(paste0(file_path, "example_1_rnw.txt"), encoding = "UTF-8")
info_patterns_rnw <- get_extension_patterns(extension = "rnw")

test_that("get the correct extract_chunk", {
  expect_snapshot_output(extract_chunk(lines_rmd, info_patterns_rmd))
  expect_snapshot_output(extract_chunk(lines_rnw, info_patterns_rnw))
})

test_that("get the correct extract_chunk no info", {
  # no chunks
  lines_no_chunk <- c("A file with no chunks")
  expect_null(extract_chunk(lines_no_chunk, info_patterns_rmd))
  expect_null(extract_chunk(lines_no_chunk, info_patterns_rnw))
})

#----    extract_header    ----

# rmd
lines_rmd <- readLines(paste0(file_path, "example_1_rmd.txt"), encoding = "UTF-8")
info_patterns_rmd <- get_extension_patterns(extension = "rmd")

# rnw
lines_rnw <- readLines(paste0(file_path, "example_1_rnw.txt"), encoding = "UTF-8")
info_patterns_rnw <- get_extension_patterns(extension = "rnw")


test_that("get the correct extract_header", {
  #rmd
  expect_snapshot_output(extract_header(lines_rmd, info_patterns_rmd))
  
  skip_on_os("windows") # due to bom utf-8
  # rnw
  expect_snapshot_output(extract_header(lines_rnw, info_patterns_rnw))
  # no chunks
  expect_error(extract_header(lines_no_chunk, info_patterns_rnw))

})

test_that("get the correct extract_header no chuncks", {
  # no chunks
  lines_no_chunk <- c("A file with no chunks")
  expect_error(extract_header(lines_no_chunk, info_patterns_rmd), 
               regexp = "There are some issues in the identification of YAML")
  
  skip_on_os("windows") # due to bom utf-8
  # no chunks
  expect_error(extract_header(lines_no_chunk, info_patterns_rnw),
               regexp = "There are some issues in the identification of the document header")
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

#----    hide_code    ----

test_that("get the correct hide_code", {
  
  # rmd
  document <- readLines(paste0(file_path, "example_1_rmd.txt"), encoding = "UTF-8")
  file_info <- get_file_info(paste0(file_path, "example_1.Rmd"))
  expect_snapshot_output(hide_code(document, file_info))
  
  # rnw
  document <- readLines(paste0(file_path, "example_1_rnw.txt"), encoding = "UTF-8")
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

# rmd
document_rmd <- readLines(paste0(file_path, "restore_example_1.Rmd"), warn = FALSE, encoding = "UTF-8")
chunk_info_rmd <- load_code("example_1.Rmd", path = file_path, type = "chunk")
index_header_rmd <- 9


test_that("get that restore_chunk works properly", {
  #---- Rmd ----
  # complete
  expect_snapshot_output(restore_chunk(document = document_rmd, chunk_info = chunk_info_rmd, 
                                       index_header = index_header_rmd))
  
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_chunk(document = document_rmd[-c(12, 39, 48, 51, 57)], 
                                       chunk_info = chunk_info_rmd, index_header = index_header_rmd))
  
  #---- Rnw ----
  document_rnw <- readLines(paste0(file_path, "restore_example_1.Rnw"), warn = FALSE, encoding = "UTF-8")
  chunk_info_rnw <- load_code("example_1.Rnw", path = file_path, type = "chunk")
  index_header_rnw <- 12
  # complete
  expect_snapshot_output(restore_chunk(document = document_rnw, chunk_info = chunk_info_rnw,
                                       index_header = index_header_rnw))

  # missing multiple chunks (1°,3°,4°, 6°)
  expect_snapshot_output(restore_chunk(document = document_rnw[-c(37, 52, 55, 61)],
                                       chunk_info = chunk_info_rnw, index_header = index_header_rnw))

})

test_that("get that restore_chunk missing first 2 chuncks", {
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_chunk(document = document_rmd[-c(12, 24,  39, 48, 51, 57)], 
                                       chunk_info = chunk_info_rmd, index_header = index_header_rmd))
})


#----    restore_code    ----

# Note that chunk info are created  in the hide_code test section and deleted at the end

#Rmd 
file_name_rmd <- "example_1.Rmd"
document_rmd <- readLines(paste0(file_path, paste0("restore_", file_name_rmd)), warn = FALSE, encoding = "UTF-8")

#Rnw
file_name_rnw <- "example_1.Rnw"
document_rnw <- readLines(paste0(file_path, paste0("restore_", file_name_rnw)), warn = FALSE, encoding = "UTF-8")

test_that("get that restore_code works properly", {
  #---- Rmd ----
  # complete
  expect_snapshot_output(restore_code(document = document_rmd, 
                                      file_name = file_name_rmd, path = file_path))
  
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_code(document = document_rmd[-c(12, 39, 48, 51, 57)], 
                                      file_name = file_name_rmd, path = file_path))
  
  #---- Rnw ----
  
  skip_on_os("windows") # due to bom utf-8
  
  # complete
  expect_snapshot_output(restore_code(document = document_rnw, 
                                      file_name = file_name_rnw, path = file_path))
  
  # missing multiple chunks (1°,3°,4°, 6°)
  expect_snapshot_output(restore_code(document = document_rnw[-c(37, 52, 55, 61)], 
                                      file_name = file_name_rnw, path = file_path))
  
})

test_that("get that restore_code missing header-tag", {
  # missing header-tag
  expect_warning(restore_code(document = document_rmd[-9], 
                              file_name = file_name_rmd, path = file_path),
                 regexp = "Failed retrieving \\[\\[document-header\\]\\] placeholder")
})

#----    restore_file    ----

test_that("get that restore_file works properly", {
  
  #---- Rmd ----
  
  file_name <- "example_1.Rmd"
  temp_file <- paste0(file_path, "restore_", file_name)
  new_temp_file <- paste0(file_path, "new_restore_", file_name)
  file.copy(from = temp_file, to = new_temp_file, overwrite = TRUE)
  
  # complete
  result <- restore_file(temp_file = new_temp_file, file_name = file_name, 
                         path = file_path)
  expect_snapshot_output(result)
  
  unlink(new_temp_file, recursive = TRUE)
  
  #---- Rnw ----
  file_name <- "example_1.Rnw"
  temp_file <- paste0(file_path, "restore_", file_name)
  new_temp_file <- paste0(file_path, "new_restore_", file_name)
  file.copy(from = temp_file, to = new_temp_file, overwrite = TRUE)
  
  # complete
  result <- restore_file(temp_file = new_temp_file, file_name = file_name, 
                         path = file_path)
  expect_snapshot_output(result)
  
  unlink(new_temp_file, recursive = TRUE)
})

#---- remove flolder  .trackdown ----

# remove files
unlink(paste0(file_path, ".trackdown"), recursive = TRUE)

#---- restore_code test no .trackdown folder ----

test_that("get that restore_code no .trackdown folder", {
  # missing header-tag
  expect_error(restore_code(document = document_rmd[-9], 
                            file_name = file_name_rmd, path = file_path),
               regexp = "Failed restoring code\\. Folder \\.trackdown")
})

#----

