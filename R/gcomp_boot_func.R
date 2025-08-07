#' G-computation using bootstrapping with covariate adjustment
#'
#' @description
#' A short description...
#'
#' @import dplyr
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

# g-computation for gtsummary tbl_custom_summary
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
  # Fit model
  model <- glm(formula, data = data, family = binomial)
  # Counterfactual datasets
  data1 <- data; data1[[by]] <- levels(data[[by]])[2]
  data0 <- data; data0[[by]] <- levels(data[[by]])[1]
  pred1 <- predict(model, newdata = data1, type = "response")
  pred0 <- predict(model, newdata = data0, type = "response")
  rd_point <- (mean(pred1) - mean(pred0)) * 100 # Convert to percentage
  # Bootstrap
  boot_rd <- replicate(R, {
    idx <- sample(seq_len(nrow(data)), replace = TRUE)
    d <- data[idx, ]
    m <- glm(formula, data = d, family = binomial)
    d1 <- data1[idx, ]
    d0 <- data0[idx, ]
    p1 <- predict(m, newdata = d1, type = "response")
    p0 <- predict(m, newdata = d0, type = "response")
    (mean(p1) - mean(p0)) * 100 # Convert to percentage
  })
  ci <- quantile(boot_rd, probs = c(0.025, 0.975))
  pval <- 2 * min(mean(boot_rd <= 0), mean(boot_rd >= 0))
  # Return tibble in required format
  dplyr::tibble(
    estimate = rd_point,
    std.error = sd(boot_rd),
    conf.low = ci[1],
    conf.high = ci[2],
    p.value = pval,
    method = "Absolute Risk Difference estimated by bootstrapped G-Computation"
  )
}
