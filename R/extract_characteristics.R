#' Extract sample characteristics into separate columns
#'
#' Parses a character vector containing sample characteristics in
#' `"key: value"` format and converts the characteristics into a
#' one-row data frame. Each characteristic key becomes a column name
#' and its corresponding value becomes the column value.
#'
#' @param x A character vector containing sample characteristics in
#'   `"key: value"` format.
#'
#' @return A data frame containing the extracted characteristics as
#'   separate columns. Returns an empty data frame if \code{x} is empty
#'   or contains only missing values.
#'
#' @examples
#' \dontrun{
#' characteristics <- c(
#'   "cell type: HeLa",
#'   "treatment: control",
#'   "time: 24 hours"
#' )
#'
#' extract_characteristics(characteristics)
#' }
#'
#' @export



extract_characteristics <- function(x){

  if(length(x) == 0 || all(is.na(x)))
    return(data.frame())

  vals <- strsplit(x, ": ")

  keys <- sapply(vals, `[`, 1)

  values <- sapply(vals, function(y){

    if(length(y) >= 2)
      paste(y[-1], collapse=": ")
    else
      ""

  })

  out <- as.data.frame(as.list(values),
                       stringsAsFactors = FALSE)

  names(out) <- make.names(keys)

  out

}
