# setup ------------------------------------------------------------------------
suppressWarnings(library(dplyr))
suppressWarnings(library(ggplot2))

initialize_db()
start_db()

rm(
  tbl_control,
  tbl_doi,
  tbl_object,
  tbl_score,
  keyword_synonyms,
  keywords_control,
  keywords_object,
  time_control,
  time_object,
  envir = .GlobalEnv
)

add_control_keyword(
  keyword = c("gmail", "map", "translate", "wikipedia", "youtube"),
  time = "2010-01-01 2019-12-31"
)

add_object_keyword(
  keyword = c("fc barcelona", "fc bayern", "manchester united", "real madrid"),
  time = "2010-01-01 2019-12-31"
)

# try download object ----------------------------------------------------------
test_that("download_object1", {
  out <- expect_message(
    download_object(object = 1, locations = countries[[1]]),
    "Download for object data failed.\nThere is no data in 'data_control' for control batch 1 and location US."
  )
})

# download control --------------------------------------------------------------
test_that("download_control1", {
  out <- capture_messages(download_control(control = 1, locations = countries[1:3]))

  expect_match(
    out,
    "Successfully downloaded control data | control: 1 | location: US [1/3]",
    all = FALSE
  )
  expect_match(
    out,
    "Successfully downloaded control data | control: 1 | location: CN [2/3]",
    all = FALSE
  )
  expect_match(
    out,
    "Successfully downloaded control data | control: 1 | location: JP [3/3]",
    all = FALSE
  )

  out <- filter(.tbl_control, batch == 1 & location != "world")
  out <- collect(out)
  expect_equal(nrow(out), 1800)
})

# re-download control ----------------------------------------------------------
test_that("download_control2", {
  expect_message(
    download_control(control = 1, locations = countries[[1]]),
    "Control data already available | control: 1 | location: US [1/1]"
  )
})

# download control global ------------------------------------------------------
test_that("download_control3", {
  expect_message(
    download_control_global(control = 1),
    "Successfully downloaded control data | control: 1 | location: world [1/1]"
  )
  out <- filter(.tbl_control, batch == 1 & location == "world")
  out <- collect(out)
  expect_equal(nrow(out), 600)
})

# download control signals -----------------------------------------------------
test_that("download_control4", {
  expect_error(
    download_control(control = 1.5),
    "Batch number must be object of type integer.\nYou provided a non-integer numeric value."
  )
  expect_error(
    download_control(control = "A"),
    "no applicable method"
  )
  expect_error(
    download_control(control = TRUE),
    "no applicable method"
  )
  expect_error(
    download_control(control = sum),
    "no applicable method"
  )
})

test_that("download_control5", {
  expect_error(
    download_control(locations = 1),
    '"control"'
  )
  expect_error(
    download_control(locations = TRUE),
    '"control"'
  )
  expect_error(
    download_control(locations = sum),
    '"control"'
  )
})

test_that("download_control6", {
  expect_error(
    download_control_global(control = 1.5),
    "Batch number must be object of type integer.\nYou provided a non-integer numeric value."
  )
  expect_error(
    download_control_global(control = "A"),
    "no applicable method"
  )
  expect_error(
    download_control_global(control = TRUE),
    "no applicable method"
  )
  expect_error(
    download_control_global(control = sum),
    "no applicable method"
  )
})

# download object --------------------------------------------------------------
test_that("download_object2", {
  out <- capture_messages(download_object(object = 1, locations = countries[1:3]))

  expect_match(
    out,
    "Successfully downloaded object data | object: 1 | control: 1 | location: US [1/3]",
    all = FALSE
  )
  expect_match(
    out,
    "Successfully downloaded object data | object: 1 | control: 1 | location: CN [2/3]",
    all = FALSE
  )
  expect_match(
    out,
    "Successfully downloaded object data | object: 1 | control: 1 | location: JP [3/3]",
    all = FALSE
  )

  out <- filter(.tbl_object, batch_o == 1 & location != "world")
  out <- collect(out)
  expect_equal(nrow(out), 1800)
})

# re-download object -----------------------------------------------------------
test_that("download_object3", {
  expect_message(
    download_object(object = 1, locations = countries[[1]]),
    "Object data already available | object: 1 | control: 1 | location: US [1/1]"
  )
})

# download object global -------------------------------------------------------
test_that("download_object4", {
  expect_message(
    download_object_global(object = 1),
    "Successfully downloaded object data | object: 1 | control: 1 | location: world [1/1]"
  )
  out <- filter(.tbl_object, batch_o == 1 & location == "world")
  out <- collect(out)
  expect_equal(nrow(out), 600)
})

# download object signals ------------------------------------------------------
test_that("download_object5", {
  expect_error(
    download_object(object = 1.5),
    "Batch number must be object of type integer.\nYou provided a non-integer numeric value."
  )
  expect_error(
    download_object(object = "A"),
    "no applicable method"
  )
  expect_error(
    download_object(object = TRUE),
    "no applicable method"
  )
  expect_error(
    download_object(object = sum),
    "no applicable method"
  )
})

test_that("download_object6", {
  expect_error(
    download_object(control = 1.5, object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer numeric value."
  )
  expect_error(
    download_object(control = "A", object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer value."
  )
  expect_error(
    download_object(control = TRUE, object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer value."
  )
  expect_error(
    download_object(control = sum, object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer value."
  )
  expect_error(
    download_object(control = 1:5, object = 1),
    "'control' must be object of length 1.\nYou provided an object of length 5."
  )
})

test_that("download_object7", {
  expect_error(
    download_object(object = 1, locations = 1),
    "'locations' must be object of type character.\nYou provided an object of type double."
  )
  expect_error(
    download_object(object = 1, locations = TRUE),
    "'locations' must be object of type character.\nYou provided an object of type logical."
  )
  expect_error(
    download_object(object = 1, locations = sum),
    "'locations' must be object of type character.\nYou provided an object of type builtin."
  )
})

test_that("download_object8", {
  expect_error(
    download_object_global(object = 1.5),
    "Batch number must be object of type integer.\nYou provided a non-integer numeric value."
  )
  expect_error(
    download_object_global(object = "A"),
    "no applicable method"
  )
  expect_error(
    download_object_global(object = TRUE),
    "no applicable method"
  )
  expect_error(
    download_object_global(object = sum),
    "no applicable method"
  )
})

test_that("download_object9", {
  expect_error(
    download_object_global(control = 1.5, object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer numeric value."
  )
  expect_error(
    download_object_global(control = "A", object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer value."
  )
  expect_error(
    download_object_global(control = TRUE, object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer value."
  )
  expect_error(
    download_object_global(control = sum, object = 1),
    "Batch number must be object of type integer.\nYou provided a non-integer value."
  )
  expect_error(
    download_object_global(control = 1:5, object = 1),
    "'control' must be object of length 1.\nYou provided an object of length 5."
  )
})

# disconnect -------------------------------------------------------------------
disconnect_db()
unlink("db", recursive = TRUE)
