# EXAMPLE VCR USAGE: RUN AND DELETE ME

#----    find files in root    ----

test_that("root works", {
  vcr::use_cassette("testing_root", {
    # googledrive::drive_auth(email = "reviewdown.test@gmail.com")
    root_id <- googledrive::drive_find(q = c("'root' in parents"),
                                       team_drive = NULL)
  })
  testthat::expect_equal(nrow(root_id),0)
})


#----

