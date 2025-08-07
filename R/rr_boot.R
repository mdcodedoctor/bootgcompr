rr_boot_func <- function(data, variable, by, adj.vars = NULL, boot_n = n_boot_count, ...) {
  # Prepare data
  vars <- c(variable, by, adj.vars)
  data <- tidyr::drop_na(data, all_of(vars))
  data[[by]] <- factor(data[[by]], levels = unique(data[[by]]))
  data[[variable]] <- as.integer(data[[variable]])

  formula <- as.formula(paste(variable, "~", paste(c(by, adj.vars), collapse = " + ")))
  model <- glm(formula, data = data, family = binomial)

  # Predicted risks per group
  risks <- data %>%
    dplyr::mutate(pred = predict(model, type = "response")) %>%
    dplyr::group_by(.data[[by]]) %>%
    dplyr::summarise(risk = mean(pred), .groups = "drop") %>%
    dplyr::pull(risk)

  rr_point <- risks[1] / risks[2]

  # Bootstrap log RR for CI
  boot_log_rr <- replicate(boot_n, {
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

  # Optional stability patch
  rr_boot_clean <- rr_boot[is.finite(rr_boot) & rr_boot < quantile(rr_boot, 0.99)]
  ci <- quantile(rr_boot_clean, c(0.025, 0.975), na.rm = TRUE)

  # p-value for RR=1 null
  pval <- 2 * min(mean(rr_boot <= 1), mean(rr_boot >= 1))
  pval <- ifelse(is.numeric(pval) && length(pval) == 1 && !is.na(pval), pval, NA_real_)

  # Return components expected by gtsummary
  tibble::tibble(
    estimate = rr_point,
    conf.low = ci[1],
    conf.high = ci[2],
    p.value = pval
  )
}




create_rr_boot_wrapper <- function(adj.vars = NULL, boot_n = 1000) {
  function(data, variable, by) {
    rr_boot(data, variable, by, adj.vars = adj.vars, boot_n = boot_n)
  }
}


trial %>%
  tbl_summary(
    by = trt,
    include = c(response, death),
    type = everything() ~ "dichotomous",
    statistic = everything() ~ "{p}%",
    missing = "no"
  ) %>%
  add_ci(pattern = "{stat} ({ci})") %>%
  add_stat(fns = everything() ~ rr_boot_func(adj.vars = c("age", "marker"), boot_n = 1000))
