#' Bootstrapping median difference using quantile regression and non-parametric bootstrapping with covariate adjustment
#'
#' @param R number of bootstrap resamples
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`
#'
#' @import tidyr
#'
#' @export

median_diff_boot <- function(adj.vars = NULL, R = 1000) {
  function(data, variable, by, ...) {
    bootgcompr::median_diff_boot_func(
      data = data,
      variable = variable,
      by = by,
      adj.vars = adj.vars,
      R = R,
      ...
    )
  }
}
