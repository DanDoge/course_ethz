### safety and robustness certification of neural networks with abstract interpretation

neural network as a composition of conditional affine transformations
- affine functions
- conditioned affine functions
- composition of such

inteprate NN functions as CAT function

define soundness
- abstraction function: a set of vectors -> an abstract element(with possible overappriximation)
- concretization function: the opposite
- soundness is that for all layers, literally passing the concrete values still falls in the transformed abstract shape

apply CAT functions to abstract shapes
- affine: exact for zonotope and polyhedra
- case: split the abs element and compute transformation for each ele
  - define operations, meet and join
  - details in zonotope paper
- robust condition: concrete(transform(abstract(x))) in robustness condition region
  - proof by checking the intersetion with negation of robustness condition