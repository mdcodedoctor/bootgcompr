#' Median difference estimation using non-parametric bootstrapped quantile regression with covariate adjustment
#'
#' @description
#' A short description...
#'
#' @param data A dataframe passed from `median_diff_boot()` and `tbl_summary()`
#' @param variable Inputted variable from the `tbl_summary(include = c())` argument.
#' @param by Passed stratification/grouping variable from `tbl_summary(by = )` argument.
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`
#' @param R Number of resamples (Standard is 1000)
#' @param ... Placeholder accepting further inputs from `tbl_summary()`
#'
#' @importFrom tidyr drop_na
#' @importFrom dplyr all_of mutate
#' @importFrom rlang .data sym
#' @importFrom quantreg rq
#' @importFrom purrr pluck
#' @importFrom stats median
#'
#' @export

median_diff_boot_func <- function(data, variable, by, adj.vars = NULL,
                                  R = 1000, ...) {
  # Check required packages
  if (!requireNamespace("tidyr", quietly = TRUE)) stop("tidyr required.")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr required.")
  if (!requireNamespace("quantreg", quietly = TRUE)) stop("quantreg required.")
  if (!requireNamespace("purrr", quietly = TRUE)) stop("purrr required.")

  # Clean and prepare data
  vars <- c(variable, by, adj.vars)
  data <- tidyr::drop_na(data, dplyr::all_of(vars)) |>
    dplyr::mutate(!!rlang::sym(by) := factor(.data[[by]], levels = unique(.data[[by]])))

  # Check two groups
  if (length(levels(data[[by]])) != 2) stop("Grouping variable must have exactly two levels.")

  # Build formula
  formula <- as.formula(paste(variable, "~", paste(c(by, adj.vars), collapse = " + ")))
  contrast_name <- paste0(by, levels(data[[by]])[2])

  # Fit quantile regression (tau = 0.5)
  model <- quantreg::rq(formula, data = data, tau = 0.5)

  # Bootstrap summary
  summ <- summary(model, se = "boot", R = R)
  coef_df <- as.data.frame(purrr::pluck(summ, "coefficients"))

  # Extract coefficient for the 'by' variable
  if (!(contrast_name %in% rownames(coef_df))) {
    stop(glue::glue("Contrast '{contrast_name}' not found in model coefficients."))
  }

  row <- coef_df[contrast_name, , drop = FALSE]

  est <- row[1, 1]
  se  <- row[1, 2]
  pval <- row[1, 4]
  ci_low <- est - 1.96 * se
  ci_high <- est + 1.96 * se

  # format adj.vars for the method text
  if (is.null(adj.vars) || length(adj.vars) == 0) {
    adj_text <- "Analyses are unadjusted."
  } else {
    # sort adj.vars alphabetically
    adj_vars_sorted <- sort(adj.vars)
    # format the list of adj.vars
    adj_vars_formatted <- toString(adj_vars_sorted)
    # replace the last comma with " and " for better readability
    adj_vars_formatted <- sub(", ([^,]+)$", " and \\1", adj_vars_formatted)
    adj_text <- paste0("All analyses are adjusted for ", adj_vars_formatted, ".")
  }

  # call the used method to text format
  method_text <- paste0(
    "Median difference estimated via bootstrapped quantile regression with ",
    format(R, big.mark = ","),
    " resamples. ",
    adj_text,
    sep = ""
  )

  # Return tidy tibble
  tibble::tibble(
    estimate  = est,
    std.error = se,
    conf.low  = ci_low,
    conf.high = ci_high,
    p.value   = pval,
    method    = method_text
  )
}
