#' Bootstrapping absolute risk differences using G-computation with covariate adjustment. Main function for best setup of the output should be called through `add_gcomputation()`.
#'
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`. Several vars can be passed and the formulas will be taken as `glm()` or `lm()`, e.g. `lm(outcome ~ group + covariate1 + covariate2 + covariate3, data = data)` If adj.vars is not called, the analysis will be calculated unadjusted, e.g. `lm(outcome ~ group, data = data)`
#' @param R number of bootstrap resamples. Defaults to `R = 2000`.
#' @param ci_type Chosen type of CI calculation. Choose between `"bca"`, `"perc"`, `"norm"` or `"basic"`.
#' @param t.effect Whether to calculate average or individual differences or ratios. Choose between `"average"` or `"individual"`.
#' @param scale Type of scale used, set to either `"difference"` or `"ratio"`. Differences in binary outcomes are set as marginal risk differences, while continuous outcomes are set as adjusted or unadjusted mean differences. Ratios are calculated as marginal risk ratio for binary outcomes and either adjusted or unadjusted ratio of means for continuous outcomes.
#' @param percentage Defines whether to convert estimates and CI to percentage or not, set as either `TRUE` or `FALSE` Percentage only influence binary outcomes. Defaults to `FALSE`.
#' @param ... Placeholder for gtsummary table objects
#'
#' @import dplyr
#' @import tidyr
#' @importFrom stats as.formula
#' @importFrom stats binomial
#' @importFrom stats glm
#' @importFrom stats lm
#' @importFrom stats predict
#' @importFrom stats sd
#' @importFrom boot boot
#' @importFrom boot boot.ci
#' @importFrom rlang sym
#' @importFrom tibble tibble
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
#'   add_stat(fns = everything() ~ gcomp_boot(adj.vars = c("stage"),
#'                                            R = 100,
#'                                            ci_type = "bca",
#'                                            percentage = TRUE))
#'
#' @export

# gcomp_boot function setup
gcomp_boot <- function(
    adj.vars = NULL,
    R = 2000,
    ci_type = "bca",
    t.effect = "average",
    scale = "difference",
    percentage = FALSE,
    ...
) {
  force(adj.vars)
  force(R)
  force(ci_type)
  force(t.effect)
  force(scale)
  force(percentage)

  function(data, variable, by, ...) {
    # drop missing values in the analysis variables
    vars <- c(variable, by, adj.vars)
    data <- data |> tidyr::drop_na(all_of(vars))

    # check if the outcome is binary or continuous
    is_binary <- length(unique(data[[variable]])) == 2


    # set binary function call if variable is binary, else use the continuous function
    if (is_binary) {
      gcomp_boot_binary(
        adj.vars = adj.vars,
        R = R,
        ci_type = ci_type,
        t.effect = t.effect,
        scale = scale,
        percentage = percentage
      )(data, variable, by, ...)
    } else {
      gcomp_boot_continuous(
        adj.vars = adj.vars,
        R = R,
        ci_type = ci_type,
        t.effect = t.effect,
        scale = scale,
        percentage = percentage
      )(data, variable, by, ...)
    }
  }
}

# function for binary outcomes
gcomp_boot_binary <- function(
    adj.vars = NULL,
    R = 2000,
    ci_type = "bca",
    t.effect = "Average",
    scale = "difference",
    percentage = FALSE,
    ...
) {
  force(adj.vars)
  force(R)
  force(ci_type)
  force(t.effect)
  force(scale)

  function(data, variable, by, ...) {

    # revise dataset to comply with correct data format
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

    # Set standard model preference order
    methods <- c("glm", "logistf", "log_binomial")

    # try to fit models in order of preference
    try_fit_model <- function(formula, data, method) {
      tryCatch({
        if (method == "glm") {
          glm(formula, data = data, family = binomial)
        } else if (method == "logistf") {
          logistf::logistf(formula, data = data)
        } else if (method == "log_binomial") {
          glm(formula, data = data, family = binomial(link = "log"))
        }
      }, error = function(e) NULL)
    }

    # fit the main model for point estimation
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

    # bootstrap function to calculate point estimate, CI, and p-value
    boot_stat <- function(data, indices) {
      d <- data[indices, ]
      d[[by]] <- factor(d[[by]], levels = levels(data[[by]]))

      m <- NULL
      for (meth in methods) {
        m <- try_fit_model(formula, d, meth)
        if (!is.null(m)) break
      }
      if (is.null(m)) return(NA_real_)

      d1 <- d; d1[[by]] <- levels(data[[by]])[2]
      d0 <- d; d0[[by]] <- levels(data[[by]])[1]

      p1 <- predict(m, newdata = d1, type = "response")
      p0 <- predict(m, newdata = d0, type = "response")

      if (scale == "difference") {
        if (t.effect == "average") {
          return(mean(p0) - mean(p1))
        } else if (t.effect == "individual") {
          return(mean(p0 - p1))
        } else stop("Missing t.effect")
      } else if (scale == "ratio") {
        if (t.effect == "average") {
          return(mean(p0) / mean(p1))
        } else if (t.effect == "individual") {
          return(mean(p0 / p1))
        } else stop("Specification of the treatment effect (t.effect) is missing with no default")
      } else {
        stop("Specification of the scale (scale) is missing with no default")
      }
    }

    # calculate bootstrap statistics
    b <- boot::boot(data = data, statistic = boot_stat, R = R)

    if (mean(is.na(b$t)) > 0.1)
      warning("More than 10% bootstrap replicates failed. Consider using logistf as primary model.")

    # extract bootstrap results
    boot_t <- b$t[!is.na(b$t)]
    ate_point <- mean(boot_t)
    std_error <- sd(boot_t)

    # calculate confidence intervals
    ci <- boot::boot.ci(b, type = ci_type)
    if (ci_type %in% c("bca", "perc")) {
      ci_low <- ci[[ci_type]][4]
      ci_high <- ci[[ci_type]][5]
    } else if (ci_type %in% c("norm", "basic")) {
      ci_low <- ci[[ci_type]][2]
      ci_high <- ci[[ci_type]][3]
    } else {
      stop("Unknown ci_type. Choose one of 'bca', 'perc', 'norm', 'basic'.")
    }

    # calculate two-sided p-value
    null_value <- if (scale == "difference") 0 else 1
    p_val <- 2 * min(mean(boot_t <= null_value), mean(boot_t >= null_value))

    # define the method and analysis type used for the output text
    method_lookup <- list(
      glm = "standard logistic regression",
      logistf = "Firth's penalized logistic regression",
      log_binomial = "log-binomial regression"
    )

    # define which 95% CI type was used
    ci_type_display <- list(
      bca = "BCa",
      perc = "Percentile",
      norm = "Normal",
      basic = "Basic"
    )

    # define whether adj.vars was called or NULL
    if (is.null(adj.vars) || length(adj.vars) == 0) {
      adj_text <- "Analyses are unadjusted"
    } else {
      adj_vars_sorted <- sort(adj.vars)
      adj_vars_formatted <- sub(
        ", ([^,]+)$",
        " and \\1",
        toString(adj_vars_sorted)
      )
      adj_text <- paste0("Analyses adjusted for ", adj_vars_formatted)
    }

    # set the text for the effect label
    effect_label <- if (scale == "difference" && t.effect == "average") {
      "Marginal Risk Difference"
    } else if (scale == "difference" && t.effect == "individual") {
      "Individual Risk Difference"
    } else if (scale == "ratio" && t.effect == "average") {
      "Marginal Risk Ratio"
    } else if (scale == "ratio" && t.effect == "individual") {
      "Individual Risk Ratio"
    } else {
      stop("Scale or treatment effect or both are not specified with no default")
    }

    # create the CI label
    ci_label <- if (!is.null(ci_type) && !is.null(ci_type_display[[ci_type]])) ci_type_display[[ci_type]] else ci_type

    # create the method text that describes which method was used
    method_text <- paste0(
      effect_label, " estimated via bootstrapped G-Computation using ",
      method_lookup[[chosen_method]],
      " (", ci_label, " 95%CI) with ",
      format(R, big.mark = ","), " resamples. ",
      adj_text
    )


    # return the tibble and define attributes for percentage values
    res <- tibble::tibble(
      estimate = ate_point,
      std.error = std_error,
      conf.low = ci_low,
      conf.high = ci_high,
      p.value = p_val,
      method = method_text
    )

    # extract metadata for what type of call was made
    attr(res, "scale") <- scale
    attr(res, "percentage") <- percentage

    return(res)
  }
}


# function for continuous outcomes
gcomp_boot_continuous <- function(
    adj.vars = NULL,
    R = 2000,
    ci_type = "bca",
    t.effect = "average",
    scale = "difference",
    percentage = FALSE,
    ...
) {
  force(adj.vars)
  force(R)
  force(ci_type)
  force(t.effect)
  force(scale)

  function(data, variable, by, ...) {
    # drop missing values in the analysis variables
    vars <- c(variable, by, adj.vars)
    data <- data |> tidyr::drop_na(all_of(vars))

    # convert 'by' to a factor variable
    data <- data |> dplyr::mutate(!!sym(by) := factor(.data[[by]]))

    # define the model formula and identify whether adj.vars was called or NULL
    if (is.null(adj.vars) || length(adj.vars) == 0) {
      formula_int_str <- as.formula(
        paste(variable, "~", by)
      )
    } else {
      formula_int_str <- as.formula(
        paste(
          variable, "~",
          by, "* (", paste(adj.vars, collapse = " + "), ")"
        )
      )
    }

    # bootstrap function to estimate the treatment effect
    boot_stat <- function(data, indices) {
      d <- data[indices, ]

      # fit the model on the bootstrap sample
      m <- tryCatch(
        lm(formula_int_str, data = d),
        error = function(e) NULL
      )
      if (is.null(m)) return(NA_real_)

      # set treatment levels for prediction where d1 is the treatment group and d0 is the control
      d1 <- d
      d1[[by]] <- levels(data[[by]])[2]
      d0 <- d
      d0[[by]] <- levels(data[[by]])[1]

      # predict outcomes in the new data set
      p1 <- predict(m, newdata = d1)
      p0 <- predict(m, newdata = d0)

      # calculate the statistic
      if (scale == "difference") {
        if (t.effect == "average") {
          return(mean(p0, na.rm = TRUE) - mean(p1, na.rm = TRUE))
        } else if (t.effect == "individual") {
          return(mean(p0 - p1, na.rm = TRUE))
        }
      } else if (scale == "ratio") {
        if (t.effect == "average") {
          return(mean(p0, na.rm = TRUE) / (mean(p1, na.rm = TRUE) + 1e-10))
        } else if (t.effect == "individual") {
          return(mean(p0 / (p1 + 1e-10), na.rm = TRUE))
        }
      }
    }

    # run bootstrapping
    b <- boot::boot(data = data, statistic = boot_stat, R = R)

    # check for excessive NA values in bootstrap replicates
    if (mean(is.na(b$t)) > 0.1) {
      warning("More than 10% bootstrap replicates failed. Results may be unstable.")
    }

    # use the mean of the bootstrap replicates as the point estimate
    ate_point <- mean(b$t, na.rm = TRUE)

    # extract confidence intervals
    ci <- boot::boot.ci(b, type = ci_type)
    if (ci_type %in% c("bca", "perc")) {
      ci_low <- ci[[ci_type]][4]
      ci_high <- ci[[ci_type]][5]
    } else if (ci_type %in% c("norm", "basic")) {
      ci_low <- ci[[ci_type]][2]
      ci_high <- ci[[ci_type]][3]
    } else {
      stop("Unknown ci_type. Choose one of 'bca', 'perc', 'norm', 'basic'.")
    }

    # extract bootstrap replicates
    boot_t <- b$t[!is.na(b$t)]

    # calculate standard error
    std_error <- sd(boot_t)

    # calculate two-sided p-value
    null_value <- if (scale == "difference") 0 else 1
    p_val <- 2 * min(mean(boot_t <= null_value), mean(boot_t >= null_value))

    # define the method and analysis type for output text
    effect_label <- if (scale == "difference") {
      if (is.null(adj.vars) || length(adj.vars) == 0) {
        "Mean Difference"
      } else {
        "Adjusted Mean Difference"
      }
    } else {
      if (is.null(adj.vars) || length(adj.vars) == 0) {
        "Ratio of Means"
      } else {
        "Adjusted Ratio of Means"
      }
    }

    ci_type_display <- list(
      bca = "BCa",
      perc = "Percentile",
      norm = "Normal",
      basic = "Basic"
    )

    # define the text when adj.vars is called or not
    if (is.null(adj.vars) || length(adj.vars) == 0) {
      adj_text <- "Analyses are unadjusted"
    } else {
      adj_vars_sorted <- sort(adj.vars)
      adj_vars_formatted <- sub(", ([^,]+)$", " and \\1", toString(adj_vars_sorted))
      adj_text <- paste0("Analyses adjusted for ", adj_vars_formatted)
    }

    # define the CI label
    ci_label <-
      if (!is.null(ci_type) && !is.null(ci_type_display[[ci_type]])) ci_type_display[[ci_type]]
      else ci_type

    # create the method text
    method_text <- paste0(
      effect_label, " estimated via bootstrapped G-Computation using linear regression (",
      ci_label, " 95%CI) with ", format(R, big.mark = ","), " resamples. ", adj_text
    )

    # return results as a tibble
    return(
      tibble::tibble(
        estimate = ate_point,
        std.error = std_error,
        conf.low = ci_low,
        conf.high = ci_high,
        p.value = p_val,
        method = method_text
      )
    )
  }
}

