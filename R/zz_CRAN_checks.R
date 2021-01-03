###########################
####    CRAN checks    ####
###########################

#----    ASCII characters    -----

# cat(stringi::stri_escape_unicode("This is a bullet •"))

#----    Build and see vignettes    ----

# devtools::build_vignettes()
# devtools::build()  # Build package source
# install.packages("../PRDA_0.2.0.9000.tar.gz", repos = NULL, type = "source") # Install source
# browseVignettes("PRDA")  # See vignette

#----    Add to .Rbuildignore    ----

# usethis::use_build_ignore("TODO.Rmd")

#----    Check package    ----

# devtools::check()
# devtools::check(vignettes = FALSE)
# devtools::check_win_devel(email= "claudiozandonella@gmail.com")
# devtools::check_win_release(email= "claudiozandonella@gmail.com")
# devtools::release()

#----    Goodpractice    ----

# g <- goodpractice::gp()
# goodpractice::all_checks()
# goodpractice::gp( checks = "covr")

# spelling::spell_check_package()

#----    covr    ----

# covr::report()
# covr::codecov()
# covr::codecov(token = "549179f1-fef6-4a05-be11-e2b5029df6a0", branch = "develop")

#----    pkgdown    ----

# pkgdown::deploy_to_branch()

#----    paper md    ----

# rmarkdown::render(input = "paper/paper.Rmd",output_format = "html_document",
#                   output_dir = "paper/", clean = FALSE)


#----






