n=50
set.seed(11)
sum = 0
for (idx in 1:100){
    x <- rnorm(n, 0, 1)
    y <- -2 + 1.5*x + rnorm(n, 0, 1)
    pol_x = poly(x, 2)
    reg <- lm(y ~ ., data=pol_x) # use this form to avoid naming issues
    x_new <- data.frame(predict(pol_x, 2))
    colnames(x_new) = c("1", "2")
    sum = sum + predict(reg, x_new)
}

load("./Computational_Statistics/Exercices/cars.dat")

cars_df$cost2 = cars_df$cost ** 2
reg = lm(repair ~ ., data=cars_df)   


df = cars_df
set.seed(22)
generate.bootstrap.data <- function(data){
  x <- data$cost
  y <- 2.1 + 2.2 * x - 0.2 * (x ** 2) + rnorm(length(x), sd=sqrt(0.6))
  return(data.frame(x=x, y=y))
}
B = 3000
thetastar = rep(NA, B)
for(i in 1:B){
  dset = generate.bootstrap.data(df)
  fit = lm(y ~ x + I(x ** 2), data=dset)
  thetastar[i] = fit$coef[3]
}
print(sd(thetastar))


set.seed(22)
generate.bootstrap.data.2 <- function(data){
  x <- data$cost
  residuals <- data$repair - 2.1 - 2.2 * data$cost + 0.2 * (data$cost ** 2)
  y <- 2.1 + 2.2 * x - 0.2 * (x ** 2) + sample(residuals, replace = T)
  return(data.frame(x=x, y=y))
}

B = 3000
thetastar = rep(NA, B)

for (i in 1:B){
  dset = generate.bootstrap.data.2(df)
  fit = lm(y ~ x + I(x ** 2), data=dset)
  thetastar[i] = fit$coef[3]
}
print(sd(thetastar))


load("./Computational_Statistics/Exercices/runners.dat")
reg = lm(formula = distance ~ as.factor(club) + height + weight, data = runners_df)

reg = lm(formula = distance ~ height + weight, data = runners_df)

rss = sum((reg$fitted - runners_df$distance) ** 2)

set.seed(22)
B = 5000
perm_test_statistic = rep(NA, B)
for(i in 1:B){
  new_distance = sample(runners_df$distance)
  reg = lm(formula = new_distance ~ height + weight, data = runners_df)
  perm_test_statistic[i] = sum((reg$fitted - new_distance) ** 2)
}

standard_deviation = sd(perm_test_statistic)

mean(perm_test_statistic < 1975)

load("./Computational_Statistics/Exercices/square.dat")

computeT <- function(points, rectangles){
  counts = rep(0, 5) #here we store the number of points contained in each rectangle
  for(i in 1:5){ #this iterates over rectangles
    counts[i] = sum(points$x > rectangles[i, ]$x1 & points$x < rectangles[i, ]$x2 & points$y > rectangles[i, ]$y1 & points$y < rectangles[i, ]$y2)
  } 
  # compute the expected number of points in each rectangle
  expected = 300 * (rectangles$x2 - rectangles$x1) * (rectangles$y2 - rectangles$y1)
  # compute the test statistic 
  T = max(abs(counts - expected))
  return(T)
}
# compute the test statistics on the given data
res = computeT(points, rectangles)


set.seed(22)
B = 400
test_statistic = rep(0, B)
for(k in 1:B){
  x <- runif(300)
  y <- runif(300)
  sim_points = data.frame(x=x, y=y) #this is a simulated set of points under the null hypothesis
  test_statistic[k] = computeT(sim_points, rectangles)
}
quantile = quantile(test_statistic, probs=0.9)
print(mean(test_statistic > 5))



library(glmnet)
library(ISLR)
data(Hitters)
Hitters=na.omit(Hitters)
x = model.matrix(Salary~., data=Hitters)
x = x[,-1]
y = Hitters$Salary
# define grid of lambda
grid.lambda=10^seq(from = 10, to = -2, length=100)
# define train and test
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2, replace=FALSE)   
test=(-train)  
# training data
x.train <- x[train,]
y.train <- y[train]
# test data
x.test <- x[test,]
y.test <- y[test]
fit = glmnet(x.train, y.train, alpha=1, lambda=100)

coef(fit)

set.seed(2020) 

fitcv = cv.glmnet(x.train, y.train, alpha=0, lambda=grid.lambda)

fit = glmnet(x.train, y.train, alpha=0, lambda=fitcv$lambda.min)

mean((predict(fit, x.test) - y.test) ** 2)

set.seed(2020) 

fitcv = cv.glmnet(x.train, y.train, alpha=1, lambda=grid.lambda)

fit = glmnet(x.train, y.train, alpha=1, lambda=fitcv$lambda.min)

mean((predict(fit, x.test) - y.test) ** 2)


library(randomForest)
library(MASS)
# splitting the data into training and testing data
set.seed(1)
subset<-sample(1:nrow(Boston), size = nrow(Boston) * 0.5, replace = F)
Boston.train<-Boston[subset,-14]
Boston.test<-Boston[-subset,-14]
y.train<-Boston[subset,14]
y.test<-Boston[-subset,14]

fit = randomForest(Boston.train, y.train, ntree=500, mtry=ncol(Boston.train))   
mean((fit$predicted - y.train) ** 2)

mean((predict(fit, Boston.test) - y.test) ** 2)


load('./Computational_Statistics/Exercices/position.dat')
n = 1000
nfolds = 10
fold_indicator = floor((1:1000 - 1) / 100) + 1 # create labels denoting which point is in which fold
for (j in 1:10){
    sse = 0 # here we will store the result for the sum of squared errors
    for(i in 1:nfolds){
    train = position_df[-which(fold_indicator == i), ]
    test = position_df[which(fold_indicator == i), ]
    
    fit <- lm(position ~ poly(time, j), data=train)
    predicted_positions <- predict(fit, test)
    sse = sse + sum((predicted_positions - test[, 1]) ** 2)
    }
    mse = sse / n
    print(mse)
}