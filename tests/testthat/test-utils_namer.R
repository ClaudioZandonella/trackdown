###################################
####    test Utils Dribble     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    quote_label    ----

test_that("get the correct quote_label", {
  
  expect_match(quote_label("r chunck_name, eval = FALSE"), 
               "'r chunck_name', eval = FALSE")
  expect_match(quote_label("r, eval = FALSE"), 
               "'r', eval = FALSE")
  expect_match(quote_label("r eval = FALSE"), 
               "r eval = FALSE")
})

#----    transform_params    ----

test_that("get the correct transform_params", {
  
  #---- rmd ----
  
  # language, name and options
  expect_identical(transform_params(params = "r chunck_name, eval = FALSE", extension = "rmd"), 
                   tibble::tibble(language = "r",
                                  name = "chunck_name",
                                  options = ", eval = FALSE"))
  # language, no name and options
  expect_identical(transform_params(params = "r eval = FALSE", extension = "rmd"), 
                   tibble::tibble(language = "r",
                                  name = NA,
                                  options = ", eval = FALSE"))
  # language, name and no options
  expect_identical(transform_params(params = "r chunck_name", extension = "rmd"), 
                   tibble::tibble(language = "r",
                                  name = "chunck_name",
                                  options = ""))
  # language, no name and no options
  expect_identical(transform_params(params = "r", extension = "rmd"), 
                   tibble::tibble(language = "r",
                                  name = NA,
                                  options = ""))
  # no language, no name and options
  expect_identical(transform_params(params = "eval = FALSE", extension = "rmd"), 
                   tibble::tibble(language = NA,
                                  name = NA,
                                  options = "eval = FALSE"))
  # no language, no name and no options
  expect_identical(transform_params(params = "", extension = "rmd"), 
                   tibble::tibble(language = NA,
                                  name = NA,
                                  options = ""))
  
  #---- rnw ----
  
  # name and options
  expect_identical(transform_params(params = "chunck_name, eval = FALSE", extension = "rnw"), 
                   tibble::tibble(language = NA,
                                  name = "chunck_name",
                                  options = ", eval = FALSE"))
  # no name and options
  expect_identical(transform_params(params = "eval = FALSE", extension = "rnw"), 
                   tibble::tibble(language = NA,
                                  name = NA,
                                  options = "eval = FALSE"))
  # name and no options
  expect_identical(transform_params(params = "chunck_name", extension = "rnw"), 
                   tibble::tibble(language = NA,
                                  name = "chunck_name",
                                  options = ""))
  # no name and no options
  expect_identical(transform_params(params = "", extension = "rnw"), 
                   tibble::tibble(language = NA,
                                  name = NA,
                                  options = ""))
})

#----    get_chunk_info    ----

test_that("get the correct get_chunk_info", {
  # rmd
  lines_rmd <- readLines(paste0(file_path, "example_1_rmd.txt"))
  info_patterns_rmd <- get_extension_patterns(extension = "rmd")
  expect_snapshot_output(get_chunk_info(lines_rmd, info_patterns_rmd))
  
  # rnw
  lines_rnw <- readLines(paste0(file_path, "example_1_rnw.txt"))
  info_patterns_rnw <- get_extension_patterns(extension = "rnw")
  expect_snapshot_output(get_chunk_info(lines_rnw, info_patterns_rnw))
  
  # no chuncks
  lines_no_chunck <- c("A file with no chuncks")
  expect_null(get_chunk_info(lines_no_chunck, info_patterns_rmd))
  
})

#----
