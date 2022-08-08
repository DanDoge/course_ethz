banana = read.csv("./Computational_Statistics/Exercices/banana.dat")
banana$y = (banana$Y + 3) / 2

require(rpart)

bagging <- function(B, data){
    trees = list()
    for(i in 1:B){
        idx = sample(nrow(data), nrow(data), replace = TRUE)
        trees = append(trees, list(rpart(y ~ X1 + X2, data[idx, ])))
    }
    trees
}

baggpred= matrix(nrow=nrow(banana), ncol=50)
for(j in 1:50){
    B = 1
    idx = sample(nrow(banana), 100, replace = FALSE)
    bagtree = bagging(B, banana[idx, ])

    pred = matrix(nrow=nrow(banana), ncol=B)
    for(i in 1:B){
        pred[, i] = predict(bagtree[[i]], banana)
    }
    baggpred[, j] = apply(pred, 1, mean)
}

print(mean(apply(baggpred, 1, sd)))