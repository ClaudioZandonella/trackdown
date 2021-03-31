###################################
####    test Matrix Weights    ####
###################################
file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

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

#----    get_instructions    ----

test_that("check get_instructions", {
  # Rmd
  file_info <- get_file_info(paste0(file_path, "example_1.Rmd"))
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = TRUE))
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = FALSE))
  
  # Rnw
  file_info <- get_file_info(paste0(file_path, "example_1.Rnw"))
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = TRUE))
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = FALSE))
})

#----    format_document    ----

test_that("check format_document", {
  document <- readLines(paste0(file_path, "example_1_rmd.txt"))
  file_info <- get_file_info(paste0(file_path, "example_1.Rmd"))
  expect_snapshot_output(format_document(document, file_info = file_info, 
                                         hide_code = FALSE))
  
  document <- readLines(paste0(file_path, "example_1_rmd.txt"))
  expect_snapshot_output(format_document(document, file_info = file_info,
                                         hide_code = TRUE))
})

#----    check_dribble    ----

test_that("check check_dribble", {
  # dribble_hello_world <- get_dribble_info(gfile = "Hello-world", path = "reading_folder")
  # save(dribble_hello_world, file = paste0(file_path, "dribble_hello_world.rda"))
  load(paste0(file_path, "dribble_hello_world.rda"))
  
  # none
  expect_error(check_dribble(dribble_hello_world$file, "Hello-world"))
  expect_error(check_dribble(dribble_hello_world$file[-1, ], "Hello-world", NA))
  
  # single
  expect_error(check_dribble(dribble_hello_world$file[-1, ], "Hello-world", 
                            test = "single"))
  expect_error(check_dribble(dribble_hello_world$file[c(1, 1), ], "Hello-world", 
                            test = "single"))
  expect_error(check_dribble(dribble_hello_world$file, "Hello-world", 
                            test = "single"), NA)
  
  # both
  expect_error(check_dribble(dribble_hello_world$file[c(1,1)], "Hello-world", 
                            test = "both"))
  expect_error(check_dribble(dribble_hello_world$file, "Hello-world", 
                            test = "both"), NA)
  expect_error(check_dribble(dribble_hello_world$file[-1], "Hello-world", 
                            test = "both"), NA)
  
})
#----



