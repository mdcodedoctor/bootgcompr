#' Bootstrapping absolute risk differences using G-computation with covariate adjustment
#' @param R number of bootstrap resamples
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`.
#' @param ci_type Chosen type of CI calculation. Choose between `"bca"`, `"perc"`, `"norm"` or `"basic"`.
#' @param percentage Defines whether to convert estimates and CI to percentage or not. or `"poisson"`.
#'
#' @export

# wrapper function for gcomp_boot_func
gcomp_boot <- function(adj.vars = NULL, R = 1000, ci_type = "bca", percentage = FALSE) {
  force(adj.vars); force(R); force(ci_type); force(percentage)

  function(data, variable, by, ...) {
    res <- bootgcompr::gcomp_boot_func(
      data = data,
      variable = variable,
      by = by,
      adj.vars = adj.vars,
      R = R,
      ci_type = ci_type,
      ...
    )

    if (percentage) {
      res <- dplyr::mutate(res,
                           estimate = estimate * 100,
                           std.error = std.error * 100,
                           conf.low = conf.low * 100,
                           conf.high = conf.high * 100)
    }
    res
  }
}

