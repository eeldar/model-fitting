# Hierarchical Model Fitting
 - **demo.m**:   demonstrates fitting two models to simulated data
 - **simulate_data.m**:   simulate data from a reinforcement learning agent
 - **lik_rl.m**:          reinforcement learning likelihood function
 - **lik_bayes.m**:       Bayesian inference likelihood function
 - **mfUtil.m**:          various functions including the below
    - *.randomP*            Sample parameter values from prior distributions
    - *.computeEstimates*   Resample all parameters based on their posterior probability
    - *.computeEstimate*    Resample one parameter based on its posterior probability
    - *.fit_prior*          Update the hyperparameters of the prior distribution to reflect the posterior
    - *.logsumexp*          Compute log(sum(exp(x),dim)) avoiding numerical underflow
    - *.randmultinomial*    Generate multinomial random numbers


Bayesian learning: if outcome = 1; a(c)  = a(c) + 1; if outcome = 0; b(c) = b(c) + 1;
                   q(c) = mean of beta distribution with parameters a(c) and b(c) = a(c)/(a(c)+b(c));

RL learning: q(c) = q(c) + lrate x (outcome - q(c))

Decision model: p(c) = exp(invtemp x q(c)) / sum_i(exp(invtemp x q(i)))


$ y = x^2 + 3 $
