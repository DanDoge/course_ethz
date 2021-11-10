### GPML Chapter 2.

gaussian process: a distribution over functions
- start at weight space

assume f(x) = w^T x, y = f(x) + epsilon
- posterior by completing the square, done
- prediction distribution: f = w^T x, also gaussian, done
- observation: prediction + noise, gaussian, done

proj to high dim space: replace all X with phi(X)
- also enables kernel trick

function space view
- Gaussian process is a collection of random variables, any finite number of them have a joint Gaussian distribution
- defined by its mean function and cov function
  - m(x) = E f(x)
  - k(x1, x2) = E (f(x1) - m(x1))(f(x2) - m(x2))
  - then f(x) ~ GP(m(x), k(x1, x2))
- consistency requirement / marginalization property
  - if GP specifies (y1, y2) ~ N(mu, Sigma) -> y1 ~ N(mu1, Sigma11)
  - examination on a large set does not affect the small set
- example: for the above stated BLR
  - E f(x) = 0 (just by subtract the mean)
  - k(x1, x2) = x1 Sigma x2
- now consider cov function of the form k(x1, x2) = exp(-0.5 (x1 - x2)^2)
  - marge cov if the points are near
  - Squared Exponential cov function corresponds to an infinite number of basis function for BLR
- the specification of cov function defines a distribution over functions, wait and see
  - GP prior f ~ N(0, Sigma)
  - where we have no idea what value the points at training samples will eval to 
  - given the training samples, we narrow down the space f can be sampled from: at the training points, f(x) should be close to the training value
  - in fact, the prediction is given by conditioning the joint distribution on training points, given the train/test cov matrix
  - for prediction with noisy labels, add a sigma^2 I to the diag of cov matrix
    - this can also be viewed as a posterior mean and cov function
  - note that the prediction function(w/o noise) can also be viewed as a linear conbination of kenrel values
  - marginal likelihood: integrate out f to get f(y | X)
    - which can also be derived from y ~ N(0, K + sigma^2 I)

hyperparameters of the cov functions
- e.g. in the SE cov function, there are length-scale l, signal variance sigma_f, and noise variance sigma_n
  - length-scale: shorter leads to larger cov between the points, longer means a slowly varying function will be learned(more relation ship assumed in neighboring points)
  - intuitively, signal variance will scale the plot in y-dim while the length-scale will scale it in x-dim
  - arguments for signal variance and noise variance are similar to BLR, problem: how does the noise and prior variance in BLR relate to GP
    - large noise variance will regulates weight more and lead to a more flat regression(inteprating all data points to noise and stick to prior), and low noise variance will degenerate to regular linear regression
    - large prior variance will means the prior has little effect for the regression, and vice versa

decision theory and regression
- define a loss function, which has nothing to do with density estimation
- then min the expected risk w.r.t. the final output, not the model parameters

replace MSE with SMSE, where each feature is normalized s.t. guessing the mean of targets will have a loss of 1
- NLL can also be normalized by subtracting a gaussian ll from the train mean and variance data

another view of GP
- GP aims to reconstruct the underlying signal by removing noise
  - linear smoother
- SVD on prediction mean
  - f = h^T y, where h is the weight function, outputs the weight applied to y for predicting target at point x
  - equivalent kernel: suppose there are infinite observations on the x-axis -> we have a infinite dim kernel vector -> kernel function
    - so you see the EK here is only derived from the SE kernel, regardless of training data
  - more observations make a more frequent kernel

### GPML Chapter 4.

stationary -> invariant to translations
- while isotropic is invariant to rigid transformations
  - aka. radial basis functions
- network as a kernel function: some translation needed
  - but still not a valid cov. function

eigendecomposition of kernel functions
- w.r.t. integration on some measure
- a degenerate kernel will finite rank(number of non zero eigen values)
- and thus the nyström approximation of the kernel function

kernel for structure data
- string kernel: in terms of occurance of some sub string
- fisher kernel: define a generative model, and take the derivative

### GPML Chapter 3.

genertive model for classification p(x | y)
- note that a strong prior is taken on conditional density and may not work well
- while in discriminative case, we can turn a regression output to class distributions
  - by using a response function, e.g. logistic regression, or any CDF in general

decision theory
- cost function: in medical cases, it can be asymmetric
- rejection function: do not predict if we are uncertain for all classes
  - or require the gap between first and second most possible class to exceed some threshold

recall logistic regression
- p(y | x, w) = sigmoid(y xt w)
- assume gaussian prior on weights, we have log posterior
  - not analytical, but concave
  - note that a linearly separable dataset will lead to a infinity w 
    - predict all correct labels with prob ~1.
  - for ill-conditioned cases, e.g. linearly dependent
    - then multiple solutions exist: w = Aw, suppose x = Ax

GP for logistic regression
- two steps
  - p(f_new) = int of p(f_new | f_post) p(f_post | data) d f_post
  - pred_new = int of sigmoid(f_new) p(f_new) d f_new
  - and both of them are intractable
- laplace approx
  - q(f_post | data) = N(mu, sigma), where mu is argmax p(f_post | data), and sigma is the inverse of hessian
  - note p(f_post | data) = p(y | f)p(f | X), with the latter being N(0, K), is the prior distribution
    - take the log, set to zero, we get a self-consistent function f = K(d log(p(y | f)) df)
    - apply Newton's method
  - we have p(f_new) being a Gaussian with mu k(x_new) d log(p(y | f)) df
    - note points that are well explained(with derivative small) have smaller impact towards to prediction, and points near the decision boundary(with high derivatives) will affect the predictions most
      - similar to SVM
  - variance is then the sum of two Gaussians, note the p = int p q is a convolution of Gaussians
  - and then integrate to find prediction label
    - note for binary cases, MAP prediction(sigmoid(E f)) and true averaged prediction(E sigmoid(f)) are identical
      - in case of the confidence is of no interest, and only a prediction is needed
      - in case of Gaussian sigmoid function, it is again tractable
  - marginal likelihood can also be approximated using laplace method
- expectation propagation: what?

optimizing unknown noisy function
- and optimize estimate over some high dim. space
- problem, given noisy observation y = f(x) + eps
  - goal: max. sum of f(x)
  - metric: cumulative regret, not knowing max. f beforehead
    - an algorithm with lim r(t) = 0 is said to have no regret
  - modeling f as a GP
- approach: estimate the function globally well, then explore maximum points
  - measure a point by information gain: H(y) - H(y | f), randomness gained from knowing this point's value
    - greedy find new points
    - but in our case we only need f(x) to be large
      - only exploring points with large function value will get stuck in moval maxima quickly
      - conbined strategy: x = argmax mu(x) + beta sigma(x)
    - some hard math for the bounds