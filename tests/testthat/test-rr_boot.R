library(testthat)
library(bootgcompr)
library(gtsummary)

test_that("rr_boot works with tbl_summary and add_stat", {
  data(trial)

  # Test that the function runs without error
  expect_silent(
    result <- trial %>%
      tbl_summary(
        include = c(response),
        by = trt,
        statistic = ~ "{p}%",
        missing = "no",
        type = everything() ~ "dichotomous"
      ) %>%
      add_overall() %>%
      add_ci(
        pattern = "{stat} ({ci})"
      ) %>%
      add_stat(
        fns = everything() ~ rr_boot(adj.vars = c("stage"), R = 10)
      )
  )

  # Test that the output is a gtsummary object
  expect_s3_class(result, "gtsummary")

  # Test that the table body contains the expected variable
  tbl_df <- as.data.frame(result$table_body)
  expect_true(any(grepl("response", tbl_df$label, ignore.case = TRUE)))

  # Test that the table contains the expected columns
  expect_true(all(c("label", "stat_1") %in% colnames(tbl_df)))

  # Optionally, print the table for manual inspection
  print(result)
})


test_that("rr_boot works with different adjusted variables", {
  data(trial)

  expect_silent(
    result <- trial %>%
      tbl_summary(
        include = c(response),
        by = trt,
        statistic = ~ "{p}%",
        missing = "no",
        type = everything() ~ "dichotomous"
      ) %>%
      add_overall() %>%
      add_ci(
        pattern = "{stat} ({ci})"
      ) %>%
      add_stat(
        fns = everything() ~ rr_boot(adj.vars = c("grade", "age"), R = 10)
      )
  )

  expect_s3_class(result, "gtsummary")
})
