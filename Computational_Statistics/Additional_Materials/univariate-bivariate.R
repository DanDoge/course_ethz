# generally
set.seed(0)
x1 <- -50:50
x2 = -x1 + rnorm(101)

y <- x1 + 2 * x2 + rnorm(101, sd = 3)

summary(lm(y ~ x1 + x2))

summary(lm(y ~ x1))


# orthogonal predictors
set.seed(0)
x1 <- -50:50
x2 <- c(0:49, 50, 49:0)

y <- x1 + 2 * x2 + rnorm(101, sd = 3)

summary(lm(y ~ x1 + x2))

summary(lm(y ~ x1))

summary(lm(y ~ x2))
