banana = read.csv("./Computational_Statistics/Exercices/banana.dat")
banana$y = (banana$Y + 3) / 2

require(rpart)

boosting = function(eta, data){
    prediction = rep(0, nrow(data))
    for(i in 1:100){
        new_data = data 
        new_data$y = data$y - prediction 
        tree = rpart(y ~ X1 + X2, new_data, control = rpart.control(maxdepth = 2))
        prediction = prediction + eta * predict(tree, data)
        print(mean((prediction - data$y) ** 2))
    }
}

boosting(0.01, banana)