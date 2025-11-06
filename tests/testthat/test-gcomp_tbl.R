library(testthat)
library(bootgcompr)
library(gtsummary)

test_that("gcomp_tbl modifies the gtsummary object as expected", {
  data(trial)

  base_table <- trial %>%
    tbl_summary(
      include = c(response),
      by = trt,
      statistic = ~ "{p}%",
      missing = "no",
      type = everything() ~ "dichotomous"
    ) %>%
    add_overall() %>%
    add_ci(pattern = "{stat} ({ci})") %>%
    add_stat(fns = everything() ~ gcomp_boot(adj.vars = c("stage"), R = 10))

  expect_silent(
    result <- gcomp_tbl(base_table)
  )

  expect_s3_class(result, "gtsummary")

  # Check if the method column contains the expected text
  tbl_df <- as.data.frame(result$table_body)
  expect_true(any(grepl("Absolute Risk Difference estimated via bootstrapped G-Computation using standard logistic regression with 10 resamples. All analyses are adjusted for stage.", tbl_df$method)))

  # Check if the estimate and p.value columns exist
  expect_true(all(c("estimate", "p.value") %in% colnames(tbl_df)))

  # Optionally, print the table for manual inspection
  print(result)
})
