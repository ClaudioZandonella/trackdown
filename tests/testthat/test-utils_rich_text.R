#####################################
####    test Utils Rich Text     ####
#####################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    get_param_highlight_text    ----

test_that("get correct request parameters from get_param_highlight_text()", {
  
  # normal rmd text
  rmd_rich_text <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-rich-text.txt")), collapse = "\n")
  res_1 <- get_param_highlight_text(rmd_rich_text, extension = "rmd")
  extract_1 <- lapply(res_1, function(x) substr(rmd_rich_text,
                                                x$updateTextStyle$range$startIndex,
                                                x$updateTextStyle$range$endIndex))
  
  expect_equal(length(res_1), 18)
  expect_snapshot_output(res_1[1:3])
  expect_snapshot_output(extract_1)

  # hide code rmd text
  rmd_rich_text_hide_code <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-rich-text-hide-code.txt")), collapse = "\n")
  res_2 <- get_param_highlight_text(rmd_rich_text_hide_code, extension = "rmd")
  extract_2 <- lapply(res_2, function(x) substr(rmd_rich_text_hide_code,
                                                x$updateTextStyle$range$startIndex,
                                                x$updateTextStyle$range$endIndex))
  
  expect_equal(length(res_2), 18)
  expect_snapshot_output(res_2[1:3])
  expect_snapshot_output(extract_2)
  
  # no important rmd text
  rmd_minimal <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-minimal.txt")), collapse = "\n")
  res_3 <- get_param_highlight_text(rmd_minimal, extension = "rmd")
  expect_equal(length(res_3), 1)
  expect_snapshot_output(res_3)
  
  # custom color
  res_4 <- get_param_highlight_text(rmd_minimal, extension = "rmd",
                                    rich_text_par = list(rgb_color = list(
                                      red = 102/255,
                                      green = 204/255,
                                      blue = 255/255)))
  expect_snapshot_output(res_4)
})


#----    get_patterns_highlight    ----

test_that("get correct patterns from get_patterns_highlight()", {
  
  # Rmd
  expect_snapshot_output(get_patterns_highlight(extension = "rmd"))
  
})

#----    get_range_index    ----

test_that("get correct range indexes from get_range_index()", {
  
  #---- Rmd ----
  pattern_rmd <- get_patterns_highlight(extension = "rmd")
  
  # normal rmd text
  rmd_rich_text <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-rich-text.txt")), collapse = "\n")
  res_1 <- get_range_index(pattern_rmd[4], rmd_rich_text)
  
  expect_snapshot_output(res_1)
  
  # hide code rmd text
  rmd_rich_text_hide_code <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-rich-text-hide-code.txt")), collapse = "\n")
  res_2 <- get_range_index(pattern_rmd[2], rmd_rich_text_hide_code)
  
  expect_snapshot_output(res_2)
  
  # No matches
  res_3 <- get_range_index(pattern_rmd[2], rmd_rich_text)
  expect_equal(nrow(res_3), 0)
})


#----    template_highlight_text    ----

test_that("get correct template from template_highlight_text()", {
  
  expect_snapshot_output(
    template_highlight_text(start_index = 1, end_index = 100))
  
})
