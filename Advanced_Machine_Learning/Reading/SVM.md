### PRML Ch.7

w.l.o.g., we scale w and b s.t. for all points t_n (w phi(x_n) + b) >= 1
- and there exists a point s.t. the equality holds
  - we optimize argmin |w|^2, (large w means a small margin(to get to a distance of 1))
  - (Lagrange) form a Lagrangian, take derivative w.r.t. w and b, substitute, we have
  L(a) = sum a_i - .5 sum sum a_i a_j t_i t_j k(x_i, x_j)
  - suppose the above equation is solved, we have the prediction function
  y(x) = sum a_i t_i k(x, x_i) + b
    - note only a proportion of points(support vectors) have a_i != 0
- in case of overalpping class distributions
  - introducing slack variables t y(x) >= 1 - eps
  - argmin C sum eps + .5 |w|^2
    - L(a) is identical, but under different constraints
      - a_i = 0, not support vector
      - a_i < C, lies on the margin
      - a_i = C, inside the margin
- SVM do not provide prob. -> train a logistic regression on top of y(x)
- multiclass SVM
  - one vs the rest: in case of an input being classified to multiple classes
    - prediction: y(x) = max y_k(x), but does different y_k share the same scale?
  - or train K(K-1)/2 SVMs, one vs one, and count the final votes
- SVM for regression
  - eps-insensitive error function: zero error with abs diff less than eps
  - introduce 2n slack variables, Lagrange, KKT
- learning theory
  - PAC learning: E[I(f(x) != t)] < eps, holds with prob > 1 - delta
  - while parctically, PAC tends to overestimate the number of samples needed for accurate learning

RVM
- pretty much looks like GP
  - equivalent to GP, as per wikipedia

SVM for structural output
- problems: huge number of output classes, refined notion of error
  - 1 v.s. n classifier has no generalization across (possibly infinite) outputs
    - joint feature map from (X, y)
  - exponentially growing label y
    - decompose y into nonoverlapping parts y_1...n, and such decomposition is also respeacted in the joint feature map
  - loss function
    - min w + some slack, s.t. w(Phi_y - Phi_other_y) >= dist(y, other_y) - slack
  - efficinet training via cutting-plane