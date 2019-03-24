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
devtools::install_github("scaotravis/hoo@v3.4.1")
require(hoo)
```

## What's new

*Version 3.4.1* (March 24, 2019):
* Cleaned up redundant codes.
* Included `hoo.horizon.DT()` method that utilizes data.table structure and `lapply()` function in attempt to increase performance.

~~*Version 3.3* (March 23, 2019)~~ (pulled on March 24 due to performance decrease)

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
* ~~Use type data.table on dataset to increase performance.~~ **(Prototype available in v3.4.1)**
* Consider C version of hoo to increase loop performance.
