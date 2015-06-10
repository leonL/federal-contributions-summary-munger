FormattedNumberStrAsInteger <- function(str) {
  int <- as.integer(gsub(",", "", str))
  return(int)
}

RemoveYearSuffix <- function(str) {
  s <- trimws(strsplit(str, "/")[[1]][1])
  return(s)
}
