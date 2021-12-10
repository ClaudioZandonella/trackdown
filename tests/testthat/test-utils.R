##########################
####    test Utils    ####
##########################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    check_file    ----

test_that("check if file exists", {
  # an existing file
  expect_null(check_file(paste0(file_path, "utils/Hello-World.txt")))
  # not existing file
  expect_error(check_file(paste0(file_path, "utils/new-file.txt")), 
               '^file does not exist: ".*/new-file.txt"')
  
  # wrong arguments type
  expect_error(check_file(c("a", "b")), "file has to be a single string")
  expect_error(check_file(20), "file has to be a single string")
})

#----    check_identity    ----

test_that("check_identity works prorerly", {
  rmd_file <- paste0(file_path, "utils/example-1.Rmd")
  rnw_file <- paste0(file_path, "utils/example-1.Rnw")
  
  expect_true(check_identity(temp_file = rmd_file, local_file = rmd_file))
  expect_true(check_identity(temp_file = rnw_file, local_file = rnw_file))
  
  expect_false(check_identity(temp_file = rmd_file, local_file = rnw_file))
  expect_false(check_identity(temp_file = rnw_file, local_file = rmd_file))
  expect_false(check_identity(temp_file = rnw_file, local_file = "anoter_path"))
})

#----    Message Utils    ----

test_that("Message function work prorerly", {
  expect_snapshot_output(main_process("horizontal line"))
  expect_snapshot_output(emph_file("blue text"))
  expect_snapshot_output(start_process("a colored bulled item"))
  expect_snapshot_output(finish_process("a ticked item"))
})

test_that("Message function work properly bullet", {
  expect_snapshot(sub_process("a bullet item"))
})

#----    get_file_info    ----

test_that("file info are correct", {
  
  ex_1 <- list(path = "foo",
               file_name = "new-file.Rnw",
               extension = "rnw",
               file_basename = "new-file")
  ex_2 <- list(path = ".",
               file_name = "new.file.Rmd",
               extension = "rmd",
               file_basename = "new.file")
  
  # identify folder and file 
  expect_identical(get_file_info("foo/new-file.Rnw"), ex_1)
  # identify the extension when multiple "." 
  expect_identical(get_file_info("new.file.Rmd"), ex_2)
  
  expect_error(get_file_info("my_file"), "file do not include extension")
  expect_error(get_file_info(20), "file has to be a single string")
})

#----    get_instructions    ----

test_that("check get_instructions", {
  # Rmd
  file_info <- get_file_info("foo/new-file.Rmd")
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = TRUE))
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = FALSE))
  
  # Rnw
  file_info <- get_file_info("new-file.Rnw")
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = TRUE))
  expect_snapshot_output(get_instructions(file_info = file_info, hide_code = FALSE))
})

#----    format_document    ----

test_that("check format_document", {
  # Rmd
  file_rmd <- paste0(file_path, "utils/example-1.Rmd")
  document <- readLines(file_rmd)
  file_info <- get_file_info(file_rmd)
  expect_snapshot_output(format_document(document, file_info = file_info, 
                                         hide_code = FALSE))
  
  # Rnw
  file_rnw <- paste0(file_path, "utils/example-1.Rnw")
  document <- readLines(file_rnw)
  file_info <- get_file_info(file_rnw)
  expect_snapshot_output(format_document(document, file_info = file_info,
                                         hide_code = TRUE))
})

#----    check_dribble    ----

