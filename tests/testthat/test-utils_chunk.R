#################################
####    test Utils Chunk     ####
#################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    mkdir_trackdown    ----

test_that("check a folder 'My_new_folder' is created", {
  
  my_path <- paste0(file_path, "utils_chunk/")
  
  ls_files_0 <- list.files(pattern = "^My_new_folder$", my_path)
  mkdir_trackdown(local_path = my_path, folder_name = "My_new_folder")
  ls_files_1 <- list.files(pattern = "^My_new_folder$", my_path)

  # remove folder
  unlink(paste0(my_path, "My_new_folder"), recursive = TRUE)
  
  expect_identical(length(ls_files_0), 0L)
  expect_identical(length(ls_files_1), 1L)
  
})

#----    get_chunk_range    ----

test_that("check get_chunk_range works correctly", {
  
  # rmd
  lines <- readLines(paste0(file_path, "utils_chunk/example-1.Rmd"))
  info_patterns <- get_extension_patterns(extension = "rmd")
  
  expect_true(nrow(get_chunk_range(lines[1:7], info_patterns)) == 0)
 
  expect_error(get_chunk_range(c("```", lines[8:10]), info_patterns))
  
})

#----    extract_chunk    ----

# rmd
lines_rmd <- readLines(paste0(file_path, "utils_chunk/example-1.Rmd"))
info_patterns_rmd <- get_extension_patterns(extension = "rmd")

# rnw
lines_rnw <- readLines(paste0(file_path, "utils_chunk/example-1.Rnw"))
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

#----    check_header    ----

# rmd
header_rmd <- readLines(paste0(file_path, "utils_chunk/no-code.Rmd"))
no_header_rmd <- header_rmd[-c(1:6)]
info_patterns_rmd <- get_extension_patterns(extension = "rmd")

# rnw
header_rnw <- readLines(paste0(file_path, "utils_chunk/no-code.Rnw"))
no_header_rnw <- header_rnw[-c(1:6)]
info_patterns_rnw <- get_extension_patterns(extension = "rnw")

test_that("check check_header works properly", {
  #rmd
  expect_true(check_header(header_rmd, info_patterns = info_patterns_rmd))
  expect_false(check_header(header_rmd[-1], info_patterns = info_patterns_rmd))
  expect_true(check_header(header_rmd[-6], info_patterns = info_patterns_rmd))
  expect_false(check_header(no_header_rmd, info_patterns = info_patterns_rmd))
  
  skip_on_os("windows") # due to bom utf-8
  # rnw
  expect_true(check_header(header_rnw, info_patterns = info_patterns_rnw))
  expect_false(check_header(no_header_rnw, info_patterns = info_patterns_rnw))
  
  expect_error(check_header(header_rnw[-1], info_patterns = info_patterns_rnw),
               "There are some issues in the identification of the document header start/end line indexes")
  expect_error(check_header(header_rnw[-6], info_patterns = info_patterns_rnw),
               "There are some issues in the identification of the document header start/end line indexes")
  
})

#----    extract_header    ----

# rmd
lines_rmd <- readLines(paste0(file_path, "utils_chunk/example-1.Rmd"))
info_patterns_rmd <- get_extension_patterns(extension = "rmd")

# rnw
lines_rnw <- readLines(paste0(file_path, "utils_chunk/example-1.Rnw"))
info_patterns_rnw <- get_extension_patterns(extension = "rnw")


test_that("get the correct extract_header", {
  #rmd
  expect_snapshot_output(extract_header(lines_rmd, info_patterns_rmd))
  
  skip_on_os("windows") # due to bom utf-8
  # rnw
  expect_snapshot_output(extract_header(lines_rnw, info_patterns_rnw))

})

test_that("get the correct extract_header no header", {
  # no chunks
  lines_no_chunk <- c("A file with no chunks")
  expect_null(extract_header(lines_no_chunk, info_patterns_rmd))
  
  skip_on_os("windows") # due to bom utf-8
  # no chunks
  expect_null(extract_header(lines_no_chunk, info_patterns_rnw))
})


#----    get_extension_patterns    ----

