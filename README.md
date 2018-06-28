# Hierarchical Model Fitting

### Bayesian inference
$$ \begin{matrix} \text{if } \text{outcome}_t = 1 & \alpha _{t+1}(c_t) = \alpha_t(c_t) + 1 \\\ \text{if } \text{outcome}_t = 0 & \beta _{t+1}(c_t) = \beta_t(c_t) + 1 \end{matrix} $$ 
$$ Q_t(c_t) = \frac{\alpha_t(c_t)}{\alpha_t(c_t)+\beta_t(c_t)} $$


### Reinforcement learning 
Parameters: $ \eta $- learning rate
$$ Q_{t+1}(c_t) = Q_t(c_t) + \eta(\text{outcome}_t - Q_t(c_t)) $$

### Decision model (for both models)
Parameters: $ \beta $- inverse temperature
$$ \text{p}_t(c_t) = \frac{e^{\beta Q_t(c_t)}}{\sum_i{e^{\beta Q_t(i)}}} $$

## Scripts
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

