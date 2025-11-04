#' Wrapper function for easy setup of columns and analysis output when using the `gcomp_boot` function.
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_summary()` and `bootgcompr` `gcomp_boot` function. Standard output when using `gcomp_boot` is not adjusted to the usual `tbl_summary()` output as a custom function is called. This wrapper function cleans up the outputted table and formats it as expected other types of `tbl_summary()` outputs, e.g. when using functions like `add_difference()`.
#'
#' @param tbl_summary_obj The used table summary object (e.g. `tbl_summary()`)
#' @param pattern The pattern in which the calculated output is formatted
#' @param estimate_header Header name for the calculated estimate.
#' @param p_value_header Header name for the calculated p.value
#'
#' @importFrom gtsummary modify_column_hide modify_column_merge modify_header modify_footnote_header
#'
#' @export
#' @examples
#' # load librarires
#' library(gtsummary)
#' library(bootgcompr)
#'
#' # build `tbl_summary()` with the `gcomp_boot` function
#' trial |>
#' tbl_summary(
#'  include = c(response),
#'  by = trt,
#'  statistic = ~ "{p}%",
#'  missing = "no",
#'  type = everything() ~ "dichotomous",
#'  ) |>
#'  add_overall() |>
#'  add_ci(
#'    pattern = "{stat} ({ci})") |>
#'  add_stat(
#'    fns = everything() ~ gcomp_boot(adj.vars = c("stage"), R = 1000)) |>
#'  gcomp_tbl()


# Easy wrapper function for modify_column_merge and modify_header
gcomp_tbl <- function(tbl_summary_obj,
                      pattern = "{estimate}% ({conf.low}%, {conf.high}%)",
                      estimate_header = "**ARDifference** (95%CI)",
                      p_value_header = "**P-value**") {
  tbl_summary_obj |>
    gtsummary::modify_column_hide(columns = c("std.error", "method")) |>
    gtsummary::modify_column_merge(pattern = pattern) |>
    gtsummary::modify_header(estimate = estimate_header, p.value = p_value_header) |>
    gtsummary::modify_footnote_header(
      "Absolute Risk Difference estimated by bootstrapped G-Computation",
      columns = c(p.value))
}
