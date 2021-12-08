### RL an introduction

finite markov decision processes
- agent, environemnt, state, reward, action
  - anything that cannot be changed arbitrarily by the agent is considered envirionment
- episodic tasks: w/ a terminal state
- for continuing tasks, discount reward of future time step
- markov property: all information are encoded into current state / conditional independence
- MDP: reinforcement learning task satisfying markov property
  - finite if w/ finite state and action sets
  - value functions
    - value of a state being sum of current and all future steps, under certain prob function
      - by taking one step, we get the recurrsive formular of value function(bellman equation)
    - action-value function being expected value of future steps, from state s doing action a
  - optimal state-value function: maximise value function w.r.t. policy functions
    - but reinforcement learning as an online learning only learns on the fly the most frequent set of spaces(often a fraction of whole space)

dynamic programming
- assume finite MDP environment
- iterative policy evaluation: full backup(all possible next states are considered)
  - use old values or new values in one update round?
    - use new ones will converge faster
- policy improvement theorem
  - if from any state s, choose action from policy pi', the expected value under policy pi will always be better than pi, then policy pi' will yield higher return for all states s
- policy iteration
  - from a random policy
  - get value function for all states
    - iteratively... slow!
    - truncated after one step -> value iteration
      - also can be viewed as a fix point iteration of Bellman equation
  - update policy from value functions
  - repeat

temporal difference learning
- constatnt-alpha MC: V(s) = V(s) + alpha(G_t - V(s)), where the G_t is the final return from step t, not available until the end
- whereas TD uses the immediate return V(s) = V(s) + alpha(r_t+1 + gamma V(s') - V(s))
  - and converges faster

on policy appriximation of action values
- many states are not visited -> some kind of reneralization required

policy gradient
- learn a parameterized policy w/o value function
- partial J(theta) ~ sum_s mu(s) sum_a q_pi(s, a) partial pi(a | s, theta)
  - where mu(s) is the proportion of time being in state s
  - and for onpolicy senarios theta = theta + alpha G_t partial pi(A_t | S_t, theta) / pi(A_t | S_t, theta)
  - can also include baselines theta = theta + alpha (G_t - b(S_t)) partial pi(A_t | S_t, theta) / pi(A_t | S_t, theta)
    - can also use a learned state value function as baseline
    - whereas the G is return from step t
- one-step actor-critic
  - theta = theta + alpha (r 1 gamma v(S_t+1, w) - v(S_t, w)) partial pi(A_t | S_t, theta) / pi(A_t | S_t, theta)
  - v(S_t, w) is also learned