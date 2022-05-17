heart <- read.table("http://stat.ethz.ch/Teaching/Datasets/heart.dat", header = TRUE)

neg.ll <- function(beta, data) {
    llh = 0
    for (i in 1:nrow(data)) {
        g = beta[1] + beta[2] * data$age[i]
        llh = llh + log(choose(data$m[i], data$N[i])) + data$N[i] * g - data$m[i] * log(1 + exp(g))
    }
    -llh
}

beta0.grid <- seq(-10, 10, length = 101)
beta1.grid <- seq(-1, 1, length = 101)

neg.ll.values <- matrix(nrow = 101, ncol = 101)

for (b0 in 1:101) {
    for (b1 in 1:101) {
        neg.ll.values[b0, b1] <- neg.ll(c(beta0.grid[b0], beta1.grid[b1]), heart)
    }
}

contour(beta0.grid, beta1.grid, neg.ll.values, nlevels = 10)

fit <- glm(cbind(N, m - N) ~ age, family = binomial, data = heart)

print(fit)

print(optim(c(0, 0), neg.ll, data = heart))

predict(fit, newdata = data.frame(age = 20:69), type = "response")