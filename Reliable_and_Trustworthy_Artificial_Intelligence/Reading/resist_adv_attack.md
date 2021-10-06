## Towards Deep Learning Models Resistant to Adversarial Attacks

PGD as the strongest first order adversary
- beacause the loss landscape of the inner max. problem is indeed well-behaved, PGD will reach the global maxima
  - all local maxima will have similar loss values
  - of course there will be isolated max with larger values -> hard to find w/ first order methods

to be adv robust, network should have more capacity
- value of saddle points decreases
- more capacity and stronger adv decrease transferability

defend
- specify a attack model
- saddle point problem?
  - local maxima within x + S tend to have well-concentrated losses
  - not only in the direction of grad will we find adv examples, but also in the opposite direction

danskin´s theorem
- indicates that (in continuous nn models) the gradient direction evaluated at the maximizer of the inner optimization problem is truly the gradient direction of the outer min. problem

PGD defenced models are more rubust to transfer attack(zero order attack, as called in this paper)
- note that adv examples´ gradient seems to correlate in diff network models
- transfer attack do worse then whier-box counterparts

landscape of adv examples
- for random starting points in l infty ball, all adv loss values concentrate to the same value after plateaus
- the adv examples are randomly distributed in the norm ball and the loss curve between a pair of them is convex

FGSM with large epsilon  leaks label and network overfits to these advs

model inspection
- first layer learns kernel of only one weight being non-zero -> a scaling function
- second layers also sparse and large weight range
- last layer, weight being similar to the naturally trained counterparts, but bias are much utilized
  - some being larger and some being smaller: more valurable against adv attack