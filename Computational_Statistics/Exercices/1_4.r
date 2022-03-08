set.seed(21)
x <- seq(1, 40, 1)
rep = 100
slope <- c(rep)
for (i in 1:rep) {
    y   <- 2 * x + 1 + 5 * rnorm(length(x))
    reg <- lm(y ~ x)
    slope[i] <- summary(reg)$coefficients[2, 1]
}

par(mfrow=c(1,2))

hist(slope, freq =FALSE)
x_app <- cbind(rep(1, 40), x)
sd_beta <- sqrt(solve(t(x_app) %*% x_app)[2, 2] * 25)
print(sd_beta)
lines(seq(1.7,2.3,by=0.01),dnorm(seq(1.7,2.3,by=0.01),mean=2.,sd=sd_beta))

mean_slope <- mean(slope)
std_slope <- sd(slope)
print(mean_slope)
print(std_slope)


for (i in 1:rep) {
    y   <- 2 * x + 1 + 5 * (1-rchisq(length(x), df=1))/sqrt(2)
    reg <- lm(y ~ x)
    slope[i] <- summary(reg)$coefficients[2, 1]
}


hist(slope, freq =FALSE)
x_app <- cbind(rep(1, 40), x)
sd_beta <- sqrt(solve(t(x_app) %*% x_app)[2, 2] * 25)
print(sd_beta)
lines(seq(1.7,2.3,by=0.01),dnorm(seq(1.7,2.3,by=0.01),mean=2.,sd=sd_beta))

mean_slope <- mean(slope)
std_slope <- sd(slope)
print(mean_slope)
print(std_slope)