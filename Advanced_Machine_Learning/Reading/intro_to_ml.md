model selection: use single test set to verify multiple training algorithms
- not work! test set should be random
  - use multiple of them -> k-fold
  - small k will overfit to the test set, overfitting to test set, underfitting to training set
  - large k will lead to better performance, but at the cost of computational efficiency

ridge regression
- standardization, to avoid the influence of scale of training data

feature selection
- greddy forward or backward selection
  - start with empty/full set, add/remove some feature step by step
  - backward can handle dependent features
- for linear models, feature selection is sparsity
  - L1 usually wîll do the trick LASSO

kernel
- no need to calculate features, we only care about tzhe inner product of them
- PSD matrices
- kernel engineering
- kernelize problems: as long as the weight is in data span, we assume w = sum of ax, then substitute all w with this linear representation, and we are good
  - kernel PCA, refer to note for details
- usually do not overfit, kernel will map data into high dimentional space
  - add a regularizer if overfits

class imbalance
- cost sensitive loss function, large weight for class with fewer examples
- precision, recall, F1 score(harmonic mean of prec and rec)
- ROC curve
 
prediction error = bias^2 + varaince + noise
- bias: risk more than a best achievable model
- variance: risk from the model from limited data
- noise: risk by an optimal model, is constant
- ridge regression -> MAP estimation given a prior of w ~ N(0, some sigma)

regression with statistical background -> logistic regression, cross-entropy loss

Bayesian decision theory
- given input x, choose act a s.t. the expected outcome C(y, a) are minimized given conditional probability p(y | x)
- can give an uncertain output if confidence is not enough

discriminative modeling
- estimate P(y| X), can not detect outliers, no modeling of P(X)
- while generative modeling model P(y, X)
  - estimate prior on labels P(y), estimate P(X | y), then obtain P(y | X)
  - naive bayes model, model class label from categorical variable, model features as conditionally independent given y
    - P(x_i | y) should be specified
    - still overconfident, from the conditional independence assumption
    - discrete naive bayes: exponentially parameters, overfit
      - Beta prior: conjugate prior
