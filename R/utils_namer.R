###############################
####    Namer Utilities    ####
###############################


#  Utility from namer R-package https://github.com/lockedata/namer

#----    quote_label    ----

# function from knitr r-package
# https://github.com/yihui/knitr/blob/2b3e617a700f6d236e22873cfff6cbc3568df568/R/parser.R#L148

# quote the chunk label if necessary

quote_label = function(x) {
  x = gsub('^\\s*,?', '', x)
  if (grepl('^\\s*[^\'"](,|\\s*$)', x)) {
    # <<a,b=1>>= ---> <<'a',b=1>>=
    x = gsub('^\\s*([^\'"])(,|\\s*$)', "'\\1'\\2", x)
  } else if (grepl('^\\s*[^\'"](,|[^=]*(,|\\s*$))', x)) {
    # <<abc,b=1>>= ---> <<'abc',b=1>>=
    x = gsub('^\\s*([^\'"][^=]*)(,|\\s*$)', "'\\1'\\2", x)
  }
  x
}

#----    get_chunk_info    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L72

# helper to create a data.frame of chunk info

get_chunk_info <- function(lines){
  # find which lines are chunk starts
  chunk_header_indices <- which(grepl("^```\\{[a-zA-Z0-9]", lines))

  # null if no chunks
  if(length(chunk_header_indices) == 0){
    return(NULL)
  }
  # parse these chunk headers
  purrr::map_df(chunk_header_indices,
                digest_chunk_header,
                lines)
}

#----    parse_chunk_header    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L35

# from a chunk header to a tibble with language, name, option, option values

parse_chunk_header <- function(chunk_header){
  # remove boundaries
  chunk_header <- gsub("```\\{", "", chunk_header)
  chunk_header <- gsub("\\}", "", chunk_header)

  # parse each part
  transform_params(chunk_header)

}

#----    digest_chunk_header    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L45

digest_chunk_header <- function(chunk_header_index,
                                lines){
  # parse the chunk header
  chunk_info <- parse_chunk_header(
    lines[chunk_header_index])


  # keep index
  chunk_info$starts <- chunk_header_index

  chunk_info
}

#----    transform_params    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L3

# not elegant, given a part of a header,
# transform it into the row of a tibble
transform_params <- function(params){
  params_string <- try(eval(parse(text = paste('alist(', quote_label(params), ')'))),
                       silent = TRUE)

  if(inherits(params_string, "try-error")){
    params <- sub(" ", ", ", params)
    params_string <- eval(parse(text = paste('alist(', quote_label(params), ')')))
  }

  label <- parse_label(params_string[[1]])

  tibble::tibble(language = label$language,
                 name = label$name,
                 options = sub(params_string[[1]], "", params))
}

#----    parse_label    ----

# function from namer r-package
# https://github.com/lockedata/namer/blob/master/R/utils.R#L20

parse_label <- function(label){
  language_name <- sub(" ", "\\/", label)
  language_name <- unlist(strsplit(language_name, "\\/"))

  if(length(language_name) == 1){
    tibble::tibble(language = trimws(language_name[1]),
                   name = NA)
  }else{
    tibble::tibble(language = trimws(language_name[1]),
                   name = trimws(language_name[2]))
  }
}
