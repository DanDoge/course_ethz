url <- "https://ww2.amstat.org/publications/jse/datasets/fruitfly.dat.txt"
data <- read.table(url)
data <- data[, c(-1, -6)]

names(data) <- c("partners", "type", "longevity", "thorax")
par(mfrow = c(3, 2))
plot(data$thorax, data$longevity, col = data$partners, pch = data$type)

data0 <- data[data$partners == 0, ]
plot(data0$thorax, data0$longevity, col = data$partners, pch = data$type)

data1 <- data[data$partners == 1, ]
plot(data1$thorax, data1$longevity, col = data$partners, pch = data$type)

data8 <- data[data$partners == 8, ]
plot(data8$thorax, data8$longevity, col = data$partners, pch = data$type)

p0 <- as.integer(data$partners == 0)
p1t0 <- as.integer(data$partners == 1 & data$type == 0)
p1t1 <- as.integer(data$partners == 1 & data$type == 1)
p8t0 <- as.integer(data$partners == 8 & data$type == 0)
p8t1 <- as.integer(data$partners == 8 & data$type == 1)

data_dummy <- cbind(data, p0, p1t0, p1t1, p8t0, p8t1)
boxplot(cbind(data_dummy[data_dummy$p0 == 1, ]$longevity,
            data_dummy[data_dummy$p1t0 == 1, ]$longevity,
            data_dummy[data_dummy$p1t1 == 1, ]$longevity,
            data_dummy[data_dummy$p8t0 == 1, ]$longevity,
            data_dummy[data_dummy$p8t1 == 1, ]$longevity)
)

print(summary(lm(thorax ~ p0 + p1t0 + p1t1 + p8t0 + p8t1, data_dummy)))

reg_wo <- lm(longevity ~ type, data1)
print(summary(reg_wo))

reg_w <- lm(longevity ~ type + thorax, data1)
print(summary(reg_w))

reg_full_fail <- lm(longevity ~ thorax
                + as.factor(partners) * as.factor(type), data)

print(summary(reg_full_fail)) # some NA here, and most var are not significant


reg_full <- lm(longevity ~ thorax + p1t0 + p1t1 + p8t0 + p8t1, data_dummy)
print(summary(reg_full))

reg_reduce <- lm(longevity ~
                thorax +
                I(p1t0 - p8t1) +
                I(p1t1 + p8t1) +
                I(p8t0 + p8t1), data_dummy)
print(summary(reg_reduce))

print(anova(reg_reduce, reg_full))