url <- "https://raw.githubusercontent.com/jawj/coffeestats/master/lifeexp.dat"
data <- read.table(url, sep = "\t", header = T, row.names = 1)
data <- data[, c("LifeExp", "People.per.TV", "People.per.Dr")]

print(rownames(data[order(data$LifeExp, decreasing =  TRUE)[1:3], ]))
print(rownames(data[order(data$People.per.TV, decreasing = TRUE)[1:3], ]))
print(rownames(data[order(data$People.per.Dr, decreasing = TRUE)[1:3], ]))

data_comp <- data[complete.cases(data), ]

reg <- lm(LifeExp ~ log2(People.per.Dr) + log2(People.per.TV), data_comp)
print(summary(reg))

new_data <- data.frame(log2(3000), log2(50))
names(new_data) <- c("People.per.Dr", "People.per.TV")
print(predict(reg, new_data, interval = "confidence"))
print(predict(reg, new_data, interval = "prediction"))

par(mfrow = c(3, 2))
plot(reg, which = 1)
plot(reg, which = 2)
plot(reg, which = 3)
plot(reg, which = 4)
plot(reg, which = 5)

reg_new <- lm(LifeExp ~ log2(People.per.Dr) + log2(People.per.TV)
            , data_comp[!row.names(data_comp) %in% c("Korea.North", "Sudan"), ])
print(summary(reg_new))
print(predict(reg_new, new_data, interval = "confidence"))
print(predict(reg_new, new_data, interval = "prediction"))