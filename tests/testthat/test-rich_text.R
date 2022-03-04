###############################
####    test Rich Text     ####
###############################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    run_rich_text    ----

test_that("get correct rich document in google Docs with run_rich_text()", {
  skip_if_no_token()
  skip_if_offline()
  
  #--- rmd ----

  # Rmd main normal

  # update_file(file = paste0(file_path, "rich_text/rmd-main.Rmd"),
  #             gpath = "unit_tests/rich_text", rich_text = FALSE, force = TRUE)

  text_main <- paste(readLines(paste0(file_path, "rich_text/rmd-main.txt")), collapse = "\n")
  vcr::use_cassette("rich_text_rmd_1", {
    response_1 <- run_rich_text(text = text_main,
                                document_ID = "1XDtFNFG4G3VlHeWiDO5GStLmPZcCcZ4yEXh5Fv2uU3M",
                                extension = "rmd")
  })

  expect_snapshot_output(response_1$replies)

  # Rmd main hide code

  # update_file(file = paste0(file_path, "rich_text/rmd-main.Rmd"),
  #             gpath = "unit_tests/rich_text", gfile = "rmd-main-hide-code",
  #             hide_code = TRUE, rich_text = FALSE, force = TRUE)

  text_main_hide_code <- paste(readLines(paste0(file_path, "rich_text/rmd-main-hide-code.txt")), collapse = "\n")
  vcr::use_cassette("rich_text_rmd_2", {
    response_2 <- run_rich_text(text = text_main_hide_code,
                                document_ID = "1Whlu-u_c9r3SmanIT-H90QHvfqe7GpQv8YTFqkJBueA",
                                extension = "rmd")
  })

  expect_snapshot_output(response_2$replies)

  # Rmd child color blue

  # update_file(file = paste0(file_path, "rich_text/rmd-child.Rmd"),
  #             gpath = "unit_tests/rich_text", hide_code = FALSE,
  #             rich_text = FALSE, force = TRUE)

  text_child <- paste(readLines(paste0(file_path, "rich_text/rmd-child.txt")), collapse = "\n")
  vcr::use_cassette("rich_text_rmd_3", {
    response_3 <- run_rich_text(text = text_child,
                                document_ID = "1HfHnL4ccBjG_4cF3XMg0krmR039GJBJQXkVdvMkNgiA",
                                extension = "rmd",
                                rich_text_par = list(rgb_color = list(
                                  red = 102/255,
                                  green = 204/255,
                                  blue = 255/255)))
  })

  expect_snapshot_output(response_3$replies)
  
  
  #----    rnw    ----
  
  # Rnw main normal
  
  # update_file(file = paste0(file_path, "rich_text/rnw-main.Rnw"),
  #             gpath = "unit_tests/rich_text", rich_text = FALSE, force = TRUE)
  
  rnw_main <- paste(readLines(paste0(file_path, "rich_text/rnw-main.txt")), collapse = "\n")
  vcr::use_cassette("rich_text_rnw_1", {
    response_4 <- run_rich_text(text = rnw_main,
                                document_ID = "14vZunKODTzGtko9u3Y_aWxLYRlDmifCQgQYUDc61q_s",
                                extension = "rnw")
  })
  
  expect_snapshot_output(response_4$replies)
  
  # Rmd main hide code
  
  # update_file(file = paste0(file_path, "rich_text/rnw-main.Rnw"),
  #             gpath = "unit_tests/rich_text", gfile = "rnw-hide-code",
  #             hide_code = TRUE, rich_text = FALSE, force = TRUE)
  
  rnw_hide_code <- paste(readLines(paste0(file_path, "rich_text/rnw-hide-code.txt")), collapse = "\n")
  vcr::use_cassette("rich_text_rnw_2", {
    response_5 <- run_rich_text(text = rnw_hide_code,
                                document_ID = "1Tyvo-CtnmRa3LF5vxfjwTPN1SWobE8oDc15omGkKHYE",
                                extension = "rnw")
  })
  
  expect_snapshot_output(response_5$replies)
  
  # Rmd child color blue
  
  # update_file(file = paste0(file_path, "rich_text/rnw-child.Rnw"),
  #             gpath = "unit_tests/rich_text", hide_code = FALSE,
  #             rich_text = FALSE, force = TRUE)
  
  rnw_child <- paste(readLines(paste0(file_path, "rich_text/rnw-child.txt")), collapse = "\n")
  vcr::use_cassette("rich_text_rnw_3", {
    response_6 <- run_rich_text(text = rnw_child,
                                document_ID = "15xbnqgbgrsUa3zqmDL1Th6t0N0uJ_zBX8RNsjT3M8Ag",
                                extension = "rnw",
                                rich_text_par = list(rgb_color = list(
                                  red = 102/255,
                                  green = 204/255,
                                  blue = 255/255)))
  })
  
  expect_snapshot_output(response_6$replies)
  

})

# remove files
unlink(paste0(file_path, "rich_text/.trackdown"), recursive = TRUE)


#----    run_rich_text    ----

test_that("get correct request parameters from get_param_request()", {
  
  #---- Rmd ----
  
  # Rmd main normal
  rmd_main <- paste(readLines(paste0(file_path, "rich_text/rmd-main.txt")), collapse = "\n")
  par_1 <- get_param_request(text = rmd_main, document_ID = "document-ID", extension = "rmd")
  
  expect_snapshot_output(str(par_1))
  
})


#----    build_request    ----

test_that("get correct request from build_request()", {
  
  #---- Rmd ----
  
  # Rmd main normal
  rmd_main <- paste(readLines(paste0(file_path, "rich_text/rmd-main.txt")), collapse = "\n")
  par_1 <- get_param_request(text = rmd_main, document_ID = "document-ID", extension = "rmd")
  
  req_1 <- build_request(endpoint = "docs.documents.batchUpdate", 
                         params = par_1, token = "My-token", 
                         base_url = "https://docs.googleapis.com")
  expect_snapshot_output(str(req_1))
  
  # Non existing endpoint
  expect_error(build_request(endpoint = "a-new-endpoint", 
                             params = par_1, token = "My-token", 
                             base_url = "https://docs.googleapis.com"),
               regexp = "^Endpoint .* not recognized")
  
})

#---
