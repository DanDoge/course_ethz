### Code skeleton for Series 5, Exercise 1

## Read in dataset
diabetes <-
  read.table("http://stat.ethz.ch/Teaching/Datasets/diabetes2.dat",
             header = TRUE)
reg <- diabetes[, c("Age", "C.Peptide")]
names(reg) <-     c("x",   "y")

## Sort values
reg <- reg[sort.list(reg$x), ]

###################################################
### TASK a)
###################################################

### Utility function for LOO cross-validation:

##' Calculates the LOO CV score for given data and regression prediction function
##'
##' @param reg.data: regression data; data.frame with columns 'x', 'y'
##' @param reg.fcn:  regr.prediction function; arguments:
##'                    reg.x: regression x-values
##'                    reg.y: regression y-values
##'                    x:     x-value(s) of evaluation point(s)
##'                  value: prediction at point(s) x
##' @return LOOCV score
loocv <- function(reg.data, reg.fcn)
{
  ## Help function to calculate leave-one-out regression values
  loo.reg.value <- function(i, reg.data, reg.fcn)
    return(reg.fcn(reg.data$x[-i], reg.data$y[-i], reg.data$x[i]))

  ## Calculate LOO regression values using the help function above
  n <- nrow(reg.data)
  loo.values <- sapply(seq(1:n), loo.reg.value, reg.data, reg.fcn)

  ## Calculate and return MSE
  return(mean((loo.values - reg.data$y)^2))
}


### Regression prediction function for NW kernel:
reg.fcn.nw <- function(reg.x, reg.y, x)
  ksmooth(reg.x, reg.y, x.points = x, kernel = "normal", bandwidth = 4.0)$y
  
### Calculation of LOO CV-score for NW kernel estimator:
(cv.nw <- loocv(reg, reg.fcn.nw))
print(cv.nw)

### Hat matrix "S.nw":
n <- nrow(reg)
Id <- diag(n)
S.nw <- matrix(0, n, n)
for (j in 1:n) {
  tmp <- rep(0, n)
  tmp[j] <- 1
  S.nw[, j] <- reg.fcn.nw(reg$x, tmp, reg$x)
}
  
### Degrees of freedom (cf. Formula (3.6) in the lecture notes:
(df.nw <- sum(diag(S.nw)))
print(df.nw)

###################################################
### TASKS b) to e)
###################################################

### Proceed similarly as in task a); you can reuse the utility function
### loocv from task a)

### b) have a look at ?predict.loess to define your regression function reg.fcn.lp
reg.fcn.lp <- function(reg.x, reg.y, x){
  loess.fit <- loess(reg.y ~ reg.x, enp.target = df.nw, surface = "direct")
  return(predict(loess.fit, data.frame(reg.x = x)))
}

(cv.lp <- loocv(reg, reg.fcn.lp))
print(cv.lp)

### c) have a look at ?predict.smooth.spline to define your regression function reg.fcn.ss

est.ss <- smooth.spline(reg$x, reg$y, cv = TRUE, df = df.nw)
print((est.ss$cv.crit))

reg.fcn.ss <- function(reg.x, reg.y, x){
  ss.fit <- smooth.spline(reg.x, reg.y, spar = est.ss$spar)
  return(predict(ss.fit, x)$y)
}

(cv.ss <- loocv(reg, reg.fcn.ss))
print(cv.ss)

### d)

cv.ss_int <- smooth.spline(reg$x, reg$y, cv = TRUE)$cv.crit
print(cv.ss_int)

### e)

reg.fcn.cn <- function(reg.x, reg.y, x){
  return(mean(reg.y))
}

(cv.cn <- loocv(reg, reg.fcn.cn))
print(cv.cn)