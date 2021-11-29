###################################
####    test Utils Manager     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    evaluate_file    ----

test_that("evaluate file correctly", {
  skip_if_no_token()
  skip_if_offline()

  file <- paste0(file_path,"utils_manager/Hello-World.Rmd")
  file_info <- get_file_info(file)

  # # old_eval_file
  # old_eval_file <- evaluate_file(file = file, gpath = "unit_tests/utils_manager", test = "single")
  # save(old_eval_file, file = "tests/testthat/test_files/utils_manager/old_eval_file.rda")
  load(paste0(file_path, "utils_manager/old_eval_file.rda"))


  # error already existing file
  vcr::use_cassette("evaluate_file_test_1", {
    evaluate_file_1 <- tryCatch(
      evaluate_file(file = file, gfile = "Hello-World-Copy",
                    gpath = "unit_tests/utils_manager", test = "none"),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^A file with this name already exists", evaluate_file_1$message))

  # error multiple existing file
  vcr::use_cassette("evaluate_file_test_2", {
    evaluate_file_2 <- tryCatch(
      evaluate_file(file = file, gfile = "Hello-World-Copy",
                    gpath = "unit_tests/utils_manager", test = "single"),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^More than one file with this name ", evaluate_file_2$message))

  # error no existing file
  vcr::use_cassette("evaluate_file_test_3", {
    evaluate_file_3 <- tryCatch(
      evaluate_file(file = file, gfile = "new-file",
                    gpath = "unit_tests/utils_manager", test = "single"),
      error = function(e) e)
  })
  # expect message starting with
  expect_true(grepl("^No file with this name exists ", evaluate_file_3$message))



  # get file evaluation
  vcr::use_cassette("evaluate_file_test_4", {
    new_eval_file <- evaluate_file(file = file, gpath = "unit_tests/utils_manager",
                                   test = "single")

  })
  expect_equal(new_eval_file$file_info[-1], old_eval_file$file_info[-1])
  expect_equal(new_eval_file$gfile, old_eval_file$gfile)
  expect_equal(new_eval_file$dribble_info$file$id,
               old_eval_file$dribble_info$file$id)
  expect_equal(new_eval_file$dribble_info$parent$id,
               old_eval_file$dribble_info$parent$id)

})

#----    upload_document    ----

test_that("upload the document correctly", {
  skip_if_no_token()
  skip_if_offline()
  gpath <- "unit_tests/utils_manager"

  file <- paste0(file_path,"utils_manager/example-1.Rmd")
  file_info <- get_file_info(file)

  # # dribble_document_old
  # dribble_old_example <- get_dribble_info(gfile = "old-example-1", path = gpath)
  # save(dribble_old_example, file = "tests/testthat/test_files/utils_manager/dribble_old_example.rda")
  load(paste0(file_path, "utils_manager/dribble_old_example.rda"))


  # upload new file
  vcr::use_cassette("upload_document_test_1", {
    dribble_new <- upload_document(file = file, file_info = file_info,
                                   gfile = "new-example-1", gpath = gpath,
                                   dribble_document = dribble_old_example,
                                   hide_code = FALSE, update = FALSE)

    googledrive::drive_rm(dribble_new)
  })
  expect_equal(dribble_new$name, "new-example-1")


  # update old file
  vcr::use_cassette("upload_document_test_2", {
    dribble_old <- upload_document(file = file, file_info = file_info,
                                   gfile = "old-example-1", gpath = gpath,
                                   dribble_document = dribble_old_example,
                                   hide_code = TRUE, update = TRUE)

  })
  expect_equal(dribble_old$name, "old-example-1")

  # remove files
  unlink(paste0(file_path, "utils_manager/.trackdown"), recursive = TRUE)
})

#----    upload_output    ----

test_that("upload the output correctly", {
  skip_if_no_token()
  skip_if_offline()
  gpath <- "unit_tests/utils_manager"

  # html
  output_html <- paste0(file_path,"utils_manager/example-2.html")
  output_info_html <- get_file_info(output_html)


  # # dribble_output_old
  # dribble_old_output <- get_dribble_info(gfile = "old-example-2-output", path = gpath)
  # save(dribble_old_output, file = "tests/testthat/test_files/utils_manager/dribble_old_output.rda")
  load(paste0(file_path, "utils_manager/dribble_old_output.rda"))


  # upload new output html
  vcr::use_cassette("upload_output_test_1", {
    dribble_new <- upload_output(path_output = output_html, output_info = output_info_html,
                                 gfile_output = "new-output", gpath = gpath,
                                 dribble_output = dribble_old_output,
                                 update = FALSE, .response = 2L)

    googledrive::drive_rm(dribble_new)
  })
  expect_equal(dribble_new$name, "new-output")


  # update old output
  vcr::use_cassette("upload_output_test_2", {
    dribble_old <- upload_output(path_output = output_html, output_info = output_info_html,
                                 gfile_output = "old-example-2-output", gpath = gpath,
                                 dribble_output = dribble_old_output,
                                 update = TRUE, .response = 1L)
  })
  expect_equal(dribble_old$name, "old-example-2-output")

})


#----
