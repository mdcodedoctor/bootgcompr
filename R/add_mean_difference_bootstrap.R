#' Function for calculating mean difference by linear regression through non-parametric bootstrapping.
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_summary()` and `bootgcompr`. Uses `mean_diff_tbl()`, `mean_diff_boot()` and `mean_diff_boot_func()` to create a neatly organised calculation of unadjusted or adjusted non-parametric bootstrapped mean difference by linear regression. type of CI pattern can be defined.
#'
#' @param tbl_summary_obj The used table summary object
#' @param adj.vars Covariates used for adjusted analyses. Default = NULL
#' @param R Number of bootstrap resamples. Default = 1000.
#' @param ci_type Define the type of CI method. Possible types are `"bca"`, `"perc"`, `"norm"`, `"basic"`.
#' @param pattern The pattern in which the calculated output is formatted.
#' @param estimate_header Header name for the calculated estimate.
#' @param p_value_header Header name for the calculated p.value
#'
#' @import tidyr
#' @import gtsummary
#'
#' @export
#' @examples
#' # load libraries
#' library(gtsummary)
#' library(bootgcompr)
#'
#' # build `tbl_summary()` with the `add_mean_difference_bootstrap()` function
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
#'  add_mean_difference_bootstrap(adj.vars = c("stage"), R = 1000)

add_mean_difference_bootstrap <- function(tbl_summary_obj,
                                          adj.vars = NULL,
                                          R = 1000,
                                          ci_type = "bca",
                                          pattern = "{estimate} ({conf.low}, {conf.high})",
                                          estimate_header = "**Mean difference** (**95%CI**)",
                                          p_value_header = "**P-value**") {

  # Apply mean_diff_boot() via add_stat()
  tbl_summary_obj <- tbl_summary_obj |>
    gtsummary::add_stat(
      fns = everything() ~ mean_diff_boot(adj.vars = adj.vars, R = R, ci_type = ci_type)
    )

  # Apply mean_diff_tbl() for formatting
  mean_diff_tbl(
    tbl_summary_obj = tbl_summary_obj,
    pattern = pattern,
    estimate_header = estimate_header,
    p_value_header = p_value_header
  )
}
