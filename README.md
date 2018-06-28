# Hierarchical Model Fitting

The code fits RL and Bayesian models to simulated data.

### Reinforcement learning 
Parameters: $ \eta $ - learning rate
$$ \begin{matrix} \forall i & Q_0(i) = 0 & Q_0(i) = 0 \end{matrix} $$
$$ Q_{t+1}(c_t) = Q_t(c_t) + \eta(\text{outcome}_t - Q_t(c_t)) $$

### Bayesian inference
Parameters: $ \phi $ - shape of prior expectation
$$ \begin{matrix} \forall i & A_0(i) = \phi, B_0(i) = \phi \end{matrix} $$
$$ \begin{matrix} \text{if } \text{outcome}_t = 1 & A _{t+1}(c_t) = A_t(c_t) + 1 \\\ \text{if } \text{outcome}_t = 0 & B _{t+1}(c_t) = B_t(c_t) + 1 \end{matrix} $$ 
$$ Q_t(c_t) = \frac{A_t(c_t)}{A_t(c_t)+B_t(c_t)} $$

### Decision model (for both models)
Parameters: $ \beta $ - inverse temperature
$$ \text{p}(c_t) = \frac{e^{\beta Q_t(c_t)}}{\sum_i{e^{\beta Q_t(i)}}} $$

Legend: $ Q $ - expected value, $ c $ - choice, $ t $ - trial
## Scripts
 - **demo.m**:   demonstrates fitting the two models to simulated data
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

