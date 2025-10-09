#' Bootstrapping absolute risk differences using G-computation with covariate adjustment
#' @param R number of bootstrap resamples
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`.
#'
#' @import tidyr
#'
#' @export

# Wrapper function for gcomp_boot_func
gcomp_boot <- function(adj.vars = NULL, R = 1000, method = NULL) {
  # Return a partially applied function
  function(data, variable, by, ...) {
    bootgcompr::gcomp_boot_func(data, variable, by, adj.vars = adj.vars, R = R, method = method, ...)
  }
}
