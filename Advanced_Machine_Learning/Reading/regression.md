### ESL ch. 3

RSS residual sum fo squares
- var of beta is (Xt X)^-1 Sigma_y
  - note that var(Ax) = Avar(x)A^t
- assume y ~ N(X beta, sigma^2) 
  - test whether beta_j = 0 -> t-distribution, hypothesis test
  - remove k variables -> F-test
- schimidt orthogonalize inputs(N = d) -> each beta_j only depends on z_j and y -> projection on each axis of the d-dim space
- multiple dim outputs: similar formular

subset selection
- reduce var by setting some coef to zero
- adding or dropping variables, greedy
- stagewise: adding a variable by regressing on the residual
  - with coef of other variables not changed
  - slow, but competitive in high dim cases

shinkage methods: also reduce var
- ridge regression: standardizes inputs to handle scaling
  - note in orthogonal cases, ridge is just a scaling of LSE
  - apply SVD on X -> ridge regression shrink coordinates with small singular value
- LASSO: regression s.t. L1 of beta is less than t
- least angle regression
  - identify a var with most corr with the response, move a fraction towards LSE, until another var has the most corr with the response
  - move both of them until another var has the most corr

derived input directions
- produce Z: a small linear combinations of X
- principal components regression
  - orthogonal axis, so prediction is a sum of univariate regressions
  - also first standardize to avoid scaling
- partial least square
  - compute z_1 = sum of < x_j, y > x_j, orthogonalize all x w.r.t. z_1 and repeat
  - the mth iteration of PCR solves max_a Var(Xa) s.t. |a| = 1, aT S v_l = 0
  - the mth iteration of PLS solves max_a Var(Xa)Corr^2(y, Xa) s.t. |a| = 1, aT S v_l = 0
- see fig 3.18 pp83

shrinkage and selection on multiple outcome predcitions
- different lambda for each outcome
- canonical correlation analysis: find a conbination Xv and Yu s.t. corr is max.ed
  - SVD of YtX / N
- reduced rank regression: totally not readable, give up
- miscellaneous, nothing much important

### basis expansion

cubic spline
- 1, x, x2, x3, (x - e1)3, (x - e2)3
  - each region fit a 4 parameter function, but each knots comes with 3 constraints(continuous second derivative)
- very wild prediction outside of the boundary
  - introducing natural cubic spline: linear beyond the boundary -> 4 deg of freedom freed
- smoothing splines
  - RSS = LSE + lambda curvature
    - global minimizer with N knots -> note it is not a degenerate solution, because continuous derivatives has to be respected
  - after some matrix representations, the analytical solution is some generalized ridge regression
    - with numerical DoG being trace of smoothing matrix