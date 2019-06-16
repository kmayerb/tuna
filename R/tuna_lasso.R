
#' run_lasso
#'
#' wrapper around cv.glmnet() to run lasso regression with a specific seed
#'
#' @param x matrix of numeric predictors
#' @param y matrix (1D) response
#' @param s int randomization seed
#' @param alpha numeric from 0 (ridge) to 1 ()
#' @param family string "gaussian", 'binomial", "poisson'
#'
#' @return list of two elements (1) cvfit , cv.glmnet full output and (2) r data.frame of non zero coefficients
run_lasso <- function(x,
                      y,
                      s,
                      alpha,
                      family){
  set.seed(seed=s)
  cvfit  = glmnet::cv.glmnet(x = x,
                         y = y,
                         alpha = alpha,
                         family = family)
  cf = coef(cvfit, lambda = "lambda.min") %>%
    as.matrix()
  r = data.frame("var" =rownames(cf), "coef"= cf[,1])
  r = r[(r$coef != 0), ]
  return(list(cvfit = cvfit, r = r))
}

q_run_lasso = purrr::quietly(run_lasso)

#' repeat_lasso
#'
#' call run_lasso over a specified number of trials to see the frequency with which the regularization
#' proceedure include each coefficient
#'
#' @param trials number of times to repeat cross-validation on the lasso
#' @param my_x matrix of numeric predictors
#' @param my_y matrix (1D) response
#' @param my_alpha numeric from 0 (ridge) to 1 ()
#' @param my_family string "gaussian", 'binomial"
#'
#' @return list, first element is data frame summarizing fits, second element contains all of the glmnet cvfit objects
#' @export
#'
#' @examples
#' repeat_lasso(10,
#' my_x = as.matrix(mtcars[1:15,2:dim(mtcars)[2]]),
#' my_y = as.matrix(mtcars[1:15,1]))
#'
repeat_lasso <- function(trials,
                         my_x,
                         my_y,
                         my_alpha = 1,
                         my_family= "gaussian"){


  lassos_and_fits <- purrr::map(seq(1:trials), ~ q_run_lasso(x = my_x,
                                       y = my_y,
                                       s = .x,
                                       alpha = my_alpha,
                                       family = my_family)
            )
  # have to pull results from quiety run function
  # quietly: wrapped function instead returns a list with components result, output, messages and warnings.
  lassos_and_fits <- lapply(lassos_and_fits, function(x) x[["result"]])

  lassos <- lapply(lassos_and_fits , function(x) x[["r"]])
  lassos <- purrr::invoke(rbind, lassos)

  fits  <- lapply(lassos_and_fits , function(x) x[["cvfit"]])

  lassos_df_s<- lassos %>%
    group_by(var) %>%
    summarise(n=n(),
              mean= mean(coef),
              sd = sd(coef) ) %>%
    mutate(descr = paste0(var,"_(",n,"/",trials,")")) %>%
    ungroup()

  lassos_df <- lassos %>% left_join(lassos_df_s, by = "var") %>% mutate(z = (coef-mean)/sd)

  return(list(df = lassos_df, fits = fits))

}


