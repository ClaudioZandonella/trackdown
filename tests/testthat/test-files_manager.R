##################################
####    test Files Manager    ####
##################################

#----    upload_file    ----

path_test <- ifelse(interactive(), "tests/testthat/", "")

test_that("expect error form upload_file", {
  
  skip_if_no_token()
  skip_if_offline()
  
  vcr::use_cassette("upload_file_test_1", {
    upload_file_1 <- tryCatch(
      upload_file(file = paste0(path_test, "test_files/example_1.Rmd"),
                  gfile = "already_present_file", path = "writing_folder"),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^a file with this name already exists", upload_file_1$message))
  
  
})



#----