test_that("file info are correct", {
  
  ex_rmd <- list(chunk_header_start = "^```(\\s*$|\\s*\\{)",
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
  
  #----     rmd    ----
  file_rmd <- paste0(file_path, "utils_chunk/example-1.Rmd")
  document <- readLines(file_rmd)
  file_info <- get_file_info(file_rmd)
  expect_snapshot_output(hide_code(document, file_info))
  
  # no header and or code
  no_header <- readLines(paste0(file_path, "utils_chunk/no-header.Rmd"))
  no_code <- readLines(paste0(file_path, "utils_chunk/no-code.Rmd"))
  no_header_code <- readLines(paste0(file_path, "utils_chunk/no-header-code.Rmd"))
  expect_snapshot_output(hide_code(no_header, file_info))
  expect_snapshot_output(hide_code(no_code, file_info))
  expect_snapshot_output(hide_code(no_header_code, file_info))
  
  #----    rnw    ----
  file_rnw <- paste0(file_path, "utils_chunk/example-1.Rnw")
  document <- readLines(file_rnw)
  file_info <- get_file_info(file_rnw)
  expect_snapshot_output(hide_code(document, file_info))
  
  # no header and or code
  no_header <- readLines(paste0(file_path, "utils_chunk/no-header.Rnw"))
  no_code <- readLines(paste0(file_path, "utils_chunk/no-code.Rnw"))
  no_header_code <- readLines(paste0(file_path, "utils_chunk/no-header-code.Rnw"))
  expect_snapshot_output(hide_code(no_header, file_info))
  expect_snapshot_output(hide_code(no_code, file_info))
  expect_snapshot_output(hide_code(no_header_code, file_info))
  
  #----    tests    ----
  ls_files_1 <- list.files(paste0(file_path, "utils_chunk/.trackdown"))
  expect_identical(length(ls_files_1), 4L)
  expect_true(all(c("example-1.Rmd-chunk_info.rds", "example-1.Rmd-header_info.rds",
                    "example-1.Rnw-chunk_info.rds", "example-1.Rnw-header_info.rds") %in% ls_files_1))
  
  #----    remove flolder  .trackdown    ----
  unlink(paste0(file_path, "utils_chunk/.trackdown"), recursive = TRUE)
  
})

#----    create .trackdown with file info    ----

# obtain header and chunk info for files in following list
list_files <- c("example-1.Rmd", "example-1.Rnw",
                "no-header.Rmd", "no-code.Rmd", "no-header-code.Rmd",
                "no-header.Rnw", "no-code.Rnw", "no-header-code.Rnw")

invisible(
  lapply(list_files, function(x){
    file <- paste0(file_path, "utils_chunk/", x)
    document <- readLines(file)
    file_info <- get_file_info(file)
    
    hide_code(document, file_info)
  })
)

#----    restore_chunk    ----

# chunk info are created in the section above "create .trackdown with file info"
# these will be deleted at the end

# each file (e.g., my-file.Rmd) has the corresponding file (e.g.,
# my-file-restore.Rmd) with place-holders instead of code, ready to be restored
 

test_that("check restore_chunk works properly", {
  #---- Rmd ----
  # example-1-restore.Rmd
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rmd"), warn = FALSE)
  chunk_info <- load_code("example-1.Rmd", path = paste0(file_path, "utils_chunk/"), type = "chunk")
  index_header <- 9
  
  # complete
  expect_snapshot_output(restore_chunk(document = document, chunk_info = chunk_info, 
                                       index_header = index_header))
  
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_chunk(document = document[-c(11, 29, 35, 37, 45)], 
                                       chunk_info = chunk_info, index_header = index_header))
  
  #---- Rnw ----
  # example-1-restore.Rnw
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rnw"), warn = FALSE)
  chunk_info <- load_code("example-1.Rnw", path = paste0(file_path, "utils_chunk/"), type = "chunk")
  index_header <- 9
  
  # complete
  expect_snapshot_output(restore_chunk(document = document, chunk_info = chunk_info,
                                       index_header = index_header))

  # missing multiple chunks (1°,3°,4°, 6°)
  expect_snapshot_output(restore_chunk(document = document[-c(27, 37, 39, 43)],
                                       chunk_info = chunk_info, index_header = index_header))

})

test_that("check restore_chunk works when missing first chuncks", {
  #---- Rmd ----
  # example-1-restore.Rmd
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rmd"), warn = FALSE)
  chunk_info <- load_code("example-1.Rmd", path = paste0(file_path, "utils_chunk/"), type = "chunk")
  index_header <- 9
  
  # missing first 2 chunks and others (1°,2°, 7°, 8°, last)
  expect_snapshot_output(restore_chunk(document = document[-c(11, 19, 35, 37, 45)], 
                                       chunk_info = chunk_info, index_header = index_header))
  
})

#----    restore_code    ----

# chunk info are created in the section above "create .trackdown with file info"
# these will be deleted at the end

# each file (e.g., my-file.Rmd) has the corresponding file (e.g.,
# my-file-restore.Rmd) with place-holders instead of code, ready to be restored

my_path <- paste0(file_path, "utils_chunk/")