test_that("check check_dribble", {
  # dribble_hello_world <- get_dribble_info(gfile = "Hello-world")$file
  # save(dribble_hello_world, file = paste0(file_path, "utils/dribble_hello_world.rda"))
  load(paste0(file_path, "utils/dribble_hello_world.rda"))
  
  # none
  expect_error(check_dribble(dribble_hello_world, "Hello-world"))
  expect_error(check_dribble(dribble_hello_world[-1, ], "Hello-world", NA))
  
  # single
  expect_error(check_dribble(dribble_hello_world[-1, ], "Hello-world", 
                            test = "single"))
  expect_error(check_dribble(dribble_hello_world[c(1, 1), ], "Hello-world", 
                            test = "single"))
  expect_error(check_dribble(dribble_hello_world, "Hello-world", 
                            test = "single"), NA)
  
  # both
  expect_error(check_dribble(dribble_hello_world[c(1,1), ], "Hello-world", 
                            test = "both"))
  expect_error(check_dribble(dribble_hello_world, "Hello-world", 
                            test = "both"), NA)
  expect_error(check_dribble(dribble_hello_world[-1], "Hello-world", 
                            test = "both"), NA)
  
})

#----    eval_instructions    ----

document <- readLines(paste0(file_path, "utils/example_instructions.txt"), 
                      warn = FALSE)


test_that("check eval_instructions full file", {
  # full file 
  expect_snapshot_output(eval_instructions(document))
})

test_that("check eval_instructions no instructions", {
  # no instructions delimiters
  expect_warning(eval_1 <- eval_instructions(document[-1]), 
                 regexp = "Failed retrieving instructions delimiters")
  expect_snapshot_output(eval_1)
  expect_warning(eval_1_bis <- eval_instructions(document[-8]),
                 regexp = "Failed retrieving instructions delimiters")
  expect_snapshot_output(eval_1_bis)
})

test_that("check eval_instructions no file_name", {
  # no file_name
  expect_warning(eval_2 <- eval_instructions(document[-6]),
                 regexp = "Failed retrieving FILE-NAME")
  expect_snapshot_output(eval_2)
  expect_warning(eval_3 <- eval_instructions(document[-6], file_name = "example_instructions.txt"),
                 regexp = "Failed retrieving FILE-NAME")
  expect_snapshot_output(eval_3)
})

test_that("check eval_instructions no hide_code", {
  # no hide_code
  expect_warning(eval_4 <- eval_instructions(document[-c(7,9)]),
                 regexp = "Failed retrieving HIDE-CODE")
  expect_snapshot_output(eval_4)
  expect_warning(eval_5 <- eval_instructions(document[-c(7,12)]),
                 regexp = "Failed retrieving HIDE-CODE")
  expect_snapshot_output(eval_5)
  expect_warning(eval_6 <- eval_instructions(document[-c(7, 9, 12)]),
                 regexp = "Failed retrieving HIDE-CODE")
  expect_snapshot_output(eval_6)
  
})


#----    load_code    ----

test_that("check load_code", {
  expect_error(load_code(file_name = "new-file.Rmd", path = "foo", 
                         type = "header"), "^Failed restoring code.*")
})

#----    does_error    ----

test_that("check does_error", {
  expect_true(does_error(stop()))
  expect_false(does_error(mean(1:5)))
})

#----    sanitize_path    ----

test_that("check sanitize_path", {
  expect_match(sanitize_path("my_path/foo/"), "my_path/foo")
  expect_match(sanitize_path("my_path/foo"), "my_path/foo")
  expect_null(sanitize_path(NULL))
})

#----    check_supported_documents    ----

test_that("check sanitize_path", {
  
  file_info <- get_file_info("new-file.txt")
 
  expect_error(check_supported_documents(file_info), "not supported file")
})

#----    sanitize_document    ----

test_that("check sanitize_document", {
  expect_match(sanitize_document(c("Line1\n", 
                                   "Line2\n\n\n", 
                                   "Line3\n\n\n Line4")),
               "Line1\n\nLine2\n\n\nLine3\n\n Line4\n")
})

#----    get_os    ----

test_that("get_os", {
  expect_true({
  os <- get_os()
  os %in% c("unix", "windows")
  })
})

#----    is_balnk    ----

test_that("is_blank works properly", {
  expect_true({is_blank("     ")})
  expect_true({is_blank("")})
  expect_true({is_blank(NULL)})
  
  expect_false({is_blank("Hello World")})
  expect_false({is_blank(NA)})
  })


#----





