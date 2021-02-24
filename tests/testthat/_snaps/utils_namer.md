# get the correct get_chunk_info

    # A tibble: 7 x 4
      language name     options                       starts
      <chr>    <chr>    <chr>                          <int>
    1 r        setup    ", include=FALSE"                  8
    2 r        cars     ""                                18
    3 r        pressure ", echo=FALSE"                    26
    4 r        <NA>     ", echo=FALSE, warning=FALSE"     32
    5 r        <NA>     ", echo=FALSE"                    36
    6 r        <NA>     ", chunck_name"                   40
    7 sql      <NA>     ", eval=FALSE"                    44

---

    # A tibble: 7 x 4
      language name     options                     starts
      <lgl>    <chr>    <chr>                        <int>
    1 NA       setup    ", include=FALSE"               19
    2 NA       cars     ""                              48
    3 NA       pressure ", echo=FALSE"                  56
    4 NA       <NA>     "echo=FALSE, warning=FALSE"     62
    5 NA       <NA>     "echo=FALSE"                    66
    6 NA       sql      ", eval=FALSE"                  71
    7 NA       <NA>     ""                              75

