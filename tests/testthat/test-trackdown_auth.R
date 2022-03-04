####################################
####    test trackdown Auth     ####
####################################

#----    check_from_trackdown    ----

test_that("check check_from_trackdown() wprks properly", {
  expect_null(check_from_trackdown())
})


#----    trackdown_app    ----

test_that("check check_from_trackdown() wprks properly", {
  expect_match(.trackdown_auth()$appname, "trackdown-rpackage")
  expect_equal(length(.trackdown_auth()), 4)
})
