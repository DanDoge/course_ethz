## EXPLAINING AND HARNESSING ADVERSARIAL EXAMPLES

L-BFGS: limited memory quasi neuton method
- estimate inverse hessian

hypotheses
- NN are too linear to resist linear adv perturbations
  - no need for specular assumptions
  - esp. for high dim. problems
  - also considering prevelent NN models tends to have linear activation functions for the ease of optimazation
- in underfitting setting, adv examples will worsen underfitting
- directions matter most in finding adv examples

some experiment findings
- adv training may not lead to fast drop of validation set error, but will decrease validation set adv error over time
- comparing a vanilla model and a adv trained model
  - adv examples are indeed transferable
  - but the adv trained model are more robust, while adv examples from the adv trained model still will fool the original model
- training a model using noise level epsilon is inefficient at preventing adv examples -> expected dot product is zero -> maybe not effect at all rather than a difficult input
  - adv training as hard example mining among noisy points
- training network jointly with adv params(e.g. rotation, addition), does not work in this paper
  - seems to be a easy adv example
- preturb input or hidden layers
  - hidden layer does not work: model can learn a large weight
  - rotation can be trained, but not efficient for defence
  - preturb final layer does not work: very little capacity left, and last layer usually is not an universial approximator

RBF: radial basis function
- output = sum of a_i exp(-beta_i |x - c_i|^2)

why adv examples generalize
- hypothesize all NN ensemble the same linear classifier
- so ensembles also do not work
- very little space on the data manifold does the network rightly classifies the input, the whole Rn is mostly madeup of rubbish inputs and adv examples

refuted hypothesis
- generate model are more robust: no
- ensemble will wash out adv examples: no

rubbish inputs
- out of distributions inputs
- linear models output extrame high values for ood inputs
  - and the extreme high class prediction distribution are skewed