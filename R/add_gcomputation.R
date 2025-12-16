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
#' @param tbl A `gtsummary` table object.
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`. Several vars can be passed and the formulas will be taken as `glm()` or `lm()`, e.g. `lm(outcome ~ group + covariate1 + covariate2 + covariate3, data = data)` If adj.vars is not called, the analysis will be calculated unadjusted, e.g. `lm(outcome ~ group, data = data)`
#' @param R number of bootstrap resamples. Defaults to `R = 2000`.
#' @param ci_type Chosen type of CI calculation. Choose between `"bca"`, `"perc"`, `"norm"` or `"basic"`.
#' @param t.effect Whether to calculate average or individual differences or ratios. Choose between `"average"` or `"individual"`.
#' @param scale Type of scale used, set to either `"difference"` or `"ratio"`. Differences in binary outcomes are set as marginal risk differences, while continuous outcomes are set as adjusted or unadjusted mean differences. Ratios are calculated as marginal risk ratio for binary outcomes and either adjusted or unadjusted ratio of means for continuous outcomes.
#' @param percentage Defines whether to convert estimates and CI to percentage or not, set as either `TRUE` or `FALSE` Percentage only influence binary outcomes. Defaults to `FALSE`.
#' @param footnotes_separate Defines whether footnotes for what statistical analysis was conducted should be placed as either one combined footnote or separate footnotes in a similar manner as gtsummarys `separate_p_footnotes()`. `footnotes_separate = TRUE` gives each individual test a footnote, while `FALSE` keeps them combined. Defaults to `FALSE`.
#' @param ... Placeholder for gtsummary table objects
#'
#' @import dplyr
#' @importFrom gtsummary add_stat modify_table_styling modify_column_hide modify_column_merge modify_header modify_footnote_header everything any_of
#' @importFrom rlang .data
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
#'   add_gcomputation(adj.vars = c("age", "stage", "response"),
#'                    R = 1000,
#'                    ci_type = "bca",
#'                    t.effect = "average",
#'                    scale = "ratio",
#'                    percentage = TRUE,
#'                    footnotes_separate = TRUE)
#'
#' @export

add_gcomputation <- function(
    tbl,
    ...,
    footnotes_separate = FALSE,
    t.effect = "average",
    scale = "difference",
    percentage = FALSE
) {

  # calls the gcomp_boot() function for calculating bootstrap estimates
  tbl <- tbl %>%
    add_stat(fns = everything() ~ gcomp_boot(
      ...,
      scale = scale,
      t.effect = t.effect
    ))

  # setup for formatting of calculated values as percentage for risk differences and ratios when percentage = TRUE
  if (percentage && scale == "difference") {
    binary_vars <- tbl$table_body %>%
      filter(.data$var_type == "dichotomous") %>%
      pull(variable) %>%
      unique()

    if (length(binary_vars) > 0) {
      tbl <- tbl %>%
        modify_table_styling(
          columns = any_of(c("estimate", "conf.low", "conf.high")),
          rows = variable %in% binary_vars,
          fmt_fun = function(x) sprintf("%.1f%%", x * 100)
        )
    }
  }

  # adds footnotes for each variable and sets as one footnote for all calculations if footnotes_separate = FALSE, if footnotes_separate = TRUE, then variables are handled with separate footnotes in a similar matter as separate_p_footnote() from gtsummary
  if (footnotes_separate) {
    tbl <- tbl %>% add_method_footnotes_body()
  } else {
    if ("method" %in% names(tbl$table_body)) {
      footnote_text <- tbl$table_body$method |> unique() |> na.omit() |> paste(collapse = "; ")
      tbl <- tbl %>%
        modify_footnote_header(
          footnote = footnote_text,
          columns = c("estimate", "p.value")
        )
    }
  }

  # merges columns and set column names
  estimate_label <-
    if (scale == "difference") "**Difference** (**95% CI**)"
  else "**Ratio** (**95% CI**)"

  tbl <- tbl %>%
    modify_column_hide(columns = c("std.error", "method")) %>%
    modify_column_merge(pattern = "{estimate} ({conf.low}, {conf.high})") %>%
    modify_header(
      estimate = estimate_label,
      p.value = "**p-value**"
    )

  tbl
}
