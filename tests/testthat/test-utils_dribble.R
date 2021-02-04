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

})


#----
