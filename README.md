# dfoliatR

[![Build Status](https://travis-ci.org/chguiterman/dfoliatR.svg?branch=master)](https://travis-ci.org/chguiterman/dfoliatR)
[![Coverage Status](https://coveralls.io/repos/github/chguiterman/dfoliatR/badge.svg?branch=master)](https://coveralls.io/github/chguiterman/dfoliatR?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![DOI](https://zenodo.org/badge/104808563.svg)](https://zenodo.org/badge/latestdoi/104808563)


`dfoliatR` provides dendrochronologists with tools for identifying and analyzing the signatures of insect defoliators preserved in tree rings. The methods it employs closely follow (or exactly replicate) OUTBREAK, a FORTRAN program available from the [Dendrochronological Program Library](https://www.ltrr.arizona.edu/pub/dpl/). 

## Installation

`dfoliatR` is not yet on CRAN, to install it use the `devtools` function:

```R
devtools::install_github("chguiterman/dfoliatR")
```
Once installed, `dfoliatR` can be called like any other R package.

```R
library(dfoliatR)
```

The package includes two sets of tree-ring data for examples and exploration.

For the full range of usage in `dfoliatR`, please visit the [introduction vignette](https://chguiterman.github.io/dfoliatR/articles/intro-to-dfoliatR.html). 

## Overview

The package requires users to input two sets of tree-ring data: standardized ring widths of individual host trees and a standardized tree-ring chronology from a local non-host tree species. `dfoliatR` combines these to remove the climate signal represented by the non-host chronology from the host tree series. What's left should represent a disturbance signal. Then, `dfoliatR` identifies defoliation events in the host tree series. 

We recommend that the input tree-ring data be standardized in either ARSTAN or the `dplR` R package. These standardized ring-width series should be averaged to the tree level. In ARSTAN, make sure to output .TRE files and read them into R with the `read.compact()` function in `dplR`. If you choose to standardize raw ring widths in `dplR` with `detrend()`, then use the `treeMean()` function to generate tree-level series. All data input to `dfoliatR` needs to be an `rwl` object as defined in `dplR`.

Begin using `dfoliatR` by applying the `defoliate_trees()` function that calls for these host tree series and a non-host site chronology. Note that the non-host chronology cannot include the "samp.depth" column commonly included in chronology files (e.g., .crn) and created by the `dplr::chron()` function.

Analyses of the tree series (termed `defol` objects) can be done via:

* `plot_defol()`
* `defol_stats()`
* `get_defol_events()`
* `sample_depth()`

To identify ecologically-significant outbreak events, use the `outbreak()` function. Various filters are available to aid users in defining outbreak thresholds. Analyses of outbreak series (termed `obr` objects) can be done via:

* `plot_outbreak()`
* `outbreak_stats()`

#### Questions, concerns, problems, ideas, or want to contribute?
Please contact the author, Chris Guiterman
