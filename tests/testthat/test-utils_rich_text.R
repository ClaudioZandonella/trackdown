#####################################
####    test Utils Rich Text     ####
#####################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    get_param_highlight_text    ----

test_that("get correct request parameters from get_param_highlight_text()", {
  
  #----    rmd    ----
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
  
  #----    rnw    ----
  
  # normal rnw text
  rnw_main <- paste(readLines(
    paste0(file_path, "utils_rich_text/rnw-main.txt")), collapse = "\n")
  res_5 <- get_param_highlight_text(rnw_main, extension = "rnw")
  extract_5 <- lapply(res_5, function(x) substr(rnw_main,
                                                x$updateTextStyle$range$startIndex,
                                                x$updateTextStyle$range$endIndex))
  
  expect_equal(length(res_5), 12)
  expect_snapshot_output(res_5[1:3])
  expect_snapshot_output(extract_5)
  
  # hide code rnw text
  rnw_hide_code <- paste(readLines(
    paste0(file_path, "utils_rich_text/rnw-hide-code.txt")), collapse = "\n")
  res_6 <- get_param_highlight_text(rnw_hide_code, extension = "rnw")
  extract_6 <- lapply(res_6, function(x) substr(rnw_hide_code,
                                                x$updateTextStyle$range$startIndex,
                                                x$updateTextStyle$range$endIndex))
  
  expect_equal(length(res_6), 11) #  11 instead of 12 because set-up chunk is inside header
  expect_snapshot_output(res_6[1:3])
  expect_snapshot_output(extract_6)
  
  # rnw minimal
  rnw_minimal <- paste(readLines(
    paste0(file_path, "utils_rich_text/rnw-minimal.txt")), collapse = "\n")
  res_7 <- get_param_highlight_text(rnw_minimal, extension = "rnw")
  expect_equal(length(res_7), 1)
  expect_snapshot_output(res_7)
})


#----    get_patterns_highlight    ----

test_that("get correct patterns from get_patterns_highlight()", {
  
  # Rmd
  expect_snapshot_output(get_patterns_highlight(extension = "rmd"))
  
  # Rnw
  expect_snapshot_output(get_patterns_highlight(extension = "rnw"))
  
})

#----    check patters    ----

# Citations
test_that("citations are correctly matched", {

  # Rmd
  citations_rmd <- paste(readLines(
    paste0(file_path, "utils_rich_text/citations.Rmd")), collapse = "\n")
  pattern_rmd <- get_patterns_highlight(extension = "rmd")
  
  res_cit_1 <- get_range_index(pattern_rmd["citations"], citations_rmd)
  expect_snapshot_output(res_cit_1)

  # Rnw

})

# Equations
test_that("equations are correctly matched", {

  # Rmd
  equations_rmd <- paste(readLines(
    paste0(file_path, "utils_rich_text/equations.Rmd")), collapse = "\n")
  pattern_rmd <- get_patterns_highlight(extension = "rmd")

  res_inline_eq <- get_range_index(pattern_rmd["inline_equations"], equations_rmd)
  expect_snapshot_output(res_inline_eq)
  
  res_eq <- get_range_index(pattern_rmd["equations"], equations_rmd)
  expect_snapshot_output(res_eq)

})

#----    get_range_index    ----

test_that("get correct range indexes from get_range_index()", {
  
  #---- Rmd ----
  pattern_rmd <- get_patterns_highlight(extension = "rmd")
  
  # normal rmd text
  rmd_rich_text <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-rich-text.txt")), collapse = "\n")
  res_1 <- get_range_index(pattern_rmd["chunks"], rmd_rich_text)
  
  expect_snapshot_output(res_1)
  
  # hide code rmd text
  rmd_rich_text_hide_code <- paste(readLines(
    paste0(file_path, "utils_rich_text/rmd-rich-text-hide-code.txt")), collapse = "\n")
  res_2 <- get_range_index(pattern_rmd["tags"], rmd_rich_text_hide_code)
  
  expect_snapshot_output(res_2)
  
  # No matches
  res_3 <- get_range_index(pattern_rmd["tags"], rmd_rich_text)
  expect_equal(nrow(res_3), 0)
  
  
  #---- Rmd ----
  pattern_rnw <- get_patterns_highlight(extension = "rnw")
  
  # normal rmd text
  rnw_main <- paste(readLines(
    paste0(file_path, "utils_rich_text/rnw-main.txt")), collapse = "\n")
  res_4 <- get_range_index(pattern_rnw["chunks"], rnw_main)
  
  expect_snapshot_output(res_4)
  
  # hide code rmd text
  rnw_hide_code <- paste(readLines(
    paste0(file_path, "utils_rich_text/rnw-hide-code.txt")), collapse = "\n")
  res_5 <- get_range_index(pattern_rnw["tags"], rnw_hide_code)
  
  expect_snapshot_output(res_5)
  
  # No matches
  res_6 <- get_range_index(pattern_rnw["tags"], rnw_main)
  expect_equal(nrow(res_6), 0)
})


#----    template_highlight_text    ----

test_that("get correct template from template_highlight_text()", {
  
  expect_snapshot_output(
    template_highlight_text(start_index = 1, end_index = 100))
  
})
