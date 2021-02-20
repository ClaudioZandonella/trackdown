###################################
####    test Utils Dribble    ####
###################################

#----    get_path_dribble    ----


test_that("get the correct path dribble", {
  skip_if_no_token()
  skip_if_offline()

  # single folder
  vcr::use_cassette("get_path_dribble_test_1", {
    dribble_path_1 <- get_path_dribble(path = "reading_test")
  })
  expect_equal(dribble_path_1$id, "1nDVAOBmr7ZOs_ZaYVdFHVS8ykomvpoX6")

  # multiple folders
  vcr::use_cassette("get_path_dribble_test_2", {
    dribble_path_2 <- get_path_dribble(path = "reading_test/my_folder")
  })
  expect_equal(nrow(dribble_path_2), 2)

  # correct subfolder
  vcr::use_cassette("get_path_dribble_test_3", {
    dribble_path_3 <- get_path_dribble(path = "reading_test/my_folder/foo_folder")
  })
  expect_equal(dribble_path_3$id, "10ZvYoaEj2-LfHHgs_pNP_PRBMutbtEjw")
  
  # not available folder create new folder
  vcr::use_cassette("get_path_dribble_test_4", {
    dribble_path_4 <- get_path_dribble(path = "no_available_folder")
    googledrive::drive_rm(dribble_path_4)
  })
  expect_match(dribble_path_4$name, "no_available_folder")
  
  # not available folder create error no unique parent folder
  vcr::use_cassette("get_path_dribble_test_5", {
    dribble_path_5 <- tryCatch(
      get_path_dribble(path = "reading_test/my_folder/no_available_folder"),
      error = function(e) e)
  })
  # expect message start with "No unique parent folder"
  expect_true(grepl("^No unique parent folder",dribble_path_5$message))
  
  # not available folder create process arrested
  vcr::use_cassette("get_path_dribble_test_6", {
    dribble_path_6 <- tryCatch(
      get_path_dribble(path = "reading_test/my_folder/no_available_folder", .response = 2),
      error = function(e) e)
  })
  # expect message start with "No unique parent folder"
  expect_equal(as.character(dribble_path_6$call), c("stop_quietly","Process arrested"))

})


#----
