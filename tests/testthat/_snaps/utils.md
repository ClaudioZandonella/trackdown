# Message function work prorerly

    -- horizontal line -------------------------------------------------------------
     

---

    <ansi_string>
    [1] blue text

---

    * a colored bulled item

---

    v a ticked item

# Message function work prorerly bullet

    Code
      sub_process("a bullet item")
    Message <cliMessage>
      * a bullet item

# check get_instructions

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                                  
    [2] "This is not a common Document. The Document includes properly formatted Markdown syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Please do not remove placeholders of type \"[[chunk-<name>]]\" or \"[[document-header]]\""                                                                                                                                                         
    [4] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                        
    [5] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                               
    [6] "FILE-NAME: example_1.Rmd"                                                                                                                                                                                                                          
    [7] "HIDE-CODE: TRUE"                                                                                                                                                                                                                                   
    [8] "#----End Instructions----#"                                                                                                                                                                                                                        

---

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                                  
    [2] "This is not a common Document. The Document includes properly formatted Markdown syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                        
    [4] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                               
    [5] "FILE-NAME: example_1.Rmd"                                                                                                                                                                                                                          
    [6] "HIDE-CODE: FALSE"                                                                                                                                                                                                                                  
    [7] "#----End Instructions----#"                                                                                                                                                                                                                        

---

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                               
    [2] "This is not a common Document. The Document includes properly formatted LaTeX syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Please do not remove placeholders of type \"[[chunk-<name>]]\" or \"[[document-header]]\""                                                                                                                                                      
    [4] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                     
    [5] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                            
    [6] "FILE-NAME: example_1.Rnw"                                                                                                                                                                                                                       
    [7] "HIDE-CODE: TRUE"                                                                                                                                                                                                                                
    [8] "#----End Instructions----#"                                                                                                                                                                                                                     

---

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                               
    [2] "This is not a common Document. The Document includes properly formatted LaTeX syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                     
    [4] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                            
    [5] "FILE-NAME: example_1.Rnw"                                                                                                                                                                                                                       
    [6] "HIDE-CODE: FALSE"                                                                                                                                                                                                                               
    [7] "#----End Instructions----#"                                                                                                                                                                                                                     

# check format_document

    [1] "#----Trackdown Instructions----#\nThis is not a common Document. The Document includes properly formatted Markdown syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code.\nOnce the review is over accept all changes: Tools -> Review suggested edits -> Accept all.\nYou must not modify or remove these lines, we will do it for you ;)\nFILE-NAME: example_1.Rmd\nHIDE-CODE: FALSE\n#----End Instructions----#\n---\ntitle: \"Reviewdown Test\"\nauthor: \"reviewdown\"\ndate: \"2/3/2021\"\noutput: html_document\n---\n\n```{r setup, include=FALSE}\nknitr::opts_chunk$set(echo = TRUE)\n```\n\n## R Markdown\n\nThis is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.\n\nWhen you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:\n\n```{r cars}\nsummary(cars)\n```\n\n## Including Plots\n\nYou can also embed plots, for example:\n\n```{r, pressure, echo=FALSE}\nplot(pressure)\n```\n\nNote that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.\n\n```{r, echo=FALSE, warning=FALSE}\n# R chunk with no name but multiple options (using ,)\n```\n\n```{r echo=FALSE}\n# R chunk with no name but options (not using,)\n```\n\n```{r, chunk_name}\n# wrong R chunk with , and name is parsed as argument\n```\n\n```{sql, eval=FALSE}\n/*A sql chunk chunk with no name but options*/\n```\n\n```{eval = TRUE}\nA void code\n```\n\n```{}\nAnother void code\n```\n\n```\nStill another void code\n```\n\n```a really strange inline block ```\n\nEnd of the document\n"

---

    [1] "#----Trackdown Instructions----#\nThis is not a common Document. The Document includes properly formatted Markdown syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code.\nPlease do not remove placeholders of type \"[[chunk-<name>]]\" or \"[[document-header]]\"\nOnce the review is over accept all changes: Tools -> Review suggested edits -> Accept all.\nYou must not modify or remove these lines, we will do it for you ;)\nFILE-NAME: example_1.Rmd\nHIDE-CODE: TRUE\n#----End Instructions----#\n---\ntitle: \"Reviewdown Test\"\nauthor: \"reviewdown\"\ndate: \"2/3/2021\"\noutput: html_document\n---\n\n```{r setup, include=FALSE}\nknitr::opts_chunk$set(echo = TRUE)\n```\n\n## R Markdown\n\nThis is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.\n\nWhen you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:\n\n```{r cars}\nsummary(cars)\n```\n\n## Including Plots\n\nYou can also embed plots, for example:\n\n```{r, pressure, echo=FALSE}\nplot(pressure)\n```\n\nNote that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.\n\n```{r, echo=FALSE, warning=FALSE}\n# R chunk with no name but multiple options (using ,)\n```\n\n```{r echo=FALSE}\n# R chunk with no name but options (not using,)\n```\n\n```{r, chunk_name}\n# wrong R chunk with , and name is parsed as argument\n```\n\n```{sql, eval=FALSE}\n/*A sql chunk chunk with no name but options*/\n```\n\n```{eval = TRUE}\nA void code\n```\n\n```{}\nAnother void code\n```\n\n```\nStill another void code\n```\n\n```a really strange inline block ```\n\nEnd of the document\n"

# check eval_instructions full file

    $start
    [1] 1
    
    $end
    [1] 8
    
    $file_name
    [1] "example_1.Rmd"
    
    $hide_code
    [1] TRUE
    

# check eval_instructions no instructions

    $start
    NULL
    
    $end
    NULL
    
    $file_name
    [1] "example_1.Rmd"
    
    $hide_code
    [1] TRUE
    

---

    $start
    NULL
    
    $end
    NULL
    
    $file_name
    [1] "example_1.Rmd"
    
    $hide_code
    [1] TRUE
    

# check eval_instructions no file_name

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    NULL
    
    $hide_code
    [1] TRUE
    

---

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    [1] "example_instructions.txt"
    
    $hide_code
    [1] TRUE
    

# check eval_instructions no hide_code

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    [1] "example_1.Rmd"
    
    $hide_code
    [1] TRUE
    

---

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    [1] "example_1.Rmd"
    
    $hide_code
    [1] TRUE
    

---

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    [1] "example_1.Rmd"
    
    $hide_code
    [1] FALSE
    

