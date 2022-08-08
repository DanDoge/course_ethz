## looking at lecture r codes for now, refer to exercise later

### w1

reg = lm(y ~ ., data = data)
summary(reg)
- residuals: difference btn. prediction and actural value
- coef.s
  - std. error: residual standard error / sqrt(sum of square of x)
- residual std. err: SSE / (n - p), p includes intercepts
- multiple r-squared: sum (y - mean_y)^2 - sum(y - prediction)^2 / sum(y - mean_y)^2
- adj.ed r^2: dof of sum (y - mean_y)^2 n-1, sum(y - prediction)^2: n - p

rep(a, b): aaaaa
cbind/rbind: combine by col or row
crossprod: t(X) %*% X
solve(a, b=I): return a %*% x = b
diag(x): return diagonals as a vector
predict(interval="confidence" or "prediction")

### w2

dt pt qt rt: density, distribution function, quantile function, random generation for t dist.
- pt(quantile, df, lower.tail=TRUE, log.p=FALSE)
- same for pnorm, rnorm
- and for runif
nrow, ncol
matrix(data, nrol, ncol)
sample(x, size, replace=FALSE)
apply(x, MARGIN, FUN): margin=1 row, 2 col, FUN: sd, sum, ...

### w3

seq(st, ed, length)
hist(x, breaks=number of bins, freq=TRUE)
density(x, bw, kernel)
approxfun(x, y, rule=2, method="linear")
- like approxfun(densityhat$x, densityhat$y)
- and sample from it can be done by approxfun(cumsum(densityhat$y / sum(densityhar$y)), densityhat$x)
which.max

### w4

library() # install package
data() # dataset
which(is.na())
ksmooth(x, y, kernel, bandwidth)
sp = smooth.spline()
predict(sp, x)

### w6

numeric(length)

### w7

aggregate(X[train,],by=list(y=Y), FUN=mean)
sweep(X,2,as.numeric(mu[j,-1]),FUN="-")
table: for confusion matrix

### w8

chol: chol factorization of PSD matrix
order: literally
smooth.spline

### w11

rpart


## exercises

### s1

set.seed()
numeric() # initialize a vector
coefficients(lm_obj)

### s2

pairs() # matrix of scatter plot
names(data) <-  c(foobar)
range() # returns range
anova(lm1, lm2) # to test the difference between two models
use as.factor() for categorial variables
- also we can say f1*f2 to get higher order interaction among these
group variables by I(v1 + v2)
- and then use anova for significance test
for lm models
- plot(lm_obj, which=)
  - 1: TA plot/ residuals/fitted plot
  - 2: normal qq plot
  - 3: scale location / standardized residual/fitted
array[-c(foo, bar)], to remove multiple row/cols

### s3

2^seq(-5, 1, 0.2)

### s4

plot.ts: time series
loess: local ploynomial regression
- fitted$trace.hat
- predict(loess, new_data=)
smooth.spline: smoothing splines
- predict(ss, x=)
ksmooth for kernel smoother
- ksmooth$y for fitted values
glkerns/lokerns(x, y, x.out)
- fitted from obj$est

### s5

real.table
sort indices: reg <- reg[sort.list(reg$x), ]
sapply
mean(trim)
boot.ci()

### s6

require("MASS")
fitdistr(data, "gamma")
quantile(data, c(st, ed))
- note for normal quantiles, we only replace quantile with normal ones in **reversed CI**

### s7

library(MASS)
- lda(), predict(lda_obj, )
- same for qda
fit logistic regression for binomial distribution
- N ~ binomial(m, pi(x))
- glm(cbind(N, m - N) ~ x, family = binomial, data)
  - linear logistic regression can directly done using glm(y ~ ., data, family="binomial")
or directly optimize nll
- optim(starting point, neg.ll, data)

### s8

require(ROCR)
- perd = prediction(fit$fitted.values, d$labels)
- then use pref = performance(pred, "tpr", "fpr")
- then plot(pred) for ROC curve

require(sfsmisc)
- for wrapFormula(y ~ ., data=data, wrapString="poly(*,degree=2)")
- by default s(*), then require(mgcv) we can use gam() to fit an additive model

require(earth)
- for MARS, earth(formula=y ~ ., data, degree=1)
- predict(earth_obj, newdata, type="response")

for k-fold cv
- folds <- sample(cut(seq(1, n), breaks = K, labels = FALSE), replace = FALSE)
- then each fold in folds is a test.ind

cor, cov, var

### s10

for nicely plot a tree
- require(rpart.plot), prp(tree)
the 1-se error is from cv-error
prune.rpart(full_tree, cp=cp.opt) for a pruned tree

### s12

some notes
- cubic penalized regression: regression that involves x^3 --> in warpForluma, degree=3
- in glmnet the 1-std rule means search a larger lambda(more regularized one, more pruned in tree's case)

attributes 
confint(fit) for all conf inverval for params

glm for logistic regression: family = "binomial"

get prob: prediction(fit$fitted.values, labels = as.factor(data$y))
- works only the training data

get log odds: predict(fit, newdata = data), which is fit$fitted.values

### R card

str(a), internal structure of a

x[x %in% c("foo", "bar")]

%*%