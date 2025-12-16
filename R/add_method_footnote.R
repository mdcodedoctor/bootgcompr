#' Internal function for setup of footnotes in a single footnote
#'
#' @param tbl a `gtsummary` `tbl_summary()` object
#'
#' @importFrom gtsummary modify_footnote_header
#'


add_method_footnote <- function(tbl) {
  if (!"method" %in% names(tbl$table_body)) {
    stop("No 'method' column found in the table_body.")
  }
  footnote_text <- tbl$table_body$method |> unique() |> na.omit() |> paste(collapse = "; ")
  gtsummary::modify_footnote_header(
    tbl,
    footnote = footnote_text,
    columns = c("estimate", "p.value")
  )
}
