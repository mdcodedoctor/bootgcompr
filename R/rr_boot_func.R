#' Relative risk / Risk ratio estimation using non-parametric bootstrapped logistic regression with covariate adjustment
#'
#' @description
#' A short description...
#'
#' @param data A dataframe passed from `rr_boot()` and `tbl_summary()`
#' @param variable Inputted variable from the `tbl_summary(include = c())` argument. Variables are best handled as integers of 0 or 1, where 1 depicts that the outcome happened and 0 depicts that the outcome didn't happen.
#' @param by Passed stratification/grouping variable from `tbl_summary(by = )` argument. Should accept both integers (0 vs. 1) or factors with at least 2 levels.
#' @param adj.vars Covariates used for adjusting the estimates. Uses the same setup as `gtsummary` `add_difference()` with `adj.vars = c("var")`
#' @param R Number of resamples (Standard is 1000)
#' @param ... Placeholder accepting further inputs from `tbl_summary()`
#'
#' @import dplyr
#' @import tidyr
#' @import sandwich
#' @import lmtest
#' @import logistf
#' @importFrom stats as.formula
#' @importFrom stats binomial
#' @importFrom stats glm
#' @importFrom stats predict
#' @importFrom stats quantile
#' @importFrom stats sd
#'
#' @export

rr_boot_func <- function(data, variable, by, adj.vars = NULL, R = 1000, method = NULL, ...) {
  # Prepare data
  vars <- c(variable, by, adj.vars)
  data <- tidyr::drop_na(data, all_of(vars))
  data[[by]] <- factor(data[[by]], levels = unique(data[[by]]))
  data[[variable]] <- as.integer(data[[variable]])
  formula <- as.formula(paste(variable, "~", paste(c(by, adj.vars), collapse = " + ")))

  # Function to fit a model and return bootstrapped RR
  boot_rr <- function(model_family, use_firth = FALSE) {
    if (use_firth) {
      # Use Firth's penalized regression
      model <- tryCatch({
        logistf(formula, data = data, pl = TRUE)
      }, error = function(e) NULL)
      if (is.null(model) || any(is.na(coef(model)))) {
        warning("Firth's regression failed.")
        return(NULL)
      }
      model_type <- "Firth's penalized"
    } else {
      # Standard GLM
      model <- tryCatch({
        suppressWarnings(glm(formula, data = data, family = model_family))
      }, error = function(e) NULL)
      if (is.null(model)) return(NULL)
      model_type <- ifelse(model_family$link == "log", "log-binomial", "Poisson")
    }

    # Predicted risks per group
    risks <- data %>%
      dplyr::mutate(pred = predict(model, type = "response")) %>%
      dplyr::group_by(.data[[by]]) %>%
      dplyr::summarise(risk = mean(pred), .groups = "drop") %>%
      dplyr::pull(risk)
    rr_point <- risks[1] / risks[2]

    # Bootstrap RR for CI and p-value
    boot_log_rr <- replicate(R, {
      idx <- sample(seq_len(nrow(data)), replace = TRUE)
      d_boot <- data[idx, ]
      if (use_firth) {
        m_boot <- tryCatch({
          logistf(formula, data = d_boot, pl = TRUE)
        }, error = function(e) NULL)
      } else {
        m_boot <- tryCatch({
          suppressWarnings(glm(formula, data = d_boot, family = model_family))
        }, error = function(e) NULL)
      }
      if (is.null(m_boot)) return(NA)
      risks_boot <- d_boot %>%
        dplyr::mutate(pred = predict(m_boot, newdata = d_boot, type = "response")) %>%
        dplyr::group_by(.data[[by]]) %>%
        dplyr::summarise(risk = mean(pred), .groups = "drop") %>%
        dplyr::pull(risk)
      log(risks_boot[1] / risks_boot[2])
    })
    rr_boot <- exp(boot_log_rr)
    rr_boot_clean <- rr_boot[is.finite(rr_boot) & rr_boot < quantile(rr_boot, 0.99)]
    ci <- quantile(rr_boot_clean, c(0.025, 0.975), na.rm = TRUE)
    pval <- 2 * min(mean(rr_boot <= 1, na.rm = TRUE), mean(rr_boot >= 1, na.rm = TRUE))
    pval <- ifelse(is.numeric(pval) && length(pval) == 1 && !is.na(pval), pval, NA_real_)

    return(
      tibble::tibble(
        estimate = rr_point,
        conf.low = ci[1],
        conf.high = ci[2],
        p.value = pval,
        method = paste("Relative Risk estimated by bootstrapped", model_type, "regression")
      )
    )
  }

  # If method is specified, use it
  if (!is.null(method)) {
    if (method == "log-binom") {
      message("Using log-binomial regression...")
      result <- boot_rr(binomial(link = "log"))
      if (!is.null(result)) return(result)
    } else if (method == "logit-binom") {
      message("Using logistic regression...")
      result <- boot_rr(binomial(link = "logit"))
      if (!is.null(result)) return(result)
    } else if (method == "poisson") {
      message("Using Poisson regression...")
      result <- boot_rr(poisson(link = "log"))
      if (!is.null(result)) return(result)
    } else if (method == "firth") {
      message("Using Firth's penalized regression...")
      result <- boot_rr(binomial(link = "log"), use_firth = TRUE)
      if (!is.null(result)) return(result)
    } else {
      warning(paste("Unknown method:", method, ". Using default logic."))
    }
  }

  # Default logic: Try log-binomial, then Poisson, then Firth's, then logistic
  message("Trying log-binomial regression...")
  try_log_binomial <- boot_rr(binomial(link = "log"))
  if (!is.null(try_log_binomial)) return(try_log_binomial)

  message("Trying Poisson regression...")
  try_poisson <- boot_rr(poisson(link = "log"))
  if (!is.null(try_poisson)) return(try_poisson)

  message("Trying Firth's penalized regression...")
  try_firth <- boot_rr(binomial(link = "log"), use_firth = TRUE)
  if (!is.null(try_firth)) return(try_firth)

  message("Falling back to bootstrapped logistic regression...")
  model <- glm(formula, data = data, family = binomial)
  risks <- data %>%
    dplyr::mutate(pred = predict(model, type = "response")) %>%
    dplyr::group_by(.data[[by]]) %>%
    dplyr::summarise(risk = mean(pred), .groups = "drop") %>%
    dplyr::pull(risk)
  rr_point <- risks[1] / risks[2]
  boot_log_rr <- replicate(R, {
    idx <- sample(seq_len(nrow(data)), replace = TRUE)
    d_boot <- data[idx, ]
    m_boot <- glm(formula, data = d_boot, family = binomial)
    risks_boot <- d_boot %>%
      dplyr::mutate(pred = predict(m_boot, newdata = d_boot, type = "response")) %>%
      dplyr::group_by(.data[[by]]) %>%
      dplyr::summarise(risk = mean(pred), .groups = "drop") %>%
      dplyr::pull(risk)
    log(risks_boot[1] / risks_boot[2])
  })
  rr_boot <- exp(boot_log_rr)
  rr_boot_clean <- rr_boot[is.finite(rr_boot) & rr_boot < quantile(rr_boot, 0.99)]
  ci <- quantile(rr_boot_clean, c(0.025, 0.975), na.rm = TRUE)
  pval <- 2 * min(mean(rr_boot <= 1, na.rm = TRUE), mean(rr_boot >= 1, na.rm = TRUE))
  pval <- ifelse(is.numeric(pval) && length(pval) == 1 && !is.na(pval), pval, NA_real_)
  return(
    tibble::tibble(
      estimate = rr_point,
      conf.low = ci[1],
      conf.high = ci[2],
      p.value = pval,
      method = "Relative Risk estimated by non-parametric bootstrapped logistic regression"
    )
  )
}





