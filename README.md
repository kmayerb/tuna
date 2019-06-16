---
title: "Instructions"
author: "Koshlan Mayer-Blackwell"
date: "6/16/2019"
output: html_document
---

### Package: tuna

Type: Package

Title: See what may have passed through your glmnet.

Version: 0.1.0

Author: Koshlan Mayer-Blackwell

Description: Tuna makes it easy to repeat regularized regressions 
in the popular package [glmnet] (https://www.jstatsoft.org/article/view/v033i01) 
and vizualize the results.  Lasso, ridge, and glmnet regressions typically use cross validation 
to determine a suitable value of the regularization hyperparameter
that minimizes the cross-validated estimate of out of sample error. 
The number of non-zero coefficients can vary depending on initialization
of coordinate gradient decent used to estimate arguments that maximize the penalized 
likelihood function. Therefore, if regularized regression is being used 
for feature selection it is worth repeating cross validation and gradient decent.

### Usage

```{r, echo = T, warnings = F, message = F}
devtools::load_all(".")
require(tuna)
```
Define a response vector and predictor matrix. specify the the number of repeated trials. 
```{r}
my_y = as.matrix(mtcars[1:15,1])
my_x = as.matrix(mtcars[1:15,2:dim(mtcars)[2]])
tuna <- tuna::repeat_lasso(trials = 100, my_x = my_x, my_y=my_y )
```

Summary of the results.
```{r}
tuna::summarize_repeated_lasso(tuna)
```
##### Visualize the distribution of coefficient values accross n trials
```{r, fig.width = 4 , fig.hieght =3}
vizualize_coef_density(tuna) + ggtitle("Repeated Lassos",subtitle ="mpg~." ) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))
```
![](f1.png)
##### Visualize distribution of standardized coefficient values
```{r, fig.width = 4 , fig.hieght =3}
vizualize_coef_z_density(tuna)
```
![](f2.png)
# Vizualize mean cross-validation errors 
Visualize mean cross-validation error for all values of the regularization 
parameter lambda across all n repeated trials.  
The blue lines show the value of lambda.min that mininized the cross 
validation error in a particular trial. The numbers above the plot 
indiate the number of parameters with non-zero coefficient for a given
value lamda in the first regularization trial. 
```{r, fig.width = 4 , fig.hieght =3}
vizualize_all_cverror(tuna)
```
![](f3.png)

# Tuna saves all the cvfit Results from glmnet
Tuna save the cvfit results from glmnet, which can be plucked for downstream analysis.
```{r, fig.width = 4 , fig.hieght =3}
i=5
plot(tuna[["fits"]][[i]])
```
![](f4.png)
