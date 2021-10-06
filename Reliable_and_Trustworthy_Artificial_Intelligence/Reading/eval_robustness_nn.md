## Towards Evaluating the Robustness of Neural Networks

L-BFGS
- move C(x) = l to min. function

JSMA: jacobian based saliency map
- pick the pixel with most gradient, and change it

deepfool
- assuming the nn is linear, find the hyperplane and mapping to the analytical solution
- repeat(since nn is not really affine) until a final solution

the infty norm only penalizes the largest entry in delta, and GD will oscillating between two suboptimal points
- replace with sum of delta - tao, with tao lowered each iteration
  - note that it is a sum not max

hyperparameter searching
- choosing c: using the smallest value which the solution really has f(x) < 0
  - indeed within some neighborhood of best c
  - best c in terms of adv examples quality or distance -> in terms of the appriximation does not change the objective´s optimal
  - large c will result in a overly greedy GD -> distance loss being ignored
  - in order the make the first iteration of GD move, c has to be larger than the inverse of gradient of f -> and a large c makes a over greddy solution again
- box constraints: if not supported natively, using change of variables

integral constrains for images
- greddy search on the lattice of discrete solution
- is a problem when the disturbance is sufficiently small

L0 attack
- identify some useless pixels and update the rest of them

heuristic: if transferability fails: adv examples on original model does not work on defenced model, model is well defenced