test_that("check restore_code works properly", {
  
  #---- Rmd ----
  # example-1-restore.Rmd
  file_name <- "example-1.Rmd"
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rmd"), warn = FALSE)
  
  # complete
  expect_snapshot_output(restore_code(document = document, 
                                      file_name = file_name, path = my_path))
  
  # missing multiple chunks (1°,4°, 7°, 8°, last)
  expect_snapshot_output(restore_code(document = document[-c(11, 29, 35, 37, 45)], 
                                      file_name = file_name, path = my_path))
  
  # no header and or code [remove instruction]
  no_header <- readLines(paste0(file_path, "utils_chunk/no-header-restore.Rmd"))[-c(1:8)]
  no_code <- readLines(paste0(file_path, "utils_chunk/no-code-restore.Rmd"))[-c(1:8)]
  no_header_code <- readLines(paste0(file_path, "utils_chunk/no-header-code-restore.Rmd"))[-c(1:8)]
  expect_snapshot_output(restore_code(no_header, file_name = "no-header.Rmd", path = my_path))
  expect_snapshot_output(restore_code(no_code, file_name = "no-code.Rmd", path = my_path))
  expect_snapshot_output(restore_code(no_header_code, file_name = "no-header-code.Rmd", path = my_path))
  
  # missing chunks
  expect_snapshot_output(restore_code(no_header[-c(11, 17)], file_name = "no-header.Rmd", path = my_path))
  
  #---- Rnw ----
  skip_on_os("windows") # due to bom utf-8
  
  # example-1-restore.Rmd
  file_name <- "example-1.Rnw"
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rnw"), warn = FALSE)
  
  # complete
  expect_snapshot_output(restore_code(document = document, 
                                      file_name = file_name, path = my_path))
  
  # missing multiple chunks (1°,3°,4°, 6°)
  expect_snapshot_output(restore_code(document = document[-c(27, 37, 39, 43)], 
                                      file_name = file_name, path = my_path))
  
  # no header and or code [remove instruction]
  no_header <- readLines(paste0(file_path, "utils_chunk/no-header-restore.Rnw"))[-c(1:8)]
  no_code <- readLines(paste0(file_path, "utils_chunk/no-code-restore.Rnw"))[-c(1:8)]
  no_header_code <- readLines(paste0(file_path, "utils_chunk/no-header-code-restore.Rnw"))[-c(1:8)]
  expect_snapshot_output(restore_code(no_header, file_name = "no-header.Rnw", path = my_path))
  expect_snapshot_output(restore_code(no_code, file_name = "no-code.Rnw", path = my_path))
  expect_snapshot_output(restore_code(no_header_code, file_name = "no-header-code.Rnw", path = my_path))
  
  # missing chunks
  expect_snapshot_output(restore_code(no_header[-c(7, 13)], file_name = "no-header.Rnw", path = my_path))
  
})

test_that("check restore_code missing header-tag", {
  # missing header-tag
  
  #---- Rmd ----
  # example-1-restore.Rmd
  file_name <- "example-1.Rmd"
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rmd"), warn = FALSE)
  
  expect_warning(restore_code(document = document[-9], 
                              file_name = file_name, path = my_path),
                 regexp = "Failed retrieving \\[\\[document-header\\]\\] placeholder")
})

#----    restore_file    ----

# chunk info are created in the section above "create .trackdown with file info"
# these will be deleted at the end

# each file (e.g., my-file.Rmd) has the corresponding file (e.g.,
# my-file-restore.Rmd) with place-holders instead of code, ready to be restored


test_that("check restore_file works properly", {
  
  my_path <-  paste0(file_path, "utils_chunk/")
  
  #---- Rmd ----
  # example-1-restore.Rmd
  file_name <- "example-1.Rmd"
  temp_file <- paste0(my_path, "example-1-restore.Rmd")
  new_temp_file <- paste0(my_path, "temp-", file_name)
  file.copy(from = temp_file, to = new_temp_file, overwrite = TRUE)
  
  # complete
  result <- restore_file(temp_file = new_temp_file, file_name = file_name, 
                         path = my_path)
  expect_snapshot_output(result)
  
  unlink(new_temp_file, recursive = TRUE)
  
  #---- Rnw ----
  # example-1-restore.Rnw
  file_name <- "example-1.Rnw"
  temp_file <- paste0(my_path, "example-1-restore.Rnw")
  new_temp_file <- paste0(my_path, "temp-", file_name)
  file.copy(from = temp_file, to = new_temp_file, overwrite = TRUE)
  
  # complete
  result <- restore_file(temp_file = new_temp_file, file_name = file_name, 
                         path = my_path)
  expect_snapshot_output(result)
  
  unlink(new_temp_file, recursive = TRUE)
})

#---- remove flolder  .trackdown ----

# remove files
unlink(paste0(file_path, "utils_chunk/.trackdown"), recursive = TRUE)

#---- restore_code test no .trackdown folder ----

test_that("check restore_code no .trackdown folder", {
  
  my_path <-  paste0(file_path, "utils_chunk/")
  
  #---- Rmd ----
  # example-1-restore.Rmd
  file_name <- "example-1.Rmd"
  document <- readLines(paste0(file_path, "utils_chunk/example-1-restore.Rmd"), warn = FALSE)
  
  expect_error(restore_code(document = document, 
                            file_name = file_name, path = my_path),
               regexp = "Failed restoring code\\. Folder \\.trackdown")
})

#----

