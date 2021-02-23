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

# #----    parse_label_rmd    ----
# 
# test_that("get the correct parse_label_rmd", {
#   
#   # langugae and name
#   expect_identical(parse_label_rmd(c("r", "chunck_name")), 
#                    tibble::tibble(language = "r",
#                                   name = "chunck_name"))
#   # only language
#   expect_identical(parse_label_rmd(c("r")), 
#                    tibble::tibble(language = "r",
#                                   name = NA))
# })
# 
# #----    parse_label_rnw    ----
# 
# test_that("get the correct parse_label_rnw", {
#   
#   label <- list("chunck_name",
#                 eval = FALSE)
#   
#   # name and options
#   expect_identical(parse_label_rnw(label, params = "chunck_name, eval = FALSE"), 
#                    tibble::tibble(language = NA,
#                                   name = "chunck_name",
#                                   options = ", eval = FALSE"))
#   # no name and options
#   expect_identical(parse_label_rnw(label[2], params = "eval = FALSE"), 
#                    tibble::tibble(language = NA,
#                                   name = NA,
#                                   options = "eval = FALSE"))
#   # name and no options
#   expect_identical(parse_label_rnw(label[1], params = "chunck_name"), 
#                    tibble::tibble(language = NA,
#                                   name = "chunck_name",
#                                   options = ""))
#   # no name and no options
#   expect_identical(parse_label_rnw(list(), params = ""), 
#                    tibble::tibble(language = NA,
#                                   name = NA,
#                                   options = ""))
# })

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

#----
