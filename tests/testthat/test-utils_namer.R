#################################
####    test Utils Namer     ####
#################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    quote_label    ----

test_that("get the correct quote_label", {
  
  expect_match(quote_label("r chunk_name, eval = FALSE"), 
               "'r chunk_name', eval = FALSE")
  expect_match(quote_label("r, chunk_name, eval = FALSE"), 
               "'r, chunk_name', eval = FALSE")
  expect_match(quote_label("r chunk_name"), 
               "'r chunk_name'")
  expect_match(quote_label("r, chunk_name"), 
               "'r, chunk_name'")
  expect_match(quote_label("r, eval = FALSE"), 
               "'r', eval = FALSE")
  expect_match(quote_label("r eval = FALSE"), 
               "r eval = FALSE")
  expect_match(quote_label("r"), "'r'")
  expect_match(quote_label("eval = FALSE"), "eval = FALSE")
  expect_match(quote_label(""), "")
})

#----    transform_params    ----

test_that("get the correct transform_params", {
  
  #---- rmd ----
  
  # language, name and options
  expect_identical(transform_params(params = "r chunk_name, eval = FALSE", extension = "rmd"), 
                   data.frame(language = "r",
                              name = "chunk_name",
                              options = ", eval = FALSE"))
  expect_identical(transform_params(params = "r, chunk_name, eval = FALSE", extension = "rmd"), 
                   data.frame(language = "r",
                              name = "chunk_name",
                              options = ", eval = FALSE"))
  # language, no name and options
  expect_identical(transform_params(params = "r eval = FALSE", extension = "rmd"), 
                   data.frame(language = "r",
                              name = NA,
                              options = ", eval = FALSE"))
  expect_identical(transform_params(params = "r, eval = FALSE", extension = "rmd"), 
                   data.frame(language = "r",
                              name = NA,
                              options = ", eval = FALSE"))
  # language, name and no options
  expect_identical(transform_params(params = "r chunk_name", extension = "rmd"), 
                   data.frame(language = "r",
                              name = "chunk_name",
                              options = ""))
  expect_identical(transform_params(params = "r, chunk_name", extension = "rmd"), 
                   data.frame(language = "r",
                              name = "chunk_name",
                              options = ""))
  # language, no name and no options
  expect_identical(transform_params(params = "r", extension = "rmd"), 
                   data.frame(language = "r",
                              name = NA,
                              options = ""))
  # no language, no name and options
  expect_identical(transform_params(params = "eval = FALSE", extension = "rmd"), 
                   data.frame(language = NA,
                              name = NA,
                              options = "eval = FALSE"))
  # no language, no name and no options
  expect_identical(transform_params(params = "", extension = "rmd"), 
                   data.frame(language = NA,
                              name = NA,
                              options = ""))
  
  #---- rnw ----
  
  # name and options
  expect_identical(transform_params(params = "chunk_name, eval = FALSE", extension = "rnw"), 
                   data.frame(language = NA,
                              name = "chunk_name",
                              options = ", eval = FALSE"))
  # no name and options
  expect_identical(transform_params(params = "eval = FALSE", extension = "rnw"), 
                   data.frame(language = NA,
                              name = NA,
                              options = "eval = FALSE"))
  # name and no options
  expect_identical(transform_params(params = "chunk_name", extension = "rnw"), 
                   data.frame(language = NA,
                              name = "chunk_name",
                              options = ""))
  # no name and no options
  expect_identical(transform_params(params = "", extension = "rnw"), 
                   data.frame(language = NA,
                              name = NA,
                              options = ""))
})

#----    get_chunk_info    ----

test_that("get the correct get_chunk_info", {
  
  # rmd
  lines_rmd <- readLines(paste0(file_path, "utils_namer/example-1.Rmd"))
  info_patterns_rmd <- get_extension_patterns(extension = "rmd")
  expect_snapshot_output(get_chunk_info(lines_rmd, info_patterns_rmd))
  
  # rnw
  lines_rnw <- readLines(paste0(file_path, "utils_namer/example-1.Rnw"))
  info_patterns_rnw <- get_extension_patterns(extension = "rnw")
  expect_snapshot_output(get_chunk_info(lines_rnw, info_patterns_rnw))
  
  # no chunks
  lines_no_chunk <- c("A file with no chunks")
  expect_null(get_chunk_info(lines_no_chunk, info_patterns_rmd))
  expect_null(get_chunk_info(lines_no_chunk, info_patterns_rnw))
  
})

#----
