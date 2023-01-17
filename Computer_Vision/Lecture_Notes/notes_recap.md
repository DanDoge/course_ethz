projective geometry
- x --> (x, 1)
- 2d lines: l^T x = 0
  - intersection of lines: l1 x l2
  - line from two points x1 x x2
- 2d transformation
  - shear ((1, h), (h', 1))
  - translation: 2dof, rigid: 3dof(R, t), similarity: 4dof(sR, t), affine: 6dof(A_2*3), proejctive 8dof(up to scale)
- perspective projection
  - K [R, t]

local features
- require region extraction to be repeatabel and accurate
  - invariant to translation, rotation, scale
  - robust to out of plane transformations
  - robust to linghting variations, noise, blur, quantization
  - locality, quantity, distinctiveness, efficiency
- Harris detector
  - looking for corners
  - E(u, v) = sum in window (I(x + u, y + v) - I(x, y))^2
  - = sum_(x, y) (I_x, I_y)(u, v)^2
  - shifting a window in any direction should give a large change in intensity
  - looking for sum_(x, y) w(x, y) (I_x, I_y)(I_x, I_y)^T with large eigenvalues
    - lam_1 lam_2 - kappa (lam_1 + lam_2)^2 = det(M) - kappa trace^2(M)
    - w(x, y) gaussian --> rotation invariant
- scale invariant region selection
  - find scale invariant signature function: same for corresponding regions, even if at different scales
    - e.g. laplacian of gaussians: appriximate with difference of gaussians
    - characteristic scale: scale that peaks Laplacian response
- local descriptors
  - SIFT: divide path into subpatches, compute histogram of gradient orientations, rotate according to dominant direction of gradient

optical flow
- 2d velocity field des cribing the apparent motion in images
- given consecutive image frames, esitmate motion of each pixel
- assume brightness constancy and small motion
  - allow for pixel to pixel comparison and linearization of brightness constancy constraint
- brightness contancy equation: partial I(x, y, t) = 0
  - part I / part x dx/dt + part I / part y dy/dt + part I / part t = 0
  - I_t = image t - image (t + 1)
  - one equation for two unknowns
- lucas kanade flow
  - assuming flow is locally smooth and neighboring pixels have same displacement
  - solve for (AtA)^-1 At b thing --> AtA is corner detector
  - corners are where lucas kanade optical flow works best
    - without corners: barner's ploe illusion, paerture problem
- horn-schunck flow
  - smooth flow field: min E(i, j) + lambda E_d(i, j) --> flow change is small
  - again, a linear system(in terms of gradient)
    - iterative update: flow --> local average minus a adj, in direction to brightness gradient

deep learning
- logistic reg. sum -y log y^ - (1 - y) log (1 - y^)
- smaller bs --> larger var
- batches randomly or partitioning dset, as independent as possible --> shuffle dset