##################################
####    test Files Manager    ####
##################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    upload_file    ----

test_that("expect error form upload_file", {
  
  skip_if_no_token()
  skip_if_offline()
  
  # error already existing file
  vcr::use_cassette("upload_file_test_1", {
    upload_file_1 <- tryCatch(
      upload_file(file = paste0(file_path, "example_1.Rmd"),
                  gfile = "already_present_file", gpath = "writing_folder"),
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
    dribble <- upload_file(file = paste0(file_path, "example_1.Rmd"),
                           gpath = "writing_folder",
                           hide_code = TRUE,
                           path_output = paste0(file_path, "example_1.html"))
    googledrive::drive_rm(dribble)
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("example_1", "example_1-output"))
  
  # upload Rnw file and pdf output
  vcr::use_cassette("upload_file_test_3", {
    dribble <- upload_file(file = paste0(file_path, "example_1.Rnw"),
                           gpath = "writing_folder",
                           hide_code = TRUE,
                           path_output = paste0(file_path, "example_1.pdf"))
    googledrive::drive_rm(dribble)
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("example_1", "example_1-output"))
  
  # remove files
  #ls_files <- list.files(paste0(file_path, ".trackdown")) delete
  #file.remove(paste0(file_path, ".trackdown/",ls_files))
  #file.remove(paste0(file_path, ".trackdown"), recursive = TRUE)
  unlink(paste0(file_path, ".trackdown"), recursive = TRUE)
  
})



#----    update_file    ----

test_that("expect error form update_file", {
  
  skip_if_no_token()
  skip_if_offline()
  
  # error already file do not exist
  vcr::use_cassette("update_file_test_1", {
    upload_file_1 <- tryCatch(
      update_file(file = paste0(file_path, "example_1.Rmd"),
                  gfile = "not_present_file", gpath = "writing_folder"),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^No file with this name exists", upload_file_1$message))
  
  # error multiple file exist
  vcr::use_cassette("update_file_test_2", {
    upload_file_1 <- tryCatch(
      update_file(file = paste0(file_path, "example_1.Rmd"),
                  gfile = "double_present_file", gpath = "writing_folder"),
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
    dribble <- update_file(file = paste0(file_path, "example_1.Rmd"),
                           gfile = "update_example",
                           gpath = "writing_folder",
                           hide_code = TRUE,
                           path_output = paste0(file_path, "example_1.html"))
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("update_example", "update_example-output"))
  
  # upload Rmd file and new pdf output
  vcr::use_cassette("update_file_test_4", {
    dribble <- update_file(file = paste0(file_path, "example_1.Rmd"),
                           gfile = "update_example_2",
                           gpath = "writing_folder",
                           hide_code = FALSE,
                           path_output = paste0(file_path, "example_1.pdf"))
    googledrive::drive_rm(dribble[2, ])
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("update_example_2", "update_example_2-output"))
  
  # remove files
  ls_files <- list.files(paste0(file_path, ".trackdown"))
  #file.remove(paste0(file_path, ".trackdown/",ls_files))
  #file.remove(paste0(file_path, ".trackdown"), recursive = TRUE)
  unlink(paste0(file_path, ".trackdown"), recursive = TRUE)
  
})


#----
