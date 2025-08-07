#' @export

# function calculating mean boot of summary statistics (both groups and overall() values)
mean_boot_func <- function(data, variable, R = 1000, ...) {

  # check if required packages are installed
  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop("Package 'tibble' is required but not installed. Please install package before this function will work.")
  }
  if (!requireNamespace("boot", quietly = TRUE)) {
    stop("Package 'boot' is required but not installed. Please install package before this function will work.")
  }

  # set data formats
  data <- tibble::as_tibble(data)
  x <- data[[variable]]

  # define the boot function
  stat_mean <- function(data, indices) { mean(data[indices], na.rm = TRUE) }

  # run the bootsstrap
  boot_results <- boot::boot(data = x, statistic = stat_mean, R = R)

  # extract 95%CI (BCa is usual, if not possible, perc is used instead)
  ci <- tryCatch({
    boot::boot.ci(boot_results, type = "bca")$bca[4:5]
  }, error = function(e) {
    message("bca CI failed; using percentile CI instead.")
    boot::boot.ci(boot_results, type = "perc")$percent[4:5]
  })

  tibble::tibble(mean = mean(boot_results$t,
                             na.rm = TRUE),
                 conf.low = ci[1],
                 conf.high = ci[2])
}
