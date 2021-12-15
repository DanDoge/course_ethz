### clustering

similarity based / feature based clustering
- dissimilarity / distance matrix

dirichlet process 
- infinite mixture models
- p(x | z = k, theta) = p(x | theta_k), p(z = k | pi) = pi_k, p(pi | alpha) = Dir(pi | alpha / K 1_K)
- distribution G over prob measure theta -> R, int G(theta) d theta = 1.
    - G(T_i) are jointly Dirichlet Dir(alphaH(T_i))
    - stick breaking construction, beta_k ~ Beta(1, alpha), pi_k = beta_k * Prod (1 - beta_i)
    - chinese resturant process: new person occupy a new table with unnormed prob alpha, and joins a occupied table w.p. number of persons at this table