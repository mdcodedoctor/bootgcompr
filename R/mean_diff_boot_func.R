#' Mean difference estimation using non-parametric bootstrapped linear regression with covariate adjustment
#'
#' @description
#' A short description...
#'
#' @param data A dataframe passed from `mean_diff_boot()` and `tbl_summary()`
#' @param variable Inputted variable from the `tbl_summary(include = c())` argument.
#' @param by Passed stratification/grouping variable from `tbl_summary(by = )` argument.
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`
#' @param R Number of resamples (Standard is 1000)
#' @param ci_type Character string specifying the bootstrap CI type to use.
#'   Options: `"bca"`, `"perc"`, `"norm"`, `"basic"`. Default = `"bca"`.
#' @param ... Placeholder accepting further inputs from `tbl_summary()`
#'
#' @importFrom tibble tibble
#' @importFrom boot boot boot.ci
#' @importFrom dplyr all_of
#' @importFrom tidyr drop_na
#' @importFrom stats lm coef sd as.formula
#'
#' @export

mean_diff_boot_func <- function(data, variable, by, adj.vars = NULL,
                                R = 1000, ci_type = "bca", ...) {
  # check packages
  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop("Package 'tibble' is required but not installed.")
  }
  if (!requireNamespace("boot", quietly = TRUE)) {
    stop("Package 'boot' is required but not installed.")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required but not installed.")
  }
  if (!requireNamespace("tidyr", quietly = TRUE)) {
    stop("Package 'tidyr' is required but not installed.")
  }

  # prepare data
  vars <- c(variable, by, adj.vars)
  data <- tidyr::drop_na(data, dplyr::all_of(vars))
  data[[by]] <- factor(data[[by]], levels = unique(data[[by]]))

  # ensure two groups only
  if (length(levels(data[[by]])) != 2) {
    stop("Grouping variable must have exactly two levels.")
  }

  # build formula
  formula <- as.formula(paste(variable, "~", paste(c(by, adj.vars), collapse = " + ")))
  contrast_name <- paste0(by, levels(data[[by]])[2])

  # define bootstrap function
  boot_fun <- function(data, indices) {
    d <- data[indices, ]
    model <- tryCatch(lm(formula, data = d), error = function(e) NULL)
    if (is.null(model)) return(NA)
    coefs <- coef(model)
    if (contrast_name %in% names(coefs)) {
      -coefs[contrast_name]  # flip sign here
    } else {
      NA
    }
  }


  # fit base model
  base_model <- lm(formula, data = data)
  estimate <- -coef(base_model)[contrast_name]

  # run bootstrap
  boot_results <- boot::boot(data = data, statistic = boot_fun, R = R)

  # determine which CI type(s) to use, with fallback if necessary
  ci_type <- match.arg(ci_type, c("bca", "perc", "norm", "basic"))
  ci <- tryCatch({
    ci_out <- boot::boot.ci(boot_results, type = ci_type)
    ci_component <- ci_out[[ci_type]]
    if (!is.null(ci_component) && length(ci_component) >= 5) {
      ci_component[4:5]
    } else {
      stop("Invalid CI structure for type: ", ci_type)
    }
  }, error = function(e) {
    message("Requested CI type failed; falling back to percentile CI.")
    tryCatch({
      ci_out <- boot::boot.ci(boot_results, type = "perc")
      ci_out$percent[4:5]
    }, error = function(e2) c(NA_real_, NA_real_))
  })

  # compute SE and bootstrap-based p-value
  se <- stats::sd(boot_results$t, na.rm = TRUE)
  pval <- 2 * min(mean(boot_results$t <= 0, na.rm = TRUE),
                  mean(boot_results$t >= 0, na.rm = TRUE))


  # create setup for displaying used 95%CI type
  ci_type_display <- list(
    bca = "BCa",
    perc = "Percentile",
    norm = "Normal",
    basic = "Basic"
  )

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
    "Mean difference estimated via bootstrapped linear regression (",
    ci_type_display[[ci_type]],
    " 95%CI) with ",
    format(R, big.mark = ","),
    " resamples. ",
    adj_text,
    sep = ""
  )

  # return results
  tibble::tibble(
    estimate = estimate,
    std.error = se,
    conf.low = ci[1],
    conf.high = ci[2],
    p.value = pval,
    method = method_text
    )
}

