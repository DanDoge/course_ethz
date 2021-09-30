### all of statistics Ch. 9

moment estimator of parameters
- let moment equal sample moment
- the estimate exists, consistent, asymptotically Normal

MLE estimator
- consistent
  - converges in prob to the true value
- equivarient: if theta_n is MLE of theta, then g(theta_n) is the MLE of g(theta)
  - suppose the function g has an inverse
- asymptotically optimal: smallest variances for large samples
  - apprroximately normal and var can be derived analytically
    - approx. theta_n ~ N(theta, sqrt(1 / fisher_information(theta)))
  - optimality if the model is correct
- approximately the Bayes estimator

fisher information
- under certain conditions: - log f(X;theta)´second derivative w.r.t. theta, expectation w.r.t. X
- for n iid experiments, I_n = n I
- fisher information matrix: expection of Hessian

parametric bootstrap
- estimate params, sample data, get new estimates, estimate some statistical quantity