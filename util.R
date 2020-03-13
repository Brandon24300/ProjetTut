
installPackages <- function(packages){
  #packages <- c("xml2", "RCurl", "RSQLite")
  if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))  
  }
}

loadPackages <- function(packages){
  options(defaultPackages=c(getOption("defaultPackages"),
                            packages))
}


Unaccent <- function(text) {
  text <- gsub("[`^~\"-]", " ", text)
  text <- gsub("[ιθ]", "e", text)
  text <- gsub("[τ]", "o", text)
  text <- iconv(text, to="ASCII//TRANSLIT//IGNORE")
  text <- gsub("[`^~\"-]", "", text)
  return(text)
}

is_empty <- function(x, first.only = TRUE, all.na.empty = TRUE) {
  # do we have a valid vector?
  if (!is.null(x)) {
    # if it's a character, check if we have only one element in that vector
    if (is.character(x)) {
      # characters may also be of length 0
      if (length(x) == 0) return(TRUE)
      # else, check all elements of x
      zero_len <- nchar(x) == 0
      # return result for multiple elements of character vector
      if (first.only) {
        zero_len <- .is_true(zero_len[1])
        if (length(x) > 0) x <- x[1]
      } else {
        return(unname(zero_len))
      }
      # we have a non-character vector here. check for length
    } else if (is.list(x)) {
      x <- purrr::compact(x)
      zero_len <- length(x) == 0
    } else {
      zero_len <- length(x) == 0
    }
  }
  
  any(is.null(x) || zero_len || (all.na.empty && all(is.na(x))))
}


.is_true <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x) && x
}
