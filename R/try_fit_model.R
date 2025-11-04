#' G-computation using bootstrapping with covariate adjustment
#'
#' @description
#' Function used through the `gcomp_boot()` function to evaluate whether the model can be fitted correctly.
#'
#' @param data A dataframe passed from `gcomp_boot()` and `tbl_summary()`
#' @param variable Inputted variable from the `tbl_summary(include = c())` argument. Variables are best handled as integers of 0 or 1, where 1 depicts that the outcome happened and 0 depicts that the outcome didn't happen.
#' @param by Passed stratification/grouping variable from `tbl_summary(by = )` argument. Should accept both integers (0 vs. 1) or factors with at least 2 levels.
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`
#' @param R number of bootstrap resamples
#' @param ... Placeholder accepting further inputs from `tbl_summary()`
#'
#' @import dplyr
#' @import tidyr
#' @import logistf
#' @importFrom stats as.formula
#' @importFrom stats binomial
#' @importFrom stats glm
#' @importFrom stats predict
#' @importFrom stats quantile
#' @importFrom stats sd
#' @importFrom rlang sym
#' @importFrom data.table :=
#'
#' @export



try_fit_model <- function(formula, data, method = "glm") {
  tryCatch({
    if (method == "glm") {
      model <- glm(formula, data = data, family = binomial)
    } else if (method == "logistf") {
      model <- logistf::logistf(formula, data = data)
    } else if (method == "log_binomial") {
      # Log-binomial model (may not converge)
      model <- glm(formula, data = data, family = binomial(link = "log"))
    } else if (method == "poisson") {
      # Poisson regression with robust variance
      model <- glm(formula, data = data, family = poisson)
    } else {
      stop("Unknown method")
    }
    return(model)
  }, error = function(e) {
    return(NULL)
  })
}
