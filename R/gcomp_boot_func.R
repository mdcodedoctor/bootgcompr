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
#' @param ci_type Chosen type of CI calculation. Choose between `"bca"`, `"perc"`, `"norm"` or `"basic"`.
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

gcomp_boot_func <- function(data, variable, by, adj.vars = NULL, R = 2000, ci_type = NULL, ...) {

  # revise dataset to comply to correct data format
  vars <- c(variable, by, adj.vars)
  data <- data |>
    tidyr::drop_na(all_of(vars)) |>
    dplyr::mutate(
      !!sym(by) := factor(.data[[by]], levels = unique(.data[[by]])),
      !!sym(variable) := as.integer(.data[[variable]])
    )

  # define formula for the model
  formula_str <- paste(variable, "~", paste(c(by, adj.vars), collapse = " + "))
  formula <- as.formula(formula_str)

  # set standard model preference order
  methods <- c("glm", "logistf", "log_binomial", "poisson")

  # Try models in order of preference
  try_fit_model <- function(formula, data, method) {
    tryCatch({
      if (method == "glm") {
        glm(formula, data = data, family = binomial)
      } else if (method == "logistf") {
        logistf::logistf(formula, data = data)
      } else if (method == "log_binomial") {
        glm(formula, data = data, family = binomial(link = "log"))
      } else if (method == "poisson") {
        glm(formula, data = data, family = poisson(link = "log"))
      }
    }, error = function(e) NULL)
  }

  # fit main model for point estimation
  main_model <- NULL
  chosen_method <- NULL

  for (m in methods) {
    main_model <- try_fit_model(formula, data, m)
    if (!is.null(main_model)) {
      chosen_method <- m
      break
    }
  }
  if (is.null(main_model)) stop("All model fitting attempts failed.")

  # compute point estimation of ATE
  data1 <- data; data1[[by]] <- levels(data[[by]])[2]
  data0 <- data; data0[[by]] <- levels(data[[by]])[1]

  pred1 <- predict(main_model, newdata = data1, type = "response")
  pred0 <- predict(main_model, newdata = data0, type = "response")

  ate_point <- mean(pred1) - mean(pred0)

  # refit the model
  boot_stat <- function(data, indices) {
    d <- data[indices, ]

    # keep treatment factor levels consistent with original dataset
    d[[by]] <- factor(d[[by]], levels = levels(data[[by]]))

    # try to fit the model for each bootstrap sample
    m <- NULL
    for (meth in methods) {
      m <- try_fit_model(formula, d, meth)
      if (!is.null(m)) break
    }

    if (is.null(m)) return(NA_real_)

    # construct counterfactuals
    d1 <- d; d1[[by]] <- levels(data[[by]])[2]
    d0 <- d; d0[[by]] <- levels(data[[by]])[1]

    # predictions
    p1 <- predict(m, newdata = d1, type = "response")
    p0 <- predict(m, newdata = d0, type = "response")

    mean(p1) - mean(p0)
  }

  # calculate bootstrap CI by defined type
  b <- boot::boot(data = data, statistic = boot_stat, R = R)

  if (mean(is.na(b$t)) > 0.1)
    warning("More than 10% bootstrap replicates failed. Consider using logistf as primary model.")

  ci <- boot::boot.ci(b, type = ci_type)
  ci_vals <- if (ci_type %in% c("bca","perc")) ci[[ci_type]][4:5] else ci[[ci_type]][2:3]

  # Extract CI depending on type
  if (ci_type %in% c("bca", "perc")) {
    ci_low  <- ci[[ci_type]][4]
    ci_high <- ci[[ci_type]][5]
  } else if (ci_type %in% c("norm", "basic")) {
    ci_low  <- ci[[ci_type]][2]
    ci_high <- ci[[ci_type]][3]
  } else {
    stop("Unknown ci_type. Choose one of 'bca', 'perc', 'norm', 'basic'.")
  }

  # extract bootstrap
  boot_t <- b$t[!is.na(b$t)]

  # extract standard error
  std_error <- sd(boot_t)

  # calculate two-sided p-value
  p_val <- 2 * min(mean(boot_t <= 0), mean(boot_t >= 0))

  # define the method and analysis type used for the output text
  method_lookup <- list(
    glm = "standard logistic regression",
    logistf = "Firth's penalized logistic regression",
    log_binomial = "log-binomial regression",
    poisson = "Poisson regression with log link"
  )

  # create setup for displaying used 95%CI type
  ci_type_display <- list(
    bca = "BCa",
    perc = "Percentile",
    norm = "Normal",
    basic = "Basic"
  )

  if (is.null(adj.vars) || length(adj.vars) == 0) {
    adj_text <- "Analyses are unadjusted."
  } else {
    adj_vars_sorted <- sort(adj.vars)
    adj_vars_formatted <- sub(
      ", ([^,]+)$",
      " and \\1",
      toString(adj_vars_sorted)
    )
    adj_text <- paste0("Analyses adjusted for ", adj_vars_formatted, ".")
  }

  # define what method was used
  method_text <- paste0(
    "Risk Difference estimated via bootstrapped G-Computation using ",
    method_lookup[[chosen_method]],
    " (",
    ci_type_display[[ci_type]],
    " 95%CI) with ",
    format(R, big.mark = ","), " resamples. ",
    adj_text,
    sep = ""
  )

  # return tibble
  return(dplyr::tibble(
    estimate = ate_point,
    std.error = std_error,
    conf.low = ci_vals[1],
    conf.high = ci_vals[2],
    p.value = p_val,
    method = method_text
  ))
}
