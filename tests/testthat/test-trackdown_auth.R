####################################
####    test trackdown Auth     ####
####################################

#----    check_from_trackdown    ----

test_that("check check_from_trackdown() wprks properly", {
  expect_null(check_from_trackdown())
})


#----    trackdown_app    ----

test_that("check check_from_trackdown() wprks properly", {
  expect_equal(length(.trackdown_auth()), 4)
  expect_match(.trackdown_auth()$appname, "trackdown-rpackage")
})
