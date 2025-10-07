library(testthat)
library(bootgcompr)
library(gtsummary)

test_that("mean_boot works with tbl_custom_summary", {
  data(trial)

  # Test that the function runs without error
  expect_silent(
    result <- trial %>%
      tbl_custom_summary(
        include = c(ttdeath, marker),
        by = trt,
        statistic = ~ "{mean} ({conf.low}, {conf.high})",
        stat_fns = everything() ~ mean_boot(),
        missing = "no",
        type = everything() ~ "continuous"
      ) %>%
      add_overall()
  )

  # Test that the output is a gtsummary object
  expect_s3_class(result, "gtsummary")

  # Test that the table body contains the expected labels
  tbl_df <- as.data.frame(result$table_body)
  expect_true(any(tbl_df$label == "Months to Death/Censor"))
  expect_true(any(tbl_df$label == "Marker Level (ng/mL)"))

  # Test that stat_1 and stat_2 columns exist
  expect_true(all(c("stat_1", "stat_2") %in% colnames(tbl_df)))

  # Optionally, print the table for manual inspection
  print(result)
})



test_that("mean_boot works with integer trt", {
  # Load the original trial dataset
  data(trial)

  # Create a copy with integer trt
  trial_int_trt <- trial %>%
    mutate(trt = ifelse(trt == "Drug A", 1, 0))  # Convert "Drug A" to 1 and "Drug B" to 0

  # Print the first few rows to confirm
  head(trial_int_trt)

  # Use the trial_int_trt dataset
  expect_silent(
    result <- trial_int_trt %>%
      tbl_custom_summary(
        include = c(ttdeath, marker),
        by = trt,
        statistic = ~ "{mean} ({conf.low}, {conf.high})",
        stat_fns = everything() ~ mean_boot(),
        missing = "no",
        type = everything() ~ "continuous"
      ) %>%
      add_overall()
  )
  expect_s3_class(result, "gtsummary")
})
