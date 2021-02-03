###################################
####    test Matrix Weights    ####
###################################

#----    Message Utils    ----

test_that("Message function work prorerly", {
  expect_snapshot_output(main_process("horizontal line"))
  expect_snapshot_output(emph_file("blue text"))
  expect_snapshot_output(sub_process("a bullet item"))
  expect_snapshot_output(start_process("a colored bulled item"))
  expect_snapshot_output(finish_process("a ticked item"))
})



#----



