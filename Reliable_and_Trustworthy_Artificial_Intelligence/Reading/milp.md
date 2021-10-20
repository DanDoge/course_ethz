# evaluating robustness of neural networks with mixed integer programming

obtaining bounds to rule out possible binary variables
- interval arithmtic
  - of maximum function: y <= x_i + (1 - a_i)(u_max,-i - l_i), with a_i indicating (one of) the maximums
    - sum of a_i = 1
- linear programming
  - which is also a relax of integer constraints
  - tradeoff: practically, get interval bound first, and then LP for the parts with high computational cost

objectives as optimization
- l1, linfty trival
- l2, no auxiliary variable needed, but MLQP required