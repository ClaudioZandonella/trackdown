##################################
####    test Files Manager    ####
##################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    upload_file    ----

gpath <- "unit_tests/files_manager"

test_that("expect error form upload_file", {

  skip_if_no_token()
  skip_if_offline()
  
  # error already existing file
  vcr::use_cassette("upload_file_test_1", {
    upload_file_1 <- tryCatch(
      upload_file(file = paste0(file_path, "files_manager/example-1.Rmd"),
                  gfile = "already-present-file", gpath = gpath),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^A file with this name already exists", upload_file_1$message))

})

test_that("expect correct upload document", {

  skip_if_no_token()
  skip_if_offline()

  # upload Rmd file and html output
  vcr::use_cassette("upload_file_test_2", {
    dribble <- upload_file(file = paste0(file_path, "files_manager/example-1.Rmd"),
                           gpath = gpath,
                           hide_code = TRUE,
                           path_output = paste0(file_path, "files_manager/example-1.html"))
    googledrive::drive_rm(dribble)
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("example-1", "example-1-output"))

  # upload Rnw file and pdf output
  vcr::use_cassette("upload_file_test_3", {
    dribble <- upload_file(file = paste0(file_path, "files_manager/example-1.Rnw"),
                           gpath = gpath,
                           hide_code = TRUE,
                           path_output = paste0(file_path, "files_manager/example-1.pdf"))
    googledrive::drive_rm(dribble)
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("example-1", "example-1-output"))
  
  
})

# remove files
unlink(paste0(file_path, "files_manager/.trackdown"), recursive = TRUE)


#----    update_file    ----

gpath <- "unit_tests/files_manager"

test_that("expect error form update_file", {

  skip_if_no_token()
  skip_if_offline()

  # error already file do not exist
  vcr::use_cassette("update_file_test_1", {
    upload_file_1 <- tryCatch(
      update_file(file = paste0(file_path, "files_manager/example-1.Rmd"),
                  gfile = "new-file", gpath = gpath),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^No file with this name exists", upload_file_1$message))

  # error multiple file exist
  vcr::use_cassette("update_file_test_2", {
    upload_file_1 <- tryCatch(
      update_file(file = paste0(file_path, "files_manager/example-1.Rmd"),
                  gfile = "example-1-copy", gpath = gpath),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^More than one file with this name", upload_file_1$message))

})

test_that("expect correct update document", {

  skip_if_no_token()
  skip_if_offline()

  # update Rmd file and already present html output
  vcr::use_cassette("update_file_test_3", {
    dribble <- update_file(file = paste0(file_path, "files_manager/example-1.Rmd"),
                           gfile = "rmd-example-1-update",
                           gpath = gpath,
                           hide_code = TRUE,
                           path_output = paste0(file_path, "files_manager/example-1.html"))
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("rmd-example-1-update", "rmd-example-1-update-output"))

  # update Rmd file and new pdf output
  vcr::use_cassette("update_file_test_4", {
    dribble <- update_file(file = paste0(file_path, "files_manager/example-1.Rmd"),
                           gfile = "rnw-example-1-update",
                           gpath = gpath,
                           hide_code = FALSE,
                           path_output = paste0(file_path, "files_manager/example-1.pdf"))
    googledrive::drive_rm(dribble[2, ])
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("rnw-example-1-update", "rnw-example-1-update-output"))

})

# remove files
unlink(paste0(file_path, "files_manager/.trackdown"), recursive = TRUE)

#----    create .trackdown with file info    ----

# obtain header and chunk info for files in following list
list_files <- c("example-1.Rmd", "example-1.Rnw")

invisible(
  lapply(list_files, function(x){
    file <- paste0(file_path, "files_manager/", x)
    document <- readLines(file)
    file_info <- get_file_info(file)
    
    hide_code(document, file_info)
  })
)

#----    download_file    ----

# chunk info are created in the section above "create .trackdown with file info"
# these will be deleted at the end

# Downloaded files are saved by vcr in the vcr_file folder. However, these files
# are named as ".temp-name-file" by trackdown. CRAN do not allows ".files" in
# the package. So we need to rename files in the vcr_file folder and also change
# the name in the related fixture yml file (it is at the end). Next, in the
# test, we manually copy the file renaming it with the initial "." so the file
# will be available to download_file(). download_file() will also automatically
# remove the file.

gpath <- "unit_tests/files_manager"

test_that("expect correct download document", {

  skip_if_no_token()
  skip_if_offline()

  # Unchanged file
  temp_file <- paste0(file_path, "files_manager/example-1-unchanged.Rmd")
  old_file <- paste0(file_path, "files_manager/example-1.Rmd")
  file.copy(from = old_file, to = temp_file, overwrite = TRUE)
  file.copy(from = "../vcr_files/temp-example-1-unchanged.txt",
            to = "test_files/files_manager/.temp-example-1-unchanged.txt")

  # download Rmd file no changes
  vcr::use_cassette("download_file_test_1", {
    result <- download_file(file = temp_file,
                            gfile = "rmd-example-1",
                            gpath = gpath,
                            shared_drive = NULL)
  })
  expect_false(result)

  # remove files
  unlink(temp_file, recursive = TRUE)

  # download Rmd file with changes
  temp_file <- paste0(file_path, "files_manager/example-1-changed.Rmd")
  file.copy(from = old_file, to = temp_file, overwrite = TRUE)
  file.copy(from = "../vcr_files/temp-example-1-changed.txt",
            to = "test_files/files_manager/.temp-example-1-changed.txt")

  vcr::use_cassette("download_file_test_2", {
    result <- download_file(file = temp_file,
                            gfile = "rmd-example-1-changed",
                            gpath = gpath,
                            shared_drive = NULL)
  })
  expect_true(result)

})


test_that("expect correct use of rm_gcomments", {
  
  expect_error(download_file(file = "my_file.Rmd", rm_gcomments = "true"),
               "rm_gcomments argument has to be logical")
})

#----    render_file    ----

# chunk info are created in the section above "create .trackdown with file info"
# these will be deleted at the end

gpath <- "unit_tests/files_manager"

test_that("expect correct render_file", {

  skip_if_no_token()
  skip_if_offline()

  # Unchanged file
  temp_file <- paste0(file_path, "files_manager/example-1-unchanged-render.Rmd")
  old_file <- paste0(file_path, "files_manager/example-1.Rmd")
  file.copy(from = old_file, to = temp_file, overwrite = TRUE)
  file.copy(from = "../vcr_files/temp-example-1-unchanged-render.txt",
            to = "test_files/files_manager/.temp-example-1-unchanged-render.txt")

  # download Rmd file no changes
  vcr::use_cassette("render_file_test_1", {
    result <- render_file(file = temp_file,
                          gfile = "rmd-example-1",
                          gpath = gpath,
                          shared_drive = NULL)
  })
  expect_false(result)

})

#----    remove files    ----

unlink(paste0(file_path, "files_manager/.trackdown"), recursive = TRUE)

#----
