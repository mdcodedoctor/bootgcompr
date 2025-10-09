#' G-computation using bootstrapping with covariate adjustment
#'
#' @description
#' Main inside function when using `gcomp_boot()`. This function use the inputted setup data from the tbl_summary() with `add_stat()` inputted `gcomp_boot()` functions. Calculates the absolute risk difference (reduction / increase) using bootstrapped G-computation with predictions by logistic regression. Standard settings are using `glm()` formula with `binomial()` distribution. Also outputs the associated bootstrapped 95%CI.
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
#'
#'

gcomp_boot_func <- function(data, variable, by, adj.vars = NULL, R = 1000, ...) {
  # Clean data
  vars <- c(variable, by, adj.vars)
  data <- data |>
    tidyr::drop_na(all_of(vars)) |>
    dplyr::mutate(
      !!sym(by) := factor(.data[[by]], levels = unique(.data[[by]])),
      !!sym(variable) := as.integer(.data[[variable]])
    )

  # Build formula
  formula_str <- paste(variable, "~", paste(c(by, adj.vars), collapse = " + "))
  formula <- as.formula(formula_str)

  # Try models in order of preference
  methods <- c("glm", "logistf", "log_binomial", "poisson")
  model <- NULL
  for (method in methods) {
    model <- try_fit_model(formula, data, method)
    if (!is.null(model)) break
  }

  if (is.null(model)) stop("All model fitting attempts failed.")

  # Counterfactual datasets
  data1 <- data; data1[[by]] <- levels(data[[by]])[2]
  data0 <- data; data0[[by]] <- levels(data[[by]])[1]
  pred1 <- predict(model, newdata = data1, type = "response")
  pred0 <- predict(model, newdata = data0, type = "response")
  rd_point <- (mean(pred1) - mean(pred0)) * 100 # Convert to percentage

  # Bootstrap with the same fallback logic
  boot_rd <- replicate(R, {
    idx <- sample(seq_len(nrow(data)), replace = TRUE)
    d <- data[idx, ]
    m <- NULL
    for (method in methods) {
      m <- try_fit_model(formula, d, method)
      if (!is.null(m)) break
    }
    if (is.null(m)) return(NA)
    d1 <- data1[idx, ]
    d0 <- data0[idx, ]
    p1 <- predict(m, newdata = d1, type = "response")
    p0 <- predict(m, newdata = d0, type = "response")
    (mean(p1) - mean(p0)) * 100 # Convert to percentage
  }, simplify = TRUE)

  # Remove NA values from bootstrap results (if any model failed)
  boot_rd <- boot_rd[!is.na(boot_rd)]

  ci <- quantile(boot_rd, probs = c(0.025, 0.975))
  pval <- 2 * min(mean(boot_rd <= 0), mean(boot_rd >= 0))

  # Return tibble
  dplyr::tibble(
    estimate = rd_point,
    std.error = sd(boot_rd),
    conf.low = ci[1],
    conf.high = ci[2],
    p.value = pval,
    method = paste("Absolute Risk Difference estimated by bootstrapped G-Computation (",
                   ifelse(method == "glm", "standard logistic",
                          ifelse(method == "logistf", "Firth's",
                                 ifelse(method == "log_binomial", "log-binomial", "Poisson"))),
                   ")", sep = "")
  )
}
