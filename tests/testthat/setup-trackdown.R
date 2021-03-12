library("vcr") # *Required* as vcr is set up on loading

# get_auth_credentials()

invisible(vcr::vcr_configure(
  dir = vcr::vcr_test_path("fixtures"),
  filter_request_headers = list(Authorization = "My bearer token is safe")
))
vcr::check_cassette_names()
