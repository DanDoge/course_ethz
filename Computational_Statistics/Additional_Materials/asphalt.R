url <- "http://stat.ethz.ch/Teaching/Datasets/asphalt.dat"
d.asphalt <- read.table(url, header = TRUE)
asphalt1 <-
  data.frame(LOGRUT = log(d.asphalt[,"RUT"]),
             LOGVISC= log(d.asphalt[,"VISC"]),
             d.asphalt[, 2:6]) # the rest
# log transform of response and two covariates
linearModel <- lm(LOGRUT ~ . , data = asphalt1)
summary(linearModel)



# calculate it manually
# X has an intercept, first column of aspahlt1 is response
X <- cbind(rep(1, 31), as.matrix(asphalt1[,-1]))
Y <- asphalt1[,1]
# formulae from least squares theory
beta.hat <- solve(crossprod(X)) %*% t(X) %*% Y
Y.hat <- X %*% beta.hat
r <- Y - Y.hat
sigma.hat <- sqrt(sum(r^2) / (nrow(X) - ncol(X)))
sigma.beta <- sigma.hat * sqrt(diag(solve(crossprod(X))))
