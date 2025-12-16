#' Internal function for setup of footnotes in several footnotes
#'
#' @param tbl a `gtsummary` `tbl_summary()` object
#' @param method_col which method was called
#' @param cols which cols should be modified in the function
#'
#' @importFrom gtsummary modify_footnote_body
#' @importFrom dplyr filter select distinct all_of
#'


add_method_footnotes_body <- function(tbl, method_col = "method",
                                      cols = c("estimate", "conf.low", "conf.high", "p.value")) {
  tb <- tbl$table_body

  # Binary/dichotomous outcomes
  binary_vars <- tb |>
    filter(.data$var_type == "dichotomous") |>
    select(variable, all_of(method_col)) |>
    distinct()

  if (nrow(binary_vars) > 0) {
    for (i in seq_len(nrow(binary_vars))) {
      tbl <- tbl %>%
        gtsummary::modify_footnote_body(
          footnote = binary_vars[[method_col]][i],
          columns = all_of(cols),
          rows = variable == binary_vars$variable[i],
          replace = TRUE
        )
    }
  }

  # Continuous outcomes
  continuous_vars <- tb %>%
    filter(.data$var_type == "continuous") |>
    select(variable, all_of(method_col)) |>
    distinct()

  if (nrow(continuous_vars) > 0) {
    for (i in seq_len(nrow(continuous_vars))) {
      tbl <- tbl %>%
        gtsummary::modify_footnote_body(
          footnote = continuous_vars[[method_col]][i],
          columns = all_of(cols),
          rows = variable == continuous_vars$variable[i],
          replace = TRUE
        )
    }
  }

  tbl
}
