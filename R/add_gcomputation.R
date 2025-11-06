#' Add Generalized Computation to a gtsummary Table
#'
#' @description
#' Function for computation of estimated Average Treatment Effect (ATE) using the G-formula for causal inference with associated p-values and 95%CI. Output is presented as risk difference.
#' Using a the `gtsummary` tables `tbl_summary()` or `tbl_custom_summary()` for the baseline setup, the function wraps wraps `gcomp_boot()`, `add_stat()`, and `gcomp_tbl()` and provides an easy syntax for the calculation of the ATE with unadjusted and adjusted analyses.
#'
#' Note that the standard implementation of G-computation necessitates adjusted analyses for relevant baseline covariates.
#'
#' The function currently only accepts comparison between a binary predictor, i.e. intervention vs. control or treatment A vs. treatment B.
#'
#' @param tbl_summary_obj A `gtsummary` table object.
#' @param adj.vars A character vector of variables to adjust for in the computation. Default = NULL.
#' @param R The number of bootstrap resamples. Default = 1000.
#' @param method A string specifying the method for computation. Usages are either "glm", "log_binomial", "poisson" or "logistf". Default = "glm"
#' @param pattern A string specifying how to format the estimate and confidence interval.
#' @param estimate_header A string specifying the header for the estimate column.
#' @param p_value_header A string specifying the header for the p-value column.
#'
#' @return A `gtsummary` table object with generalized computation estimates and formatting applied.
#'
#' @examples
#' library(gtsummary)
#'
#' trial %>%
#'   tbl_summary(
#'     missing = "no",
#'     include = c(death),
#'     by = response,
#'     statistic = everything() ~ "{p}%",
#'     type = everything() ~ "dichotomous"
#'   ) %>%
#'   add_ci(pattern = "{stat} ({ci})") %>%
#'   add_overall() %>%
#'   add_gcomputation(adj.vars = c("stage"), R = 1000, method = "glm")
#'
#' @export
add_gcomputation <- function(tbl_summary_obj,
                             adj.vars = NULL,
                             R = 1000,
                             method = NULL,
                             pattern = "{estimate}% ({conf.low}%, {conf.high}%)",
                             estimate_header = "**Risk difference** (**95%CI**)",
                             p_value_header = "**P-value**") {

  # Apply gcomp_boot() via add_stat()
  tbl_summary_obj <- tbl_summary_obj %>%
    gtsummary::add_stat(
      fns = everything() ~ gcomp_boot(adj.vars = adj.vars, R = R, method = method)
    )

  # Apply gcomp_tbl() for formatting
  gcomp_tbl(
    tbl_summary_obj = tbl_summary_obj,
    pattern = pattern,
    estimate_header = estimate_header,
    p_value_header = p_value_header
  )
}
