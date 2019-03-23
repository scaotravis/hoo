# hoo

Horizon of Observation rENA Model for Multimodal Data Analysis

* [What is hoo?](#what-is-hoo)
* [Install hoo in R](#install-hoo-in-r)
* [What's new](#whats-new)
* [Upcoming features](#upcoming-features)

## What is hoo?
hoo is an R package used for multimodal data analysis. It is used alongside [rENA](https://cran.r-project.org/web/packages/rENA/index.html).

hoo creates an appropriate ENA accumulated model that can be used by rENA to produce ENA set. You can call rENA plotting functions on such ENA set to generate points and network plots to analyze connections between player interactions.

For more on how to interpret ENA model and plotted network, consult [Epistemic Analytics Lab](http://www.epistemicanalytics.org/) at University of Wisconsin-Madison.

## Install hoo in R
To install this repository in R as a package, run the following commands:
```{r}
install.packages("devtools")
devtools::install_github("scaotravis/hoo@v3.3")
require(hoo)
```

## What's new

*Version 3.3* (March 23, 2019): 
* Cleaned up redundant codes
* Included `hoo.mc.horizon()` and `hoo.mc.ena.accumulate.data()` that utilizes `parallel` package's `mclapply()` function to speed up performance, if your computer supports multi-core computation
* Attempted to increase performance through converting data type to `data.table` with no avail (see more in [Upcoming features](#upcoming-features) section)

*Verison 3.2* (January 29, 2019):
* Now, all methods from hoo comes with prefix `hoo.`, which helps you distinguish methods called by hoo class.

*Version 3.1* (November 14, 2018):
* Included function `hoo.ena.accumulate.data()` to directly generate ENA accumulated model for ENA set creation.
* Reordered some arguments for a more logical ordering.

*Version 3.0* (November 11, 2018):

* Included dataset `mock` for testing and example demonstration.
* `windowSize` for whole conversation data now takes value 1 (uses the same standard as rENA).

## Upcoming features

* ~~Directly generate appropriate ENA accumulated model for ENA set creation.~~ **(Available since v3.1)**
* ~~Use type `data.table` on dataset to increase performance.~~ (Testing in v3.3 shows that using `data.table` along with `lapply()` actually slows performance. The current way `hoo.horizon()` works is by filling in a fixed-size `data.frame` with the computed adjacency vector, which is already of great performance. Hence, further performance improvement will rely on writing core looping codes in C or other high-performance compiled language)
* Consider C version of hoo to increase loop performance.
