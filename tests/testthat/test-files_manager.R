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
                  gfile = "already_present_file", path = "writing_folder"),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^a file with this name already exists", upload_file_1$message))
  
})

test_that("expect correct upload document", {
  
  skip_if_no_token()
  skip_if_offline()
  
  file
  gfile = NULL
  path = "trackdown"
  team_drive = NULL
  hide_code = FALSE
  path_output = NULL
  
  # upload Rmd file and html output
  vcr::use_cassette("upload_file_test_2", {
    dribble <- upload_file(file = paste0(file_path, "example_1.Rmd"),
                           path = "writing_folder",
                           hide_code = TRUE,
                           path_output = paste0(file_path, "example_1.html"))
    googledrive::drive_rm(dribble)
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("example_1", "example_1-output"))
  
  # upload Rnw file and pdf output
  vcr::use_cassette("upload_file_test_3", {
    dribble <- upload_file(file = paste0(file_path, "example_1.Rnw"),
                           path = "writing_folder",
                           hide_code = TRUE,
                           path_output = paste0(file_path, "example_1.pdf"))
    googledrive::drive_rm(dribble)
  })
  expect_equal(nrow(dribble), 2)
  expect_equal(dribble$name, c("example_1", "example_1-output"))
  
  # remove files
  ls_files <- list.files(paste0(file_path, ".trackdown"))
  file.remove(paste0(file_path, ".trackdown/",ls_files))
  file.remove(paste0(file_path, ".trackdown"), recursive = TRUE)
  
})



#----
