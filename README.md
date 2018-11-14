# hoo
Horizon of Observation rENA Model for Multimodal Data Analysis

* [What is hoo?](#what-is-hoo)
* [Install hoo in R](#install-hoo-in-r)
* [What's new](#whats-new)
* [Upcoming features](#upcoming-features)

## What is hoo?
hoo is an R package used for multimodal data analysis. It is used alongside [rENA](https://cran.r-project.org/web/packages/rENA/index.html). 

hoo will create an appropriate rENA accumulated model that can be used by `rENA` to create ENA set; afterwards, you can use `rENA` plotting functions to generate points and network plots to analyze connections between players in the multimodal data. 

For more on how to interpret ENA models and networks, consult [Epistemic Analytics Lab](http://www.epistemicanalytics.org/) at University of Wisconsin-Madison. 

## Install hoo in R: 
To install this repository in R as a package, run the following commands: 
```{r}
install.packages("devtools")
devtools::install_github("scaotravis/hoo@v3.1")
require(hoo)
```

## What's new: 

*Version 3.1*: 
* Include function `hoo.accumulate.data` to direct generate ENA accumulated model for ENA set creation. 
* Reordered some arguments for more logical ordering. 

*Version 3.0*: 

* Include dataset `mock` for testing and example demonstration.
* `windowSize` for whole conversation data now takes value 1 (uses the same standard as `rENA` package).

## Upcoming features: 

* ~~Directly generate appropriate ENA accumulated model for ENA set creation.~~ **(Now available in v3.1)**
* Use type `data.table` on dataset to increase performance.
* Consider Python version of `hoo` to increase loop performance.
