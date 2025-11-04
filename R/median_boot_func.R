#' Underlying function for the `median_boot()` function.
#'
#' @param data The inputted dataframe called from `data =` argument in `tbl_summary()`
#' @param variable The inputted variable from `include = c()` argument in `tbl_summary()`
#' @param R number of resamples (if not defined, the function calls 1000 resamples)
#' @param ... Placeholder accepting further inputs from `tbl_summary()`
#'
#' @description
#' Function used in conjunction with `gtsummary` `tbl_custom_summary()`. Set `stat_fns = var ~ median_boot(R = )` and define number of resamples in the R call (E.g. `R = 10000`). Remember to define the `statistic =` argument as `{median} ({conf.low}, {conf.high})` inside `tbl_custom_summary()`.
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom boot boot boot.ci
#'
#' @export

median_boot_func <- function(data, variable, R = 1000, ...) {

  # check if required packages are installed
  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop("Package 'tibble' is required but not installed.")
  }
  if (!requireNamespace("boot", quietly = TRUE)) {
    stop("Package 'boot' is required but not installed.")
  }

  # ensure tibble format
  data <- tibble::as_tibble(data)
  x <- data[[variable]]

  # define the boot function
  stat_median <- function(data, indices) median(data[indices], na.rm = TRUE)

  # run the bootstrap
  boot_results <- boot::boot(data = x, statistic = stat_median, R = R)

  # extract 95% CI (BCa preferred, fallback to percentile)

  ci <- tryCatch({
    boot::boot.ci(boot_results, type = "bca")$bca[4:5]
  }, error = function(e) {
    message("bca CI failed; using percentile CI instead.")
    out <- try(boot::boot.ci(boot_results, type = "perc")$percent[4:5], silent = TRUE)
    if (inherits(out, "try-error")) c(NA, NA) else out
  })

  # return tibble with median and CI
  tibble::tibble(
    median = median(boot_results$t, na.rm = TRUE),
    conf.low = ci[1],
    conf.high = ci[2]
  )
}







