# EXAMPLE VCR USAGE: RUN AND DELETE ME

#----    find files in root    ----
googledrive::drive_has_token()

test_that("root works", {
  skip_if_no_token()
  skip_if_offline()
  
  vcr::use_cassette("testing_root", {
    root_files <- googledrive::drive_find(q = c("'root' in parents"),
                                          team_drive = NULL)
  })
  testthat::expect_equal(nrow(root_files),0)
})


#----

