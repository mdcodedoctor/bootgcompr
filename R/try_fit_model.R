#' Helper function for the `gcomp_boot()` function.
#'
#' @description
#' Function used through the `gcomp_boot()` function to evaluate whether the model can be fitted correctly.
#'
#' @param data data passed from `gcomp_boot()` through `tbl_summary()` or `tbl_custom_summary()`
#' @param formula formula passed from `gcomp_boot()` through `tbl_summary()` or `tbl_custom_summary()`
#' @param method set by `gcomp_boot()` function for either "glm", "logistf" or "poisson"
#'
#' @importFrom stats glm binomial poisson
#' @importFrom logistf logistf
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
