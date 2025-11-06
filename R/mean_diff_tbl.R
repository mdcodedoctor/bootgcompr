#' Wrapper function for easy setup of columns and analysis output when using the `mean_diff_boot` function.
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_summary()` and `bootgcompr` `mean_diff_boot` function. Standard output when using `mean_diff_boot` is not adjusted to the usual `tbl_summary()` output as a custom function is called. This wrapper function cleans up the outputted table and formats it as expected other types of `tbl_summary()` outputs, e.g. when using functions like `add_difference()`.
#'
#' @param tbl_summary_obj The used table summary object (e.g. `tbl_summary()`)
#' @param pattern The pattern in which the calculated output is formatted
#' @param estimate_header Header name for the calculated estimate.
#' @param p_value_header Header name for the calculated p.value
#'
#' @import tidyr
#' @import gtsummary
#'
#' @export
#' @examples
#' # load librarires
#' library(gtsummary)
#' library(bootgcompr)
#'
#' # build `tbl_summary()` with the `mean_diff_boot` function
#' trial |>
#' tbl_summary(
#'  include = c(response),
#'  by = trt,
#'  statistic = ~ "{mean}",
#'  missing = "no",
#'  type = everything() ~ "continuous",
#'  ) |>
#'  add_overall() |>
#'  add_ci(
#'    pattern = "{stat} ({ci})") |>
#'  add_stat(
#'    fns = everything() ~ mean_diff_boot(adj.vars = c("stage"), R = 1000)) |>
#'  mean_diff_tbl()

# Easy wrapper function for modify_column_merge and modify_header
mean_diff_tbl <- function(tbl_summary_obj,
                   pattern = "{estimate} ({conf.low}, {conf.high})",
                   estimate_header = "**Mean difference** (**95%CI**)",
                   p_value_header = "**P-value**") {

  method_value <- tbl_summary_obj$table_body$method[1]

  tbl_summary_obj |>
    gtsummary::modify_column_hide(columns = c("method", "std.error")) |>
    gtsummary::modify_column_merge(pattern = pattern) |>
    gtsummary::modify_header(estimate = estimate_header, p.value = p_value_header) |>
    gtsummary::modify_footnote_header(
      method_value,
      columns = c(estimate, p.value)
    )
}
