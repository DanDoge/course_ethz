bmwr <- scan("http://stat.ethz.ch/Teaching/Datasets/bmw.dat")

p0 <- 40

p <- cumsum(bmwr) + p0

x <- rep(0, length(p))

x[1] <- log(p[1] / 40)

for (i in 2:length(x)) {
    x[i] <- log(p[i] / p[i - 1])
}

y <- x ** 2

x_model <- x[-length(x)]
y_model <- y[-1]

time <- 1:length(x_model)

ox <- order(x_model)

data <- data.frame(x = x_model, y = y_model)

loc_poly <- loess(y ~ x, data)

par(mfrow = c(4, 2))
plot(x_model, y_model)
lines(x_model[ox], fitted(loc_poly)[ox])

plot(time, y_model)
lines(time, fitted(loc_poly))

smo_spi <- smooth.spline(x_model, y_model, df = loc_poly$trace.hat)

plot(x_model, y_model)
lines(x_model[ox], fitted(smo_spi)[ox])

plot(time, y_model)
lines(time, fitted(smo_spi))

ksmo <- ksmooth(x_model, y_model, bandwidth = 0.16, x.points = x_model)

plot(x_model, y_model)
lines(ksmo$x, ksmo$y)

plot(time, y_model)
lines(time, ksmo$y[order(ox)])

# how to check model assumptions

library(lokern)
glo <- glkerns(x_model, y_model, hetero = TRUE)

plot(x_model, y_model)
lines(x_model[ox], fitted(glo)[ox])

loc <- lokerns(x_model, y_model, hetero = TRUE)

plot(x_model, y_model)
lines(x_model[ox], fitted(loc)[ox])
lines(loc$x.out, loc$bandwidth)