# get the correct get_chunk_info

    # A tibble: 10 x 5
       language name        options                       starts  ends
       <chr>    <chr>       <chr>                          <int> <int>
     1 r        setup       ", include=FALSE"                  8    10
     2 r        cars        ""                                18    20
     3 r        pressure    ", echo=FALSE"                    26    28
     4 r        <NA>        ", echo=FALSE, warning=FALSE"     32    34
     5 r        <NA>        ", echo=FALSE"                    36    38
     6 r        chunck_name ""                                40    42
     7 sql      <NA>        ", eval=FALSE"                    44    46
     8 <NA>     <NA>        "eval = TRUE"                     48    50
     9 <NA>     <NA>        ""                                52    54
    10 <NA>     <NA>        ""                                56    58

---

    # A tibble: 7 x 5
      language name     options                     starts  ends
      <lgl>    <chr>    <chr>                        <int> <int>
    1 NA       setup    ", include=FALSE"               19    21
    2 NA       cars     ""                              48    50
    3 NA       pressure ", echo=FALSE"                  56    58
    4 NA       <NA>     "echo=FALSE, warning=FALSE"     62    64
    5 NA       <NA>     "echo=FALSE"                    66    68
    6 NA       sql      ", eval=FALSE"                  71    73
    7 NA       <NA>     ""                              75    77

