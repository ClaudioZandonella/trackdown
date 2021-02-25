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

# get the correct extract_header

    # A tibble: 1 x 4
      starts  ends header_text                                        name_tag      
       <int> <int> <chr>                                              <chr>         
    1      1     6 "---\ntitle: \"Reviewdown Test\"\nauthor: \"revie~ [[document-he~

---

    # A tibble: 1 x 4
      starts  ends header_text                                        name_tag      
       <int> <int> <chr>                                              <chr>         
    1      3    29 "\\documentclass{article}  \n\\usepackage[T1] {fo~ [[document-he~

# get the correct hide_code

     [1] "[[document-header]]"                                                                                                                                                                                         
     [2] ""                                                                                                                                                                                                            
     [3] "[[chunk-setup]]"                                                                                                                                                                                             
     [4] ""                                                                                                                                                                                                            
     [5] "## R Markdown"                                                                                                                                                                                               
     [6] ""                                                                                                                                                                                                            
     [7] "This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>."             
     [8] ""                                                                                                                                                                                                            
     [9] "When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:"
    [10] ""                                                                                                                                                                                                            
    [11] "[[chunk-cars]]"                                                                                                                                                                                              
    [12] ""                                                                                                                                                                                                            
    [13] "## Including Plots"                                                                                                                                                                                          
    [14] ""                                                                                                                                                                                                            
    [15] "You can also embed plots, for example:"                                                                                                                                                                      
    [16] ""                                                                                                                                                                                                            
    [17] "[[chunk-pressure]]"                                                                                                                                                                                          
    [18] ""                                                                                                                                                                                                            
    [19] "Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot."                                                                               
    [20] ""                                                                                                                                                                                                            
    [21] "[[chunk-4]]"                                                                                                                                                                                                 
    [22] ""                                                                                                                                                                                                            
    [23] "[[chunk-5]]"                                                                                                                                                                                                 
    [24] ""                                                                                                                                                                                                            
    [25] "[[chunk-chunk-name]]"                                                                                                                                                                                        
    [26] ""                                                                                                                                                                                                            
    [27] "[[chunk-7]]"                                                                                                                                                                                                 
    [28] ""                                                                                                                                                                                                            
    [29] "[[chunk-8]]"                                                                                                                                                                                                 
    [30] ""                                                                                                                                                                                                            
    [31] "[[chunk-9]]"                                                                                                                                                                                                 
    [32] ""                                                                                                                                                                                                            
    [33] "[[chunk-10]]"                                                                                                                                                                                                
    [34] ""                                                                                                                                                                                                            
    [35] "```a really strange inline block ```"                                                                                                                                                                        
    [36] ""                                                                                                                                                                                                            
    [37] "End of the document"                                                                                                                                                                                         

---

     [1] ""                                                                                                                                                                                                            
     [2] "%----    Basic packages    ----%"                                                                                                                                                                            
     [3] "[[document-header]]"                                                                                                                                                                                         
     [4] ""                                                                                                                                                                                                            
     [5] "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"                                                                                                                        
     [6] "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         Title           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%"                                                                                                                        
     [7] "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"                                                                                                                        
     [8] ""                                                                                                                                                                                                            
     [9] "\\maketitle"                                                                                                                                                                                                 
    [10] ""                                                                                                                                                                                                            
    [11] "%----------------------------------------------------------------------------------%"                                                                                                                        
    [12] "%--------------------------         Introduction         --------------------------%"                                                                                                                        
    [13] "%----------------------------------------------------------------------------------%"                                                                                                                        
    [14] ""                                                                                                                                                                                                            
    [15] ""                                                                                                                                                                                                            
    [16] "\\section{R and \\LaTeX}"                                                                                                                                                                                    
    [17] ""                                                                                                                                                                                                            
    [18] "This is an Rnw document. \\LaTeX is a (\\textit{not so}) simple formatting syntax for authoring PDF documents. For more details on using \\LaTeX see \\url{https://www.overleaf.com/learn}."                 
    [19] ""                                                                                                                                                                                                            
    [20] "When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:"
    [21] ""                                                                                                                                                                                                            
    [22] "[[chunk-cars]]"                                                                                                                                                                                              
    [23] ""                                                                                                                                                                                                            
    [24] "\\section{Including Plots}"                                                                                                                                                                                  
    [25] ""                                                                                                                                                                                                            
    [26] "You can also embed plots, for example:"                                                                                                                                                                      
    [27] ""                                                                                                                                                                                                            
    [28] "[[chunk-pressure]]"                                                                                                                                                                                          
    [29] ""                                                                                                                                                                                                            
    [30] "Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot."                                                                               
    [31] ""                                                                                                                                                                                                            
    [32] "[[chunk-4]]"                                                                                                                                                                                                 
    [33] ""                                                                                                                                                                                                            
    [34] "[[chunk-5]]"                                                                                                                                                                                                 
    [35] ""                                                                                                                                                                                                            
    [36] ""                                                                                                                                                                                                            
    [37] "[[chunk-sql]]"                                                                                                                                                                                               
    [38] ""                                                                                                                                                                                                            
    [39] "[[chunk-7]]"                                                                                                                                                                                                 
    [40] ""                                                                                                                                                                                                            
    [41] "End of the document"                                                                                                                                                                                         
    [42] ""                                                                                                                                                                                                            
    [43] "\\end{document}"                                                                                                                                                                                             

