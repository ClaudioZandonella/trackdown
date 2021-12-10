#############################
####    test Features    ####
#############################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    remove_google_comments    ----

test_that("remove_google_comments works correctly with comments", {
  
  # rmd
  comments <- readLines(paste0(file_path, "features/comments.Rmd"), warn = FALSE)
  no_comments <- readLines(paste0(file_path, "features/no-comments.Rmd"), warn = FALSE)
  expect_snapshot_output(remove_google_comments(comments))
  expect_snapshot_output(remove_google_comments(no_comments))
  
  # rnw
  comments <- readLines(paste0(file_path, "features/comments.Rnw"), warn = FALSE)
  no_comments <- readLines(paste0(file_path, "features/no-comments.Rnw"), warn = FALSE)
  expect_snapshot_output(remove_google_comments(comments))
  expect_snapshot_output(remove_google_comments(no_comments))
})

test_that("remove_google_comments works correctly without comments", {
  
  # rmd
  no_comments <- readLines(paste0(file_path, "features/no-comments.Rmd"), warn = FALSE)
  expect_snapshot_output(remove_google_comments(no_comments))
  
  # rnw
  no_comments <- readLines(paste0(file_path, "features/no-comments.Rnw"), warn = FALSE)
  expect_snapshot_output(remove_google_comments(no_comments))
})

test_that("remove_google_comments works correctly with one comment", {
  
  # rmd
  one_comments <- readLines(paste0(file_path, "features/one-comments.Rmd"), warn = FALSE)
  expect_snapshot_output(remove_google_comments(one_comments))
})

#----

