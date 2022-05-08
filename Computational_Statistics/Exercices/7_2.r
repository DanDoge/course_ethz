### Code skeleton for Series 7, task 2

## Read in dataset, set seed, load package
Iris <- iris[,c("Petal.Length", "Petal.Width", "Species")]
grIris <- as.integer(Iris[, "Species"])
set.seed(16)
library(MASS)

## Read n
n <- nrow(Iris)

## Utility functiom for plotting boundaries
predplot <- function(object, x, gr = grIris, main = "", lines.only = FALSE,
                     len = 42, colcont = "black", ...)
{
  ##  gr : the true grouping/class vector
  stopifnot(length(gr) == nrow(x))
  xp <- seq(min(x[, 1]), max(x[, 1]), length = len)
  yp <- seq(min(x[, 2]), max(x[, 2]), length = len)
  grid <- expand.grid(xp, yp)
  colnames(grid) <- colnames(x)[-3]
  Z <- predict(object, grid, ...)
  zp <- as.numeric(Z$class)
  zp <- Z$post[, 3] - pmax(Z$post[, 2], Z$post[, 1])
  if(!lines.only)
    plot(x[,1], x[,2], col = gr, pch = gr,
         main = main, xlab = colnames(x)[1], ylab = colnames(x)[2])
  contour(xp, yp, matrix(zp, len),
          add = TRUE, levels = 0, drawlabels = FALSE, col = colcont)
  zp <- Z$post[, 1] - pmax(Z$post[, 2], Z$post[, 3])
  contour(xp, yp, matrix(zp, len),
          add = TRUE, levels = 0, drawlabels = FALSE, col = colcont)
}
## Bootstrap size
B <- 1000




###################################################
### TASK a)
###################################################

## Use function lda to fit data
class_lda <- lda(x = Iris[, -3], grouping = grIris)

## Use function predplot to plot the boundaries
predplot(class_lda, Iris, main = "Classification with LDA")

## Use function qda to fit data
class_qda <- qda(x = Iris[, -3], grouping = grIris)

## Use function predplot to plot the boundaries
predplot(class_qda, Iris, main = "Classification with QDA")


###################################################
### TASKS b)
###################################################

## Create a random index matrix with either functions sample or sample.int to generate bootstrap
## Each column corresponds to the n indices of one bootstrap sample
index <- matrix(sample.int(n, size = n * B, replace = TRUE), nrow=n, ncol=B)

## Initialize the list for LDA and QDA fits
fit_lda <- vector("list", B)
fit_qda <- vector("list", B)


## Use both methods on the bootstrap samples
for(i in 1:B) {
  ind <- index[, i]
  fit_lda[[i]] <- lda(x = Iris[ind, -3], grouping = grIris[ind])
  fit_qda[[i]] <- qda(x = Iris[ind, -3], grouping = grIris[ind])
}

## Initialize the mu_hat bootstrap estimates
mu_hat_1 <- mu_hat_2 <- mu_hat_3 <- matrix(0, ncol = B, nrow = 2)

## Determine the mu_hat bootstrap estimates

for(i in 1:B){
  ## Hint: look at fit_lda[[1]] and see how to extract the means
  mu_hat_all <- fit_lda[[i]]$means
  mu_hat_1[, i] <- mu_hat_all[1,]
  mu_hat_2[, i] <- mu_hat_all[2,]
  mu_hat_3[, i] <- mu_hat_all[3,]
}

## Plot the bootstrapped estimators
## define a suitable plotting range
xmin <- min(mu_hat_1[1,], mu_hat_2[1,], mu_hat_3[1,])
xmax <- max(mu_hat_1[1,], mu_hat_2[1,], mu_hat_3[1,])
ymin <- min(mu_hat_1[2,], mu_hat_2[2,], mu_hat_3[2,])
ymax <- max(mu_hat_1[2,], mu_hat_2[2,], mu_hat_3[2,])
## plot the estimated mean of each group
plot(mu_hat_1[1,], mu_hat_1[2,], xlim = c(xmin, xmax), ylim = c(ymin, ymax),
     xlab = colnames(Iris)[1], ylab = colnames(Iris)[2], pch = 4,
     main = "Bootstrap samples")
points(mu_hat_2[1,], mu_hat_2[2,], col = 2, pch = 4)
points(mu_hat_3[1,], mu_hat_3[2,], col = 3, pch = 4)


###################################################
### TASK c)
###################################################

## Plot the bootstrapped boundaries estimates with LDA
predplot(class_lda, Iris,
         main = "Bootstrapped boundaries estimates with LDA")
for(i in 1:B){
  fit <- fit_lda[[i]]
  predplot(fit, Iris, lines.only = TRUE, colcont = adjustcolor("gray", 0.25))
}



## Plot the bootstrapped boundaries estimates with QDA
predplot(class_qda, Iris,
         main= "Bootstrapped boundaries estimates with QDA")
for(i in 1:B){
  fit <- fit_qda[[i]]
  predplot(fit, Iris, lines.only = TRUE, colcont = adjustcolor("gray", 0.25))
}

###################################################
### TASK d)
###################################################


## write your own LOOCV code

cnt_lda = 0
cnt_qda = 0
for (i in 1:n){
  fit_lda_loocv <- lda(x = Iris[-i, -3], grouping = grIris[-i])
  cnt_lda = cnt_lda + as.integer(predict(fit_lda_loocv, Iris[i, -3])$class != grIris[i])
  fit_qda_loocv <- qda(x = Iris[-i, -3], grouping = grIris[-i])
  cnt_qda = cnt_qda + as.integer(predict(fit_qda_loocv, Iris[i, -3])$class != grIris[i])
}
print(cnt_lda)
print(cnt_qda)
