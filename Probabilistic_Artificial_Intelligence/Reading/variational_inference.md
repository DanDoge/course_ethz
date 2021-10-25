### review some papers on VI

BBVI
- only log likelihood required, MC estimate of gradients
- and various variance reduction methods apply
- optimize ELBO l(lambda) = E_q (log p(x, z) - log q(z)), i.e. KL(q || p)
  - which can be differentiated
- variance reduction
  - assume a mean field mdoel -> Rao-Blackwellization
  - control variate: find a function with some covariance
- step size: high learning rate for small variance(estimate of the gradient)
  - and address the scaling of parameters

scalable variational Gaussian process classification
- focus on incuding points in this paper
  - note the inducing points method implies a posterior on induced points
  - which can then be variational approximated
- not readable from 3.1 ...

### sampling from PRML

sample from unit Gaussian: some wield transformation
- then sample from Gaussian with custom Var -> Cholesky decomposition of Var

rejection sampling
- sample from a simple distribution q, accept wiht prob. p(.) / kq(.), where k is un-normalized
- piecewise exponential distribution

importance sampling
- for expectation -> approx p by q, and correct the weight by p / q
- q should be large where p is large

sampling-importance-resampling
- sample z_1...n from simple distribution q, then assign weights to each sample, then resample discrete samples from z_1...n

sampling to approximate E step in EM

MC
- draw samples from proposal distribution, suppose the (conditional) proposal distribution is symmetric, then acc w/ prob. min(1, p(new) / p(old))
  - for non-symmetrical cases, prob. acc = min(1, p(new)q(old|new) / p(old)q(new|old))
- MH can converges slowly with small length scale
- Gibbs: sample one coordinate conditioned on other variables
  - a special case of MH, with prob of acc === 1
  - over relaxation: with Gaussain conditional (note, this is a larger family of distribution than joint Gaussian e.g. exp(1 + x1^2)exp(1 + x2^2))