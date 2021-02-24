# get the correct extract_chunk

    # A tibble: 10 x 8
       language name   options     starts  ends index chunk_text           name_tag 
       <chr>    <chr>  <chr>        <int> <int> <int> <chr>                <chr>    
     1 r        setup  ", include~      8    10     1 "```{r setup, inclu~ [[chunk-~
     2 r        cars   ""              18    20     2 "```{r cars}\nsumma~ [[chunk-~
     3 r        press~ ", echo=FA~     26    28     3 "```{r, pressure, e~ [[chunk-~
     4 r        <NA>   ", echo=FA~     32    34     4 "```{r, echo=FALSE,~ [[chunk-~
     5 r        <NA>   ", echo=FA~     36    38     5 "```{r echo=FALSE}\~ [[chunk-~
     6 r        chunk~ ""              40    42     6 "```{r, chunk_name}~ [[chunk-~
     7 sql      <NA>   ", eval=FA~     44    46     7 "```{sql, eval=FALS~ [[chunk-~
     8 <NA>     <NA>   "eval = TR~     48    50     8 "```{eval = TRUE}\n~ [[chunk-~
     9 <NA>     <NA>   ""              52    54     9 "```{}\nAnother voi~ [[chunk-~
    10 <NA>     <NA>   ""              56    58    10 "```\nStill another~ [[chunk-~

---

    # A tibble: 7 x 8
      language name   options     starts  ends index chunk_text            name_tag 
      <lgl>    <chr>  <chr>        <int> <int> <int> <chr>                 <chr>    
    1 NA       setup  ", include~     19    21     1 "<<setup, include=FA~ [[chunk-~
    2 NA       cars   ""              48    50     2 "<<cars>>=\nsummary(~ [[chunk-~
    3 NA       press~ ", echo=FA~     56    58     3 "<<pressure, echo=FA~ [[chunk-~
    4 NA       <NA>   "echo=FALS~     62    64     4 "<<echo=FALSE, warni~ [[chunk-~
    5 NA       <NA>   "echo=FALS~     66    68     5 "<<echo=FALSE>>= # a~ [[chunk-~
    6 NA       sql    ", eval=FA~     71    73     6 "<<sql, eval=FALSE>>~ [[chunk-~
    7 NA       <NA>   ""              75    77     7 "<<>>=\n# A void cod~ [[chunk-~

