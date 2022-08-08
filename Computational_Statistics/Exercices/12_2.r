ozone <- read.table("http://stat.ethz.ch/Teaching/Datasets/ozone.dat", header = TRUE)

ozone$logupo3 <- log(ozone$upo3)
d.ozone <- subset(ozone, select = -upo3)
out <- 92
d.ozone.e <- d.ozone[-out,]

require(sfsmisc)
ff <- wrapFormula(logupo3 ~ ., data=d.ozone.e, wrapString="poly(*,degree=3)")
ff <- update(ff, logupo3 ~ . * . * .)
mm <- model.matrix(ff, data=d.ozone.e)

require(glmnet)
ridge <- glmnet(mm, d.ozone.e$logupo3, alpha=0)
lasso <- glmnet(mm, d.ozone.e$logupo3, alpha=1)

set.seed(1)
cv.eln <- cv.glmnet(mm, d.ozone.e$logupo3, alpha=0.5, nfolds=10)