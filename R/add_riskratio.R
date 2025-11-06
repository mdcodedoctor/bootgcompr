#' Final wrapper function. Embeds the `add_stat()`, `rr_boot_func()`, `rr_boot()` and `rr_tbl()` into one function call for easy syntax.
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_summary()` and `bootgcompr` `rr_boot` function. Standard output when using `rr_boot` is not adjusted to the usual `tbl_summary()` output as a custom function is called. This wrapper function cleans up the outputted table and formats it as expected other types of `tbl_summary()` outputs, e.g. when using functions like `add_difference()`.
#'
#' @param tbl_summary_obj The used table summary object (e.g. `tbl_summary()`)
#' @param adj.vars Specify covariates for adjusted analyses
#' @param R Number of resamples for the bootstrapping
#' @param pattern The pattern in which the calculated output is formatted
#' @param estimate_header Header name for the calculated estimate.
#' @param p_value_header Header name for the calculated p.value
#'
#' @import tidyr
#' @import gtsummary
#'
#' @export

add_riskratio <- function(tbl_summary_obj,
                          adj.vars = NULL,
                          R = 1000,
                          pattern = "{estimate} ({conf.low}, {conf.high})",
                          estimate_header = "**RR** (**95%CI**)",
                          p_value_header = "**P-value**") {

  # Apply rr_boot() via add_stat()
  tbl_summary_obj <- tbl_summary_obj %>%
    gtsummary::add_stat(
      fns = everything() ~ rr_boot(adj.vars = adj.vars, R = R)
    )

  # Apply rr_tbl() for formatting
  rr_tbl(
    tbl_summary_obj = tbl_summary_obj,
    pattern = pattern,
    estimate_header = estimate_header,
    p_value_header = p_value_header
  )
}
