### Code skeleton for Series 8, task 2

## read in data
## data(ozone, package = "gss")

## alternative
ozone <- read.table("http://stat.ethz.ch/Teaching/Datasets/ozone.dat", header = TRUE)

###################################################
### TASK a)
###################################################

ozone$logupo3 <- log(ozone$upo3)
d.ozone <- subset(ozone, select = -upo3)
pairs(ozone, pch = ".", gap = 0.1)

## delete outlier
out <- 92
d.ozone.e <- d.ozone[-out,]



###################################################
### TASK b)
###################################################

## package for wrapFormula()  [sfsmisc := miscellaneous from SfS
##                             ---        SfS = Seminar für Statistik, ETH Z ]
require(sfsmisc)

## Linear models
## fit 1 (polynomial of degree 1)
# write a formula as you know it from lm()
form1 <- as.formula(logupo3 ~ .)
fit1 <- lm(form1, d.ozone.e)



## fits of degree 2 to 5
form2 <- wrapFormula(f = form1, data = d.ozone.e, wrapString = "poly(*, degree = 2)")
fit2 <- lm(form2, d.ozone.e)

form3 <- wrapFormula(f = form1, data = d.ozone.e, wrapString = "poly(*, degree = 3)")
fit3 <- lm(form3, d.ozone.e)

form4 <- wrapFormula(f = form1, data = d.ozone.e, wrapString = "poly(*, degree = 4)")
fit4 <- lm(form4, d.ozone.e)

form5 <- wrapFormula(f = form1, data = d.ozone.e, wrapString = "poly(*, degree = 5)")
fit5 <- lm(form5, d.ozone.e)


## GAM
require(mgcv)
gamForm <- wrapFormula(form1, data=d.ozone.e, wrapString = "s(*)")
g1 <- gam(formula = gamForm, data = d.ozone.e)
summary(g1)

###################################################
### TASK c)
###################################################

## plot the fits

## for the linear models
par(mfrow=c(3, 3))
termplot(fit1, partial.resid = TRUE, rug = TRUE, se = TRUE, pch = 19)


par(mfrow=c(3, 3))
termplot(fit2, partial.resid = TRUE, rug = TRUE, se = TRUE, pch = 19)

par(mfrow=c(3, 3))
termplot(fit3, partial.resid = TRUE, rug = TRUE, se = TRUE, pch = 19)

par(mfrow=c(3, 3))
termplot(fit4, partial.resid = TRUE, rug = TRUE, se = TRUE, pch = 19)

par(mfrow=c(3, 3))
termplot(fit5, partial.resid = TRUE, rug = TRUE, se = TRUE, pch = 19)


## for the additive model
mult.fig(nr.plots = 9, main = "gam(gamForm, data = d.ozone.e)")
plot(g1, shade = TRUE)


###################################################
### TASK d)
###################################################


## Mallows Cp function

Cp <- function(object, sigma){
  res <- residuals(object)
  n <- length(res)
  p <- n - object$df.residual
  SSE <- sum(res^2)
  SSE / sigma^2 - n + 2 * p
}

## set sigma (use estimated sigma from fit5)
sigma <- sigma(fit5)

## Calculate Mallows's Cp statistic for all 6 models
Cp1 = Cp(fit1, sigma)
Cp2 = Cp(fit2, sigma)
Cp3 = Cp(fit3, sigma)
Cp4 = Cp(fit4, sigma)
Cp5 = Cp(fit5, sigma)
Cpg1 = Cp(g1, sigma)
  
  
###################################################
### TASK e)
###################################################
require(earth)
m1 <- earth(form1, d.ozone.e, degree = 1)
summary(m1)


###################################################
### TASK f)
###################################################
set.seed(1)
n <- nrow(d.ozone.e)
K <- 10
folds <- sample(cut(seq(1, n), breaks = K, labels = FALSE), replace = FALSE)

fold.error.m1 <- numeric(K)
fold.error.m2 <- numeric(K)
fold.error.m3 <- numeric(K)
fold.error.g1 <- numeric(K)

for (i in 1:K) {
  test.ind <- which(folds == i)
  df.train <- d.ozone.e[-test.ind, ]
  df.test <- d.ozone.e[test.ind, ]
  
  m1i <- earth(formula = form1, data = df.train, degree = 1)

  yhat.m1 <- predict(m1i, newdata = df.test, type = "response")

  fold.error.m1[i] <- mean((yhat.m1 - df.test$logupo3) ** 2)

  m2i <- earth(formula = form1, data = df.train, degree = 2)

  yhat.m2 <- predict(m2i, newdata = df.test, type = "response")

  fold.error.m2[i] <- mean((yhat.m2 - df.test$logupo3) ** 2)

  m3i <- earth(formula = form1, data = df.train, degree = 3)

  yhat.m3 <- predict(m3i, newdata = df.test, type = "response")

  fold.error.m3[i] <- mean((yhat.m3 - df.test$logupo3) ** 2)

  g1i <- gam(formula = gamForm, data = df.train)

  yhat.g1 <- predict(g1i, newdata = df.test, type = "response")

  fold.error.g1[i] <- mean((yhat.g1 - df.test$logupo3) ** 2)
}

c(m1 = mean(fold.error.m1), m2 = mean(fold.error.m2), m3 = mean(fold.error.m3),
  g1 = mean(fold.error.g1))