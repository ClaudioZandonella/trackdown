###################################
####    test Utils Dribble     ####
###################################

file_path <- ifelse(interactive(), "tests/testthat/test_files/", "test_files/")

#----    get_path_dribble    ----

test_that("get the correct path dribble", {
  skip_if_no_token()
  skip_if_offline()

  # single folder
  vcr::use_cassette("get_path_dribble_test_1", {
    dribble_path_1 <- get_path_dribble(path = "reading_folder")
  })
  expect_match(dribble_path_1$id, "1Ow7GM1dLfu31eygq9Dc8tG6b5IMdD2mr")

  # multiple folders
  vcr::use_cassette("get_path_dribble_test_2", {
    dribble_path_2 <- get_path_dribble(path = "reading_folder/my_folder")
  })
  expect_equal(nrow(dribble_path_2), 2)

  # correct subfolder
  vcr::use_cassette("get_path_dribble_test_3", {
    dribble_path_3 <- get_path_dribble(path = "reading_folder/my_folder/foo_folder")
  })
  expect_match(dribble_path_3$id, "1iRRUiG-IqA8KGvFVyrQWSUQgJJ7i8xYm")

  # not available folder create new folder
  vcr::use_cassette("get_path_dribble_test_4", {
    dribble_path_4 <- get_path_dribble(path = "writing_folder/no_available_folder")
    googledrive::drive_rm(dribble_path_4)
  })
  expect_match(dribble_path_4$name, "no_available_folder")

  # not available folder create error no unique parent folder
  vcr::use_cassette("get_path_dribble_test_5", {
    dribble_path_5 <- tryCatch(
      get_path_dribble(path = "reading_folder/my_folder/no_available_folder"),
      error = function(e) e)
  })
  # expect message start with "No unique parent folder"
  expect_true(grepl("^No unique parent folder",dribble_path_5$message))

  # not available folder create process arrested
  vcr::use_cassette("get_path_dribble_test_6", {
    dribble_path_6 <- tryCatch(
      get_path_dribble(path = "reading_folder/my_folder/no_available_folder", .response = 2),
      error = function(e) e)
  })
  # expect message start with "No unique parent folder"
  expect_equal(as.character(dribble_path_6$call), c("stop_quietly","Process arrested"))

})

#----    get_dribble_info()    ----

test_that("get the correct dribble", {
  skip_if_no_token()
  skip_if_offline()

  # file in root folder
  vcr::use_cassette("get_dribble_info_1", {
    dribble_info_1 <- get_dribble_info(gfile = "Hello-World")
  })
  expect_match(dribble_info_1$file$id,
               "1wawg2T1bCeRTkYlrdoqbIXj59ASB_x2NZXz903yCCag")
  expect_match(dribble_info_1$parent$id,
               "0APbXnIs35pMSUk9PVA")

  # file in folder
  vcr::use_cassette("get_dribble_info_2", {
    dribble_info_2 <- get_dribble_info(gfile = "Hello-World", path = "reading_folder")
  })
  expect_match(dribble_info_2$file$id,
               "1LJzwht6qXjws_UK3qWChe5InC-IIXwDjrPYvqU05mYE")
  expect_match(dribble_info_2$parent$id,
               "1Ow7GM1dLfu31eygq9Dc8tG6b5IMdD2mr")
})

#----    get_parent_dribble()    ----

test_that("get the correct parent dribble", {
  skip_if_no_token()
  skip_if_offline()

  # root id
  vcr::use_cassette("get_parent_dribble_1", {
    parent_dribble_1 <- get_parent_dribble(path = NULL)
  })
  expect_match(parent_dribble_1$name, "My Drive")

  # file in folder
  vcr::use_cassette("get_parent_dribble_2", {
    parent_dribble_2 <- get_parent_dribble(path = "reading_folder")
  })
  expect_match(parent_dribble_2$name, "reading_folder")
})

#----    create_drive_folder()    ----

test_that("create drive folders correctly", {
  skip_if_no_token()
  skip_if_offline()

  folder_names <- c("foo")
  load(paste0(file_path, "dribble_writing_folder.rda"))

  # folder in another folder
  vcr::use_cassette("create_drive_folder_1", {
    drive_folder_1 <- create_drive_folder(name = folder_names, parent_dribble = dribble_writing_folder)
    googledrive::drive_rm(drive_folder_1)
  })
  expect_match(drive_folder_1$name, "foo")

  # folder in root
  vcr::use_cassette("create_drive_folder_2", {
    drive_folder_2 <- create_drive_folder(name = folder_names[1], parent_dribble = NULL)
    googledrive::drive_rm(drive_folder_2)
  })
  expect_match(drive_folder_2$name, "foo")
})

#----    get_root_dribble()    ----

test_that("get the correct root dribble", {
  skip_if_no_token()
  skip_if_offline()

  # root id
  vcr::use_cassette("get_root_dribble_1", {
    root_dribble_1 <- get_root_dribble()
  })
  expect_match(root_dribble_1$name, "My Drive")

})

#----
