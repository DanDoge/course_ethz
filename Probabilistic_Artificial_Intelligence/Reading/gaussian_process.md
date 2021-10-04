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