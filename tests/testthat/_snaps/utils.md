# Message function work prorerly

    -- horizontal line -------------------------------------------------------------
     

---

    <ansi_string>
    [1] blue text

---

    * a colored bulled item

---

    v a ticked item

# Message function work properly bullet

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
    [6] "FILE-NAME: new-file.Rmd"                                                                                                                                                                                                                           
    [7] "HIDE-CODE: TRUE"                                                                                                                                                                                                                                   
    [8] "#----End Instructions----#"                                                                                                                                                                                                                        

---

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                                  
    [2] "This is not a common Document. The Document includes properly formatted Markdown syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                        
    [4] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                               
    [5] "FILE-NAME: new-file.Rmd"                                                                                                                                                                                                                           
    [6] "HIDE-CODE: FALSE"                                                                                                                                                                                                                                  
    [7] "#----End Instructions----#"                                                                                                                                                                                                                        

---

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                               
    [2] "This is not a common Document. The Document includes properly formatted LaTeX syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Please do not remove placeholders of type \"[[chunk-<name>]]\" or \"[[document-header]]\""                                                                                                                                                      
    [4] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                     
    [5] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                            
    [6] "FILE-NAME: new-file.Rnw"                                                                                                                                                                                                                        
    [7] "HIDE-CODE: TRUE"                                                                                                                                                                                                                                
    [8] "#----End Instructions----#"                                                                                                                                                                                                                     

---

    [1] "#----Trackdown Instructions----#"                                                                                                                                                                                                               
    [2] "This is not a common Document. The Document includes properly formatted LaTeX syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code."
    [3] "Once the review is over accept all changes: Tools -> Review suggested edits -> Accept all."                                                                                                                                                     
    [4] "You must not modify or remove these lines, we will do it for you ;)"                                                                                                                                                                            
    [5] "FILE-NAME: new-file.Rnw"                                                                                                                                                                                                                        
    [6] "HIDE-CODE: FALSE"                                                                                                                                                                                                                               
    [7] "#----End Instructions----#"                                                                                                                                                                                                                     

# check format_document

    [1] "#----Trackdown Instructions----#\nThis is not a common Document. The Document includes properly formatted Markdown syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code.\nOnce the review is over accept all changes: Tools -> Review suggested edits -> Accept all.\nYou must not modify or remove these lines, we will do it for you ;)\nFILE-NAME: example-1.Rmd\nHIDE-CODE: FALSE\n#----End Instructions----#\n---\ntitle: \"Reviewdown Test\"\nauthor: \"reviewdown\"\ndate: \"2/3/2021\"\noutput: html_document\n---\n\n```{r setup, include=FALSE}\nknitr::opts_chunk$set(echo = TRUE)\n```\n\n## R Markdown\n\nThis is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.\n\n```{r cars}\nsummary(cars)\n```\n"

---

    [1] "#----Trackdown Instructions----#\nThis is not a common Document. The Document includes properly formatted LaTeX syntax and R code. Please be aware and responsible in making corrections as you could break the code. Limit changes to narrative text and avoid modifying R code.\nPlease do not remove placeholders of type \"[[chunk-<name>]]\" or \"[[document-header]]\"\nOnce the review is over accept all changes: Tools -> Review suggested edits -> Accept all.\nYou must not modify or remove these lines, we will do it for you ;)\nFILE-NAME: example-1.Rnw\nHIDE-CODE: TRUE\n#----End Instructions----#\n\n%----    Basic packages    ----%\n\\documentclass{article}  \n\n\\usepackage{hyperref}\n\n%----    Settings    ----%\n\n<<setup, include=FALSE>>=\nknitr::opts_chunk$set(echo = TRUE)\n@\n\n% Document title info\n\\title{Reviewdown Test}\n\\author{reviewdown}\n% \\date{}\n\\begin{document}\n\n%----    Title    ----%\n\n\\maketitle\n\n\\section{R and \\LaTeX}\n\nThis is an Rnw document. \\LaTeX is a (\\textit{not so}) simple formatting syntax for authoring PDF documents. For more details on using \\LaTeX see \\url{https://www.overleaf.com/learn}.\n\n<<cars>>=\nsummary(cars)\n@\n\n\\end{document}\n"

# check eval_instructions full file

    $start
    [1] 1
    
    $end
    [1] 8
    
    $file_name
    [1] "example-1.Rmd"
    
    $hide_code
    [1] TRUE
    

# check eval_instructions no instructions

    $start
    NULL
    
    $end
    NULL
    
    $file_name
    [1] "example-1.Rmd"
    
    $hide_code
    [1] TRUE
    

---

    $start
    NULL
    
    $end
    NULL
    
    $file_name
    [1] "example-1.Rmd"
    
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
    [1] "example-1.Rmd"
    
    $hide_code
    [1] TRUE
    

---

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    [1] "example-1.Rmd"
    
    $hide_code
    [1] TRUE
    

---

    $start
    [1] 1
    
    $end
    [1] 7
    
    $file_name
    [1] "example-1.Rmd"
    
    $hide_code
    [1] TRUE
    

