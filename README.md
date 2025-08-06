
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bootgcompr

<!-- badges: start -->

<!-- badges: end -->

The `bootgcompr` package is a group of functions used in combination
with the `gtsummary` package for calculating non-parametric bootstrapped
statistics using the `boot` package. `bootgcompr` allows for calculating
the following in direct combination with `gtsummary`:

**Currently implemented:** - Mean summary statistics through
`tbl_custom_summary()`

**Under development:** - Median summary statistics through
`tbl_custom_summary()` - Mean difference (MD) by bootstrapped linear
regression (both univariate and multivariate) directly in
`tbl_summary()` - Risk Ratio / Relative Risk (RR) by bootstrapped
logistic regression directly in tbl_summary() using the `add_stat()`
function. - Absolute Risk Ratio / Absolute Risk Reduction (ARR/ARD)
using G-computation directly in tbl_summary() using the `add_stat()`
function. - Associated 95% confidence intervals (95%CI) for all of the
above mentioned statistics and analyses

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

The function is called and specifies the number of applied resamples
through the `R =` argument. If the number of resamples are not specified
it uses the default number of 10,000 resamples.

``` r
# load libraries
library(bootgcompr)
library(gtsummary)

# create tbl_custom_summary table with bootstrapped summary statistics
# set the `R = ` value to the number of wanted resamples. In this example we use 1000 resamples.
trial |> 
  tbl_custom_summary(
    include = c(ttdeath, marker),
    by = trt,
    statistic = ~ "{mean} ({conf.low}, {conf.high})",
    stat_fns = everything() ~ mean_boot(),
    missing = "no",
    type = everything() ~ "continuous"
    ) |> 
    add_overall()
```

<div id="fhkvpneiqe" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#fhkvpneiqe table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#fhkvpneiqe thead, #fhkvpneiqe tbody, #fhkvpneiqe tfoot, #fhkvpneiqe tr, #fhkvpneiqe td, #fhkvpneiqe th {
  border-style: none;
}
&#10;#fhkvpneiqe p {
  margin: 0;
  padding: 0;
}
&#10;#fhkvpneiqe .gt_table {
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
&#10;#fhkvpneiqe .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#fhkvpneiqe .gt_title {
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
&#10;#fhkvpneiqe .gt_subtitle {
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
&#10;#fhkvpneiqe .gt_heading {
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
&#10;#fhkvpneiqe .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fhkvpneiqe .gt_col_headings {
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
&#10;#fhkvpneiqe .gt_col_heading {
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
&#10;#fhkvpneiqe .gt_column_spanner_outer {
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
&#10;#fhkvpneiqe .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#fhkvpneiqe .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#fhkvpneiqe .gt_column_spanner {
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
&#10;#fhkvpneiqe .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#fhkvpneiqe .gt_group_heading {
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
&#10;#fhkvpneiqe .gt_empty_group_heading {
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
&#10;#fhkvpneiqe .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#fhkvpneiqe .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#fhkvpneiqe .gt_row {
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
&#10;#fhkvpneiqe .gt_stub {
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
&#10;#fhkvpneiqe .gt_stub_row_group {
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
&#10;#fhkvpneiqe .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#fhkvpneiqe .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#fhkvpneiqe .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fhkvpneiqe .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#fhkvpneiqe .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#fhkvpneiqe .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fhkvpneiqe .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fhkvpneiqe .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#fhkvpneiqe .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#fhkvpneiqe .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#fhkvpneiqe .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#fhkvpneiqe .gt_footnotes {
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
&#10;#fhkvpneiqe .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fhkvpneiqe .gt_sourcenotes {
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
&#10;#fhkvpneiqe .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#fhkvpneiqe .gt_left {
  text-align: left;
}
&#10;#fhkvpneiqe .gt_center {
  text-align: center;
}
&#10;#fhkvpneiqe .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#fhkvpneiqe .gt_font_normal {
  font-weight: normal;
}
&#10;#fhkvpneiqe .gt_font_bold {
  font-weight: bold;
}
&#10;#fhkvpneiqe .gt_font_italic {
  font-style: italic;
}
&#10;#fhkvpneiqe .gt_super {
  font-size: 65%;
}
&#10;#fhkvpneiqe .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#fhkvpneiqe .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#fhkvpneiqe .gt_indent_1 {
  text-indent: 5px;
}
&#10;#fhkvpneiqe .gt_indent_2 {
  text-indent: 10px;
}
&#10;#fhkvpneiqe .gt_indent_3 {
  text-indent: 15px;
}
&#10;#fhkvpneiqe .gt_indent_4 {
  text-indent: 20px;
}
&#10;#fhkvpneiqe .gt_indent_5 {
  text-indent: 25px;
}
&#10;#fhkvpneiqe .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#fhkvpneiqe div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
<td headers="stat_1" class="gt_row gt_center">20.2 (19.1, 21.1)</td>
<td headers="stat_2" class="gt_row gt_center">19.0 (17.9, 20.1)</td></tr>
    <tr><td headers="label" class="gt_row gt_left">Marker Level (ng/mL)</td>
<td headers="stat_0" class="gt_row gt_center">0.92 (0.80, 1.05)</td>
<td headers="stat_1" class="gt_row gt_center">1.02 (0.85, 1.21)</td>
<td headers="stat_2" class="gt_row gt_center">0.82 (0.67, 1.01)</td></tr>
  </tbody>
  &#10;  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="4"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>Mean (conf.low, conf.high)</span></td>
    </tr>
  </tfoot>
</table>
</div>
