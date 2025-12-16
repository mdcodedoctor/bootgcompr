library(testthat)
library(bootgcompr)
library(gtsummary)
library(dplyr)

test_that("gcomp_boot works with tbl_summary and add_stat", {
  data(trial)

  # Test that the full pipeline runs without error
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
        fns = everything() ~ gcomp_boot(adj.vars = c("stage"), R = 100, ci_type = "bca", t.effect = "average", scale = "difference", percentage = FALSE)
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




test_that("gcomp_boot works with different adjusted variables", {
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
        fns = everything() ~ gcomp_boot(adj.vars = c("stage"), R = 100, ci_type = "bca", t.effect = "average", scale = "difference" ,percentage = FALSE)
      )
  )

  expect_s3_class(result, "gtsummary")
})





test_that("gcomp_boot handles missing data", {
  # Load the original trial dataset
  data(trial)

  # Create a copy with missing values
  trial_with_missing <- trial %>%
    mutate(
      response = ifelse(runif(n()) < 0.1, NA, response),  # Introduce 10% missing in response
      age = ifelse(runif(n()) < 0.1, NA, age),            # Introduce 10% missing in age
      marker = ifelse(runif(n()) < 0.15, NA, marker)      # Introduce 15% missing in marker
    )

  # Print the first few rows to confirm missing values
  head(trial_with_missing)

  # Use the trial_with_missing dataset
  expect_silent(
    result <- trial_with_missing %>%
      tbl_summary(
        include = c(response),
        by = trt,
        statistic = ~ "{p}%",
        missing = "ifany",
        type = everything() ~ "dichotomous"
      ) %>%
      add_overall() %>%
      add_ci(pattern = "{stat} ({ci})") %>%
      add_stat(
        fns = everything() ~ gcomp_boot(adj.vars = c("stage"), R = 100, ci_type = "bca", t.effect = "average", scale = "difference" ,percentage = FALSE)
      )
  )
  expect_s3_class(result, "gtsummary")
})

test_that("gcomp_boot works with integer trt", {
  # Load the original trial dataset
  data(trial)

  # Create a copy with integer trt
  trial_int_trt <- trial %>%
    mutate(trt = ifelse(trt == "Drug A", 1, 0))  # Convert "Drug A" to 1 and "Placebo" to 0

  # Print the first few rows to confirm
  head(trial_int_trt)

  # Use the trial_int_trt dataset
  expect_silent(
    result <- trial_int_trt %>%
      tbl_summary(
        include = c(response),
        by = trt,
        statistic = ~ "{p}%",
        missing = "no",
        type = everything() ~ "dichotomous"
      ) %>%
      add_overall() %>%
      add_ci(pattern = "{stat} ({ci})") %>%
      add_stat(
        fns = everything() ~ gcomp_boot(adj.vars = c("stage"), R = 100, ci_type = "bca", t.effect = "average", scale = "difference" ,percentage = FALSE)
      )
  )
  expect_s3_class(result, "gtsummary")
})
