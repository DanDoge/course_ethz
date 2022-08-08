### Code skeleton for Series 10

## b)

## load the data:
d.vehicle <- read.table("http://stat.ethz.ch/Teaching/Datasets/NDK/vehicle.dat",
                   header = TRUE)


## train a full grown tree:
require(rpart)
set.seed(10)
rp.veh <- rpart(Class ~ ., data = d.vehicle,
              control = rpart.control(cp = 0.0, minsplit = 30))


## nice package for plotting trees:
require(rpart.plot)
prp(rp.veh, extra=1, type=1, cex=0.9,
    box.col=c('pink', 'palegreen3',
              'lightsteelblue 2','lightgoldenrod 1')[rp.veh$frame$yval])



## d)
plotcp(rp.veh)
printcp(rp.veh)



## f)
misclass.sample <- function(data, ind.training, ind.test)
{
  tree <- rpart(Class ~ ., data = data[ind.training, ], 
                  control = rpart.control(cp = 0.0, minsplit = 30))

  ## choose optimal cp according to 1-std-error rule:
  cpTab <- tree$cptable
  min.ind <- which.min(cpTab[,"xerror"])
  min.lim <- cpTab[min.ind, "xerror"] + cpTab[min.ind, "xstd"]
  cp.opt  <- cpTab[(cpTab[,"xerror"] < min.lim), "CP"][1]

  ## prune the tree:
  prnd.tree <- prune.rpart(tree, cp=cp.opt)

  ## return missclassifcation error:
  mean(data$Class[ind.test] != predict(prnd.tree, data[ind.test, ], type="class"))
}



## CV-error:

cv.err <- function(data, ind){
  misclass.sample(data, (1:nrow(data))[-ind], ind)
}

cv.samples <- sapply(1:nrow(d.vehicle), cv.err, data = d.vehicle)
errcv <- mean(cv.samples)



## Bootstrap error:

B <- 1000
n <- nrow(d.vehicle)
boot.err <- function(data, ind) {
  misclass.sample(data, ind, 1:nrow(data))
}

boot.samples <- replicate(B, boot.err(d.vehicle, sample(n, n, replace=TRUE)))
errboot <- mean(boot.samples)



## Out-of-bootstrap-sample generalization error
oobs.sample <- function(data, ind) {
  misclass.sample(data, ind, (1:nrow(data))[-ind])
}

obs.samples <- replicate(B, oobs.sample(d.vehicle, sample(n, n, replace=TRUE)))
erroobs <- mean(obs.samples)



