# hoo
Horizon of Observation rENA Model for Multimodal Data Analysis

## Install hoo in R: 
To this repository in R as a package, run the following commands: 
```{r}
install.packages("devtools")
devtools::install_github("scaotravis/hoo@v3.0")
require(hoo)
```

## What's new: 

*Version 3.0*: 

* Include dataset `mock` for testing and example demonstration.
* `windowSize` for whole conversation data now takes value 1 (uses the same standard as `rENA` package).

## Upcoming features: 

* Directly generate appropriate ENA accumulated model for ENA set creation. 
* Use type `data.table` on dataset to increase performance.
* Consider Python version of `hoo` to increase loop performance.
