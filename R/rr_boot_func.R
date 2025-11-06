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

rr_boot_func <- function(data, variable, by, adj.vars = NULL, R = 1000, ...) {

  # Prepare data
  vars <- c(variable, by, adj.vars)
  data <- tidyr::drop_na(data, all_of(vars))

  data[[by]] <- factor(data[[by]], levels = unique(data[[by]]))
  data[[variable]] <- as.integer(data[[variable]])

  formula <- as.formula(paste(variable, "~", paste(c(by, adj.vars), collapse = " + ")))
  model <- glm(formula, data = data, family = binomial)

  # Predicted risks per group

  risks <- data %>%
    mutate(pred = predict(model, type = "response")) %>%
    group_by(.data[[by]]) %>%
    summarise(risk = mean(pred), .groups = "drop") %>%
    pull(risk)

  rr_point <- risks[1] / risks[2]

  # Bootstrap log RR for CI

  boot_log_rr <- replicate(R, {
    idx <- sample(seq_len(nrow(data)), replace = TRUE)
    d_boot <- data[idx, ]
    m_boot <- glm(formula, data = d_boot, family = binomial)
    risks_boot <- d_boot %>%
      mutate(pred = predict(m_boot, newdata = d_boot, type = "response")) %>%
      group_by(.data[[by]]) %>%
      summarise(risk = mean(pred), .groups = "drop") %>%
      pull(risk)
    log(risks_boot[1] / risks_boot[2])
  })

  rr_boot <- exp(boot_log_rr)

  # Optional stability patch
  rr_boot_clean <- rr_boot[is.finite(rr_boot) & rr_boot < quantile(rr_boot, 0.99)]
  ci <- quantile(rr_boot_clean, c(0.025, 0.975), na.rm = TRUE)

  # p-value for RR=1 null
  pval <- 2 * min(mean(rr_boot <= 1), mean(rr_boot >= 1))
  pval <- ifelse(is.numeric(pval) && length(pval) == 1 && !is.na(pval), pval, NA_real_)

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

  # create method text
  method_text <- paste(
    "Relative Risk estimated by non-parametric bootstrapped logistic regression with ",
    format(R, big.mark = ","),
    " resamples. ",
    adj_text,
    sep = ""
  )

  tibble::tibble(
    estimate = rr_point,
    conf.low = ci[1],
    conf.high = ci[2],
    p.value = pval,
    method = method_text
  )
}
