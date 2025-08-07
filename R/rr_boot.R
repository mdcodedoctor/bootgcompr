#' Bootstrapping relative risk/risk ratio using logistic regression and non-parametric bootstrapping with covariate adjustment
#'
#' @param R number of bootstrap resamples
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`
#' @export

# wrapper function for using with fns = argument in add_stat()
rr_boot <- function(adj.vars = NULL, R = 1000) {
  function(data, variable, by, ...) {
    bootgcompr::rr_boot_func(data, variable, by, adj.vars = adj.vars, R = R, ...)
  }
}
