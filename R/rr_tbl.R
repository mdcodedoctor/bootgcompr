#' Wrapper function for easy setup of columns and analysis output when using the `rr_boot` function.
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_summary()` and `bootgcompr` `rr_boot` function. Standard output when using `rr_boot` is not adjusted to the usual `tbl_summary()` output as a custom function is called. This wrapper function cleans up the outputted table and formats it as expected other types of `tbl_summary()` outputs, e.g. when using functions like `add_difference()`.
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
#' # build `tbl_summary()` with the `rr_boot` function
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
#'    fns = everything() ~ rr_boot(adj.vars = c("stage"), R = 1000)) |>
#'  rr_tbl()

# Easy wrapper function for modify_column_merge and modify_header
rr_tbl <- function(tbl_summary_obj,
                    pattern = "{estimate} ({conf.low}, {conf.high})",
                    estimate_header = "RR (95%CI)",
                    p_value_header = "P-value") {
  tbl_summary_obj |>
    gtsummary::modify_column_hide(columns = c("method")) |>
    gtsummary::modify_column_merge(pattern = pattern) |>
    gtsummary::modify_header(estimate = estimate_header, p.value = p_value_header) |>
    gtsummary::modify_footnote_header(
      "Relative Risk estimated by non-parametric bootstrapped logistic regression",
      columns = c(p.value)
    )
}

