
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

\*\* NOTE: The package is currently under development and many functions
might not work as expected and may have errors. Please submit an issue
to the github repo, and I will address the issue if I can and when I
have time. The package is developed alongside current work obligations,
and I probably cannot provide a sufficient ETA. I am also open for any
requests and suggestions for the package, and will try to implement any
changes that could be relevant.

I am not a biostatistician nor a software engineer, so using the package
will be by your own responsibility. Please evaluate the source code to
ensure what type of statistical test is actually applied to any analyses
you conduct.\*\*

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

<div id="fqrgqtcjme" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#fqrgqtcjme table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#fqrgqtcjme thead, #fqrgqtcjme tbody, #fqrgqtcjme tfoot, #fqrgqtcjme tr, #fqrgqtcjme td, #fqrgqtcjme th {
  border-style: none;
}
&#10;#fqrgqtcjme p {
  margin: 0;
  padding: 0;
}
&#10;#fqrgqtcjme .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#fqrgqtcjme .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#fqrgqtcjme .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#fqrgqtcjme .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#fqrgqtcjme .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#fqrgqtcjme .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#fqrgqtcjme .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#fqrgqtcjme .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#fqrgqtcjme .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#fqrgqtcjme .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#fqrgqtcjme .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#fqrgqtcjme .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#fqrgqtcjme .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#fqrgqtcjme .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#fqrgqtcjme .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fqrgqtcjme .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#fqrgqtcjme .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#fqrgqtcjme .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#fqrgqtcjme .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fqrgqtcjme .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#fqrgqtcjme .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fqrgqtcjme .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#fqrgqtcjme .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fqrgqtcjme .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#fqrgqtcjme .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fqrgqtcjme .gt_left {
  text-align: left;
}
&#10;#fqrgqtcjme .gt_center {
  text-align: center;
}
&#10;#fqrgqtcjme .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#fqrgqtcjme .gt_font_normal {
  font-weight: normal;
}
&#10;#fqrgqtcjme .gt_font_bold {
  font-weight: bold;
}
&#10;#fqrgqtcjme .gt_font_italic {
  font-style: italic;
}
&#10;#fqrgqtcjme .gt_super {
  font-size: 65%;
}
&#10;#fqrgqtcjme .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#fqrgqtcjme .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#fqrgqtcjme .gt_indent_1 {
  text-indent: 5px;
}
&#10;#fqrgqtcjme .gt_indent_2 {
  text-indent: 10px;
}
&#10;#fqrgqtcjme .gt_indent_3 {
  text-indent: 15px;
}
&#10;#fqrgqtcjme .gt_indent_4 {
  text-indent: 20px;
}
&#10;#fqrgqtcjme .gt_indent_5 {
  text-indent: 25px;
}
&#10;#fqrgqtcjme .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#fqrgqtcjme div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
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
<td headers="stat_2" class="gt_row gt_center">19.0 (17.9, 20.1)</td></tr>
    <tr><td headers="label" class="gt_row gt_left">Marker Level (ng/mL)</td>
<td headers="stat_0" class="gt_row gt_center">0.91 (0.80, 1.05)</td>
<td headers="stat_1" class="gt_row gt_center">1.02 (0.85, 1.22)</td>
<td headers="stat_2" class="gt_row gt_center">0.82 (0.68, 1.01)</td></tr>
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
`tbl_summary()` and the `add_stat()` function.

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
  # conducting G-computation using add_stat() function.
  add_stat(
    fns = everything() ~ gcomp_boot(adj.vars = c("stage", "age", "marker"), R = 1000)
  ) |> 
  # apply the wrapper for table formatting
  gcomp_tbl()
```

<div id="fztcrooyes" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#fztcrooyes table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#fztcrooyes thead, #fztcrooyes tbody, #fztcrooyes tfoot, #fztcrooyes tr, #fztcrooyes td, #fztcrooyes th {
  border-style: none;
}
&#10;#fztcrooyes p {
  margin: 0;
  padding: 0;
}
&#10;#fztcrooyes .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#fztcrooyes .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#fztcrooyes .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#fztcrooyes .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#fztcrooyes .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#fztcrooyes .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#fztcrooyes .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#fztcrooyes .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#fztcrooyes .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#fztcrooyes .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#fztcrooyes .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#fztcrooyes .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#fztcrooyes .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#fztcrooyes .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#fztcrooyes .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fztcrooyes .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#fztcrooyes .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#fztcrooyes .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#fztcrooyes .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fztcrooyes .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#fztcrooyes .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fztcrooyes .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#fztcrooyes .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fztcrooyes .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#fztcrooyes .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fztcrooyes .gt_left {
  text-align: left;
}
&#10;#fztcrooyes .gt_center {
  text-align: center;
}
&#10;#fztcrooyes .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#fztcrooyes .gt_font_normal {
  font-weight: normal;
}
&#10;#fztcrooyes .gt_font_bold {
  font-weight: bold;
}
&#10;#fztcrooyes .gt_font_italic {
  font-style: italic;
}
&#10;#fztcrooyes .gt_super {
  font-size: 65%;
}
&#10;#fztcrooyes .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#fztcrooyes .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#fztcrooyes .gt_indent_1 {
  text-indent: 5px;
}
&#10;#fztcrooyes .gt_indent_2 {
  text-indent: 10px;
}
&#10;#fztcrooyes .gt_indent_3 {
  text-indent: 15px;
}
&#10;#fztcrooyes .gt_indent_4 {
  text-indent: 20px;
}
&#10;#fztcrooyes .gt_indent_5 {
  text-indent: 25px;
}
&#10;#fztcrooyes .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#fztcrooyes div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
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
<td headers="estimate" class="gt_row gt_center">7.97% (-7.08%, 22.1%)</td>
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
