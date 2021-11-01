### DeepPloy

new abstract domain conbining polyhedra and intervals
- main domain invariant: the concretization of symbolic obunds are contained inside concrete bounds
  - s.t. even if after a ReLU, we cannot say l_i = 0 unless the bound is 0
- keep only one lower bound to avoid exponential blowup of constraints
- tradeoff: backsubstitution all the way to first layer or stop some where
- abstract transformer for sigmoid and tanh
  - concrete bound = f(concrete bound)
  - synbolic bound = line connecting two ends and the min derivative
- for maxpool
  - if some variable has higher lower bound than all other upper bound
    - maxpool(x_1...i) = x_j
  - else choose one var with highest lower bound, lower bound = x_j, upper bound = u_j
- soundness under floating point
  - well, some theoritical terms