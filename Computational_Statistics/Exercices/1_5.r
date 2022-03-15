airline <- scan("http://stat.ethz.ch/Teaching/Datasets/airline.dat")

f1 <- seq(1, 144, 1)
f2 <- rep(c(1, rep(0, 11)), 12)
f3 <- rep(c(rep(0, 1), 1, rep(0, 10)), 12)
f4 <- rep(c(rep(0, 2), 1, rep(0, 9)), 12)
f5 <- rep(c(rep(0, 3), 1, rep(0, 8)), 12)
f6 <- rep(c(rep(0, 4), 1, rep(0, 7)), 12)
f7 <- rep(c(rep(0, 5), 1, rep(0, 6)), 12)
f8 <- rep(c(rep(0, 6), 1, rep(0, 5)), 12)
f9 <- rep(c(rep(0, 7), 1, rep(0, 4)), 12)
f10 <- rep(c(rep(0, 8), 1, rep(0, 3)), 12)
f11 <- rep(c(rep(0, 9), 1, rep(0, 2)), 12)
f12 <- rep(c(rep(0, 10), 1, rep(0, 1)), 12)
f13 <- rep(c(rep(0, 11), 1), 12)

reg <- lm(log(airline) ~ f1 + f2 + f3 + f4 + f5 + f6 + f7 + f8 + f9 + f10 + f11 + f12 + f13 - 1)

plot(reg, which=1)

