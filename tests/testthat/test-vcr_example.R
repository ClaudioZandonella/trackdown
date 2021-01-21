# EXAMPLE VCR USAGE: RUN AND DELETE ME

#----    find files in root    ----

test_that("root works", {
  skip_if_no_token()
  skip_if_offline()
  
  vcr::use_cassette("get_dribble_test", {
    dribble_hello_world <- get_dribble(gfile = "Hello-World")
  })
  testthat::expect_equal(nrow(dribble_hello_world),1)
})


#----

