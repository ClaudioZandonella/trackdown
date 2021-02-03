###################################
####    test Matrix Weights    ####
###################################

#----    Message Utils    ----

test_that("Message function work prorerly", {
  expect_snapshot_output(main_process("horizontal line"))
  expect_snapshot_output(emph_file("blue text"))
  expect_snapshot_output(sub_process("a bullet item"))
  expect_snapshot_output(start_process("a colored bulled item"))
  expect_snapshot_output(finish_process("a ticked item"))
})

#----    get_file_info    ----

test_that("file info are correct", {
  
  ex_1 <- list(path = "my_folder",
               file_name = "my_file.Rnw",
               extension = "rnw",
               file_basename = "my_file")
  ex_2 <- list(path = ".",
               file_name = "my.file.Rmd",
               extension = "rmd",
               file_basename = "my.file")
  
  expect_identical(get_file_info("my_folder/my_file.Rnw"), ex_1)
  expect_identical(get_file_info("my.file.Rmd"), ex_2)
  
  expect_error(get_file_info("my_file"), "file do not include extension")
  expect_error(get_file_info(20), "file has to be a single string")
})

#----    check_file    ----

test_that("check if file exists", {
  # an existing file
  expect_null(check_file("test_files/example_1.Rmd"))
  # not existing file
  expect_error(check_file(file = "I_dont_exist.txt"), 
               'file does not exist: "I_dont_exist.txt"')
  
  # worng argumants type
  expect_error(check_file(c("a", "b")), "file has to be a single string")
  expect_error(check_file(20), "file has to be a single string")
})


#----



