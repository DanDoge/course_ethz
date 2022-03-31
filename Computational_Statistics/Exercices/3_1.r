# b
set.seed(79)
num_rep <- 200
bandwidths <- c(as.list(2^seq(-5, 1, 0.2)), "sj")
results_mat <- matrix(nrow = 32, ncol = num_rep)

xpts <- seq(-1, 5, 0.1)
dmix <- 0.2 * dnorm(xpts, mean = 0, sd = sqrt(0.01)) + 0.8 * dnorm(xpts, mean = 2, sd = 1)

rmix <- function(n) {
    data <- ifelse(runif(n, min = 0, max = 1) < 0.2,
    rnorm(n, mean = 0, sd = sqrt(0.01)),
    rnorm(n, mean = 2, sd = 1))
}

for (rep in 1:num_rep) {
    data <- rmix(100)
    for (idx_bw in seq_along(bandwidths)) {
        ke <- density(data, bw = bandwidths[[idx_bw]],
        kernel = "gaussian", n = 61, from = -1, to = 5)

        results_mat[idx_bw, rep] <- mean((ke$y - dmix)^2)
    }
}

print(apply(results_mat, 1, mean))


for (idx_bw in 1:32) {
    for (rep in 1:num_rep) {
        for (i in 1:100) {
            p <- runif(1, min = 0, max = 1)
            if (p < 0.2) {
                data[i] <- rnorm(1, mean = 0, sd = sqrt(0.01))
            } else {
                data[i] <- rnorm(1, mean = 2, sd = 1)
            }
        }
        ke <- density(data, bw = bandwidths[[idx_bw]]
        , n = 61, from = -1, to = 5, kernel = "epanechnikov")

        results_mat[idx_bw, rep] <- mean((ke$y - dmix)^2)
    }
}

print(rowMeans(results_mat))

# for llh, use new data
for (idx_bw in 1:31) {
    for (rep in 1:num_rep) {
        for (i in 1:100) {
            p <- runif(1, min = 0, max = 1)
            if (p < 0.2) {
                data[i] <- rnorm(1, mean = 0, sd = sqrt(0.01))
            } else {
                data[i] <- rnorm(1, mean = 2, sd = 1)
            }
        }
        ke <- density(data, bw = bandwidths[[idx_bw]]
        , n = 61, from = -1, to = 5)

        for (i in 1:100) {
            p <- runif(1, min = 0, max = 1)
            if (p < 0.2) {
                data[i] <- rnorm(1, mean = 0, sd = sqrt(0.01))
            } else {
                data[i] <- rnorm(1, mean = 2, sd = 1)
            }
        }
        estidens <- approxfun(ke$x, ke$y, rule = 2, method = "linear")
        # it matters to set rule=2 and method="linear"
        results_mat[idx_bw, rep] <- mean(log(estidens(data) + 1e-7))
    }
}

print(rowMeans(results_mat))

for (idx_bw in 1:31) {
    for (rep in 1:num_rep) {
        for (i in 1:100) {
            p <- runif(1, min = 0, max = 1)
            if (p < 0.2) {
                data[i] <- rnorm(1, mean = 0, sd = sqrt(0.01))
            } else {
                data[i] <- rnorm(1, mean = 2, sd = 1)
            }
        }
        ke <- density(data, bw = bandwidths[[idx_bw]]
        , n = 61, from = -1, to = 5, kernel = "epanechnikov")

        results_mat[idx_bw, rep] <- mean(dmix * log(ke$y))
    }
}

print(rowMeans(results_mat))
