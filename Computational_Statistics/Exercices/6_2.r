boogg <- c(17, 26, 12, 6, 12, 18, 10, 12, 26, 13, 13, 11, 12, 35, 7, 21, 44, 10, 21)

require(MASS)
require("boot")

fit.gamma <- fitdistr(boogg, "gamma")

hist(boogg, prob = TRUE)
lines(x = seq(10, 40, 5), y = dgamma(seq(10, 40, 5), shape=fit.gamma$estimate["shape"], rate=fit.gamma$estimate["rate"]))

ran.gen <- function(data, mle) {
    rgamma(length(data), shape = mle$estimate["shape"], rate = mle$estimate["rate"])
}

stat <- function(data) {
    quantile(data, .75)
}

boot.package <- boot(boogg, statistic = stat, sim = "parametric", R = 1000, ran.gen = ran.gen, mle = fitdistr(boogg, "gamma"))
print(boot.package)
