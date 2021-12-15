### pac learning

if exists am algorithm A and a poly function, s.t. for all eps and delta
- P(R(h_S) < eps) > 1 - delta, for sample size m > poly(1/eps, 1/delta, n, C)
    - then C is pac learnable, efficient if A can be learned in poly time
- where n is time needed to represent an element in S
- C is the comcept class

for consistent case(no error on training set)
- ...holds if m >= 1/eps (log |H|/delta)

for inconsistant cases
- w.p. > 1 - delta, R(h) < R(^h) + srqt(log 2/delta  / 2m)
- for finite hypothesis set R(h) < R(^h) + O(sqrt(log |H| / m))
    - note a quadratically larger m need to be chosen to achieve similar results as in consistant case