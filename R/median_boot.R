#' Descriptive summary bootstrapped median (95%CI)
#'
#' @param R number of resamples (if not defined, the custom 1000 resamples are used)
#' @description
#' Function used in conjunction with `gtsummary` `tbl_custom_summary()`. Set `stat_fns = var ~ median_boot(R = )` and define number of resamples in the R call (E.g. `R = 10000`). Remember to define the `statistic =` argument as `{median} ({conf.low}, {conf.high})` inside `tbl_custom_summary()`.
#'
#' @import tidyr
#'
#' @export
#'
#' @examples
#' # load librarires
#' library(gtsummary)
#' library(bootgcompr)
#'
#' # build `tbl_custom_summary()` with the `median_boot` function
#' trial |>
#' tbl_custom_summary(
#'  include = c(ttdeath, marker),
#'  by = trt,
#'  statistic = ~ "{median} ({conf.low}, {conf.high})",
#'  stat_fns = everything() ~ median_boot(),
#'  missing = "no",
#'  type = everything() ~ "continuous"
#'  ) |>
#'  add_overall()

median_boot <- function(R = 1000) {
  function(data, variable, ...) {
    bootgcompr::median_boot_func(data, variable, R = R, ...)
  }
}
