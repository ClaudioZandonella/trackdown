library("vcr") # *Required* as vcr is set up on loading

get_auth_credentials()

invisible(vcr::vcr_configure(
  dir = vcr::vcr_test_path("fixtures"),
  filter_request_headers = list(Authorization = "My bearer token is safe"),
  write_disk_path = vcr::vcr_test_path("vcr_files")
))
vcr::check_cassette_names()
