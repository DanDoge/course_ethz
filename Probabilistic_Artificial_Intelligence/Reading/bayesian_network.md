### weight uncertainty in neural networks

neural network as point estimation of parameters
- with some regularization methods
- for BNN, min variational free energy: sum of divergence from prior and expected nll of data
  - approx.ed by sample from the weight distribution
    - and each layer's parameters are mean and variance(assume a Gaussian prior)
  - assume diagnoal Gaussian -> reparameterization trick
  - emperically, emperical Bayes does not work: update prior parameter is more easy than to move network parameters
    - new prior: mixture of two zero mean Gaussian
  - reweighting each batch: early batches move the data nll, and later batches preserve the prior

### on calibration of modern neural networks

by calibration it means the output prob should match the real likelihood
- modern(deeper) networks are not well-calibrated
  - confidence exceeds the accuracy
- perfect calibration p(y | p_y = p) = p
  - e.g. predict a class prob of 0.8 will ensure the x is 0.8 probable of being a specific class
  - and thus the difference of area will be expected calibration error
  - also define maximum calibration error for high-risk applications
- reasons of overconfidence
  - depth and width both increase calibration error
  - proper weight decay will lower calibration error
- nll can be used as a indirect measure of calibration

### dropout as Bayesian approximation

dropout for every layer
- equivalent to a deep Gaussian process(marginnalised over cov. function parameters)
- adding a set of binary variables for each node
- variational distribution is by setting weight's column to zero with prob p
  - min KL loss from MC