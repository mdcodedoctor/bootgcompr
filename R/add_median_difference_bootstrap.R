#' Function for calculating ,edoam difference by quantile regression through non-parametric bootstrapping.
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_summary()` and `bootgcompr`. Uses `median_diff_tbl()`, `median_diff_boot()` and `median_diff_boot_func()` to create a neatly organised calculation of unadjusted or adjusted non-parametric bootstrapped mean difference by linear regression. type of CI pattern can be defined.
#'
#' @param tbl_summary_obj The used table summary object
#' @param adj.vars Covariates used for adjusted analyses. Default = NULL
#' @param R Number of bootstrap resamples. Default = 1000.
#' @param pattern The pattern in which the calculated output is formatted.
#' @param estimate_header Header name for the calculated estimate.
#' @param p_value_header Header name for the calculated p.value
#'
#' @import tidyr
#' @import gtsummary
#' @import quantreg
#'
#' @export
#' @examples
#' # load libraries
#' library(gtsummary)
#' library(bootgcompr)
#'
#' # build `tbl_summary()` with the `add_median_difference_bootstrap()` function
#' trial |>
#' tbl_summary(
#'  include = c(response),
#'  by = trt,
#'  statistic = ~ "{mean}",
#'  missing = "no",
#'  type = everything() ~ "continuous",
#'  ) |>
#'  add_overall() |>
#'  add_ci(pattern = "{stat} ({ci})") |>
#'  add_median_difference_bootstrap(adj.vars = c("stage"), R = 1000)

add_median_difference_bootstrap <- function(tbl_summary_obj,
                                            adj.vars = NULL,
                                            R = 1000,
                                            pattern = "{estimate} ({conf.low}, {conf.high})",
                                            estimate_header = "**Median difference** (**95%CI**)",
                                            p_value_header = "**P-value**") {

  # Apply median_diff_boot() via add_stat()
  tbl_summary_obj <- tbl_summary_obj %>%
    gtsummary::add_stat(
      fns = everything() ~ median_diff_boot(adj.vars = adj.vars, R = R)
    )

  # Apply median_diff_tbl() for formatting
  median_diff_tbl(
    tbl_summary_obj = tbl_summary_obj,
    pattern = pattern,
    estimate_header = estimate_header,
    p_value_header = p_value_header
  )
}
