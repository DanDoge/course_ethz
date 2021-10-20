### PRML Ch. 6.4

2d GP -> gaussian random field

what about the noise level depends on x
- heteroscedastic
- introduce another gp to model noise, model ln noise(x)

GP in automatic relevance determination
- kernel = sum of eta_i (x1i - x2i)^2
- and optimize kernel, we get the weight on each feature

GP for classification
- regression + logistic function
  - sadly, not tractable
  - sampling / variational inference
  - laplace approximation: replace the binominal distributuion by a gaussian matching the mean and cov
    - find the mode by Newton method on derivative, and then eval the Hessian
    - assume all hidden value(before the logistic function) are jointly Gaussian, now only the dist of hidden value given the binary value need to approx.ed
    - again the kernel parameters need to be updated
      - again, the derivative is not tractable