library("vcr") # *Required* as vcr is set up on loading

get_auth_credentials()

invisible(vcr::vcr_configure(
  dir = "../fixtures",
  filter_request_headers = list(Authorization = "My bearer token is safe"),
  write_disk_path = "../vcr_files"
))
vcr::check_cassette_names()
