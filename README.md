# **bugr**

Detection and analysis of insect defoliation signals in tree rings


### Installation

`bugr` is not currently on CRAN. to install `bugr` use the `devtools` package:

```R
library(devtools)

install_github("chguiterman/bugr")
```
Once installed, `bugr` can be called like any other R package

```R
library(bugr)
```

### Data

`bugr` requires two independent datasets: 
* Host-tree series, as standardized ring widths. 
* A non-host standardized tree-ring chronology.
These datasets can be created in ARSTAN or using the `detrend()` function in the `dplR` library. A chronology can be created in `dplR` with the `chron()` function. Once read into R, the data can be passed to `bugr` functions. They must share the formatting of `rwl` objects in `dplR`.

Data are provided in this package to demonstrate some of the utilities of `bugr`, courtesy of Dr. Ann Lynch. 

Here, we can read in Douglas-fir host series from the East Fork site in the Jemez Mountains, `ef`.

```{r, eval = TRUE}
data(ef)

head(ef)
```
These trees are compared against a non-host chronology from a nearby site. The BAC chornology is from ponderosa pine at the Baca site in the Jemez Mountains.

```R
data(bac_crn)
```

### Operation

The first thing to do is perform the "correction" on the host trees, whereby the climate-growth signal of the non-host chronology is removed. From there, `bugr` will employ the same runs analyses as in the program OUTBREAK to assess for defoliation periods in each tree. Some parameters around the length and depth of growth departure can be changed in the `defoliate_trees` function.

```R
ef_defol <- defoliate_trees(host_tree = ef, nonhost_chron = bac_crn, duration_years = 8, max_reduction = -1.28, list_output = FALSE)
```
Definitions of the function parameters are provided with `?defoliate_trees`

We can view the individual time series and the defoliation periods identified by the function by plotting the new `defol` object:
```R
plot_defol(ef_defol)
```
![](vignettes/ef_defol_plot.tiff)


