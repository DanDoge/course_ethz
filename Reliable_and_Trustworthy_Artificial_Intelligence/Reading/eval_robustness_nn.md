## Towards Evaluating the Robustness of Neural Networks

L-BFGS
- move C(x) = l to min. function

JSMA: jacobian based saliency map
- pick the pixel with most gradient, and change it

the infty norm only penalizes the largest entry in delta, and GD will oscillating between two suboptimal points
- replace with sum of delta - tao, with tao lowered each iteration
  - note that it is a sum not max