
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bootgcompr

<!-- badges: start -->

<!-- badges: end -->

The `bootgcompr` package is a group of functions used in combination
with the `gtsummary` package for calculating non-parametric bootstrapped
statistics using the `boot` package. `bootgcompr` allows for calculating
the following in direct combination with `gtsummary`:

**Currently implemented:**

- Mean and median summary statistics through `tbl_custom_summary()` and
  the `stat_fns =` argument

- Risk Ratio / Relative Risk (RR) by bootstrapped logistic regression
  directly in `tbl_summary()` using the `add_stat()` function

- Absolute Risk Reduction / Absolute Risk Difference (ARR/ARD) using
  G-computation directly in `tbl_summary()` using the `add_stat()`
  function.

- Mean difference by bootstrapped linear regression or median difference
  using bootstrapped quantile regression directly through
  `tbl_summary()` using the `add_stat()` function.

- Associated bootstrapped 95% confidence intervals (95%CI) and p-values
  for all of the above mentioned statistics and analyses

- Wrapper functions for easily formatting of tables including standard
  displaying of the underlying statistical method, including number of
  resamples used in each analysis and if the analyses were adjusted for
  covariates or not, including alphabetically displayed of which
  covariates were used in the model.

## NOTE

The package is currently under development and many functions might not
work as expected and may have errors. Please submit an issue to the
github repo, and I will address the issue if I can and when I have time.

The package is developed alongside current work obligations, and I
probably cannot provide a sufficient ETA. I am also open for any
requests and suggestions for the package, and will try to implement any
changes that could be relevant.

I am not a biostatistician nor a software engineer, so using the package
will be by your own responsibility. Please evaluate the source code to
ensure what type of statistical test is actually applied to any analyses
you conduct.

## Installation

You can install the development version of bootgcompr from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("mdcodedoctor/bootgcompr")
```

## Example of summary statistics

If necessary to calculate summary statistics, while ensuring that the
outputted means (using the `mean_boot()` function) or medians (using the
`median_boot()` function) are bootstrapped with their 95%CI the
functions can be used with `tbl_custom_summary()` through the
`stat_fns =` argument.

``` r
# load libraries
library(bootgcompr)
library(gtsummary)

# create table for bootstrapped mean summary statistics
trial |> 
  tbl_custom_summary(
    include = c(ttdeath, marker),
    by = trt,
    statistic = ~ "{mean} ({conf.low}, {conf.high})",
    stat_fns = everything() ~ mean_boot(R = 1000),
    missing = "no",
    type = everything() ~ "continuous"
    ) |> 
    add_overall()
```

<div id="dsbnrxxupq" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Overall</strong><br />
N = 200</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_1"><span class='gt_from_md'><strong>Drug A</strong><br />
N = 98</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_2"><span class='gt_from_md'><strong>Drug B</strong><br />
N = 102</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left">Months to Death/Censor</td>
<td headers="stat_0" class="gt_row gt_center">19.6 (18.9, 20.3)</td>
<td headers="stat_1" class="gt_row gt_center">20.2 (19.2, 21.2)</td>
<td headers="stat_2" class="gt_row gt_center">19.0 (18.0, 20.1)</td></tr>
    <tr><td headers="label" class="gt_row gt_left">Marker Level (ng/mL)</td>
<td headers="stat_0" class="gt_row gt_center">0.91 (0.80, 1.04)</td>
<td headers="stat_1" class="gt_row gt_center">1.02 (0.85, 1.22)</td>
<td headers="stat_2" class="gt_row gt_center">0.82 (0.67, 1.00)</td></tr>
  </tbody>
  <tfoot>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="4"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>Mean (conf.low, conf.high)</span></td>
    </tr>
  </tfoot>
</table>
</div>

## Example of G-computation

Estimation of absolute risk difference using G-computation as causal
inference, with adjustment for specified covariates using
`tbl_summary()` and the `add_gcomputation()` function.

``` r
# create table for estimation of causal inference through G-computation
trial |>
  tbl_summary(
    include = c(death),
    by = trt,
    statistic = everything() ~ "{p}%",
    missing = "no",
    type = everything() ~ "dichotomous",
  ) |>
  add_overall() |>
  add_ci(
    pattern = "{stat} ({ci})") |>
  add_gcomputation(adj.vars = c("stage", "age", "marker"), R = 1000)
```

<div id="zqjdoromjz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Overall</strong><br />
N = 200 (<strong>95% CI</strong>)</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_1"><span class='gt_from_md'><strong>Drug A</strong><br />
N = 98 (<strong>95% CI</strong>)</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_2"><span class='gt_from_md'><strong>Drug B</strong><br />
N = 102 (<strong>95% CI</strong>)</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="estimate"><span class='gt_from_md'><strong>Risk difference</strong> (<strong>95%CI</strong>)</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="p.value"><span class='gt_from_md'><strong>P-value</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left">Patient Died</td>
<td headers="stat_0" class="gt_row gt_center">56% (49%, 63%)</td>
<td headers="stat_1" class="gt_row gt_center">53% (43%, 63%)</td>
<td headers="stat_2" class="gt_row gt_center">59% (49%, 68%)</td>
<td headers="estimate" class="gt_row gt_center">7.97% (-6.88%, 22.2%)</td>
<td headers="p.value" class="gt_row gt_center">0.3</td></tr>
  </tbody>
  <tfoot>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>%</span></td>
    </tr>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> <span class='gt_from_md'>Absolute Risk Difference estimated via bootstrapped G-Computation using standard logistic regression with 1,000 resamples. All analyses are adjusted for age, marker and stage.</span></td>
    </tr>
    <tr class="gt_sourcenotes">
      <td class="gt_sourcenote" colspan="6"><span class='gt_from_md'>Abbreviation: CI = Confidence Interval</span></td>
    </tr>
  </tfoot>
</table>
</div>

## Acknowledgements

A huge kudos to the developers of `gtsummary`. Without their substantial
work, this package would not have existed.

## References

**NOTE: References are not fully updated, but will be addressed when
possible for all relevant packages and relevant publications**

Sjoberg DD, Whiting K, Curry M, Lavery JA, Larmarange J. Reproducible
summary tables with the gtsummary package. The R Journal 2021;13:570–80.
<https://doi.org/10.32614/RJ-2021-053>.

Angelo Canty, B. D. Ripley (2024). boot: Bootstrap R (S-Plus) Functions.
R package version 1.3-31.

A. C. Davison, D. V. Hinkley (1997). Bootstrap Methods and Their
Applications. Cambridge University Press, Cambridge. ISBN 0-521-57391-2,
<doi:10.1017/CBO9780511802843>.
