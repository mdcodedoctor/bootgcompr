#' Descriptive summary bootstrapped mean (95%CI)
#'
#' @param R number of resamples (if not defined, the custom 1000 resamples are used)
#' @description
#' Function used in conjunction with `gtsummary` `tbl_custom_summary()`. Set `stat_fns = var ~ mean_boot(R = )` and define number of resamples in the R call (E.g. `R = 10000`). Remember to define the `statistic =` argument as `{mean} ({conf.low}, {conf.high})` inside `tbl_custom_summary()`.
#'
#' @export
#'
#' @examples
#' # load librarires
#' library(gtsummary)
#' library(bootgcompr)
#'
#' # build `tbl_custom_summary()` with the `mean_boot` function
#' trial |>
#' tbl_custom_summary(
#'  include = c(ttdeath, marker),
#'  by = trt,
#'  statistic = ~ "{mean} ({conf.low}, {conf.high})",
#'  stat_fns = everything() ~ mean_boot(),
#'  missing = "no",
#'  type = everything() ~ "continuous"
#'  ) |>
#'  add_overall()

# wrapper function for using with `fns =` argument in `tbl_summary()`
mean_boot <- function(R = 1000) {
  function(data, variable, ...) {
    bootgcompr::mean_boot_func(data, variable, R = R, ...)
  }
}
