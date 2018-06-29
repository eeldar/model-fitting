# Hierarchical Model Fitting

MATLAB code fitting RL and Bayesian models to simulated data.

### Fitting algorithm

Define model parameters' prior distributions <img src="/tex/1f438323bcea53b1fbcfb5169074e970.svg?invert_in_darkmode&sanitize=true" align=middle width=30.091408049999988pt height=24.65753399999998pt/>, and repeat until mean likelihood stops increasing:
 1. Sample parameter values from  <img src="/tex/1f438323bcea53b1fbcfb5169074e970.svg?invert_in_darkmode&sanitize=true" align=middle width=30.091408049999988pt height=24.65753399999998pt/>
 2. Compute likelihood <img src="/tex/767c519b405b6ea9a6d8f1b90116f3fa.svg?invert_in_darkmode&sanitize=true" align=middle width=66.62120024999999pt height=24.65753399999998pt/> for each sample 
 3. Derive <img src="/tex/c1b4b1392a4c7fb52634bd2bc4aa844d.svg?invert_in_darkmode&sanitize=true" align=middle width=185.25143999999997pt height=24.65753399999998pt/>, by resampling the parameter values with likelihoods as weights
 4. Fit prior distributions to the resampled values: <img src="/tex/bfd6855949188dd9bccbaa0dabdff8c9.svg?invert_in_darkmode&sanitize=true" align=middle width=152.37461745pt height=24.65753399999998pt/>

### Reinforcement learning model
Parameters: <img src="/tex/72f2c124690ade8ae09fa2ef022148c1.svg?invert_in_darkmode&sanitize=true" align=middle width=8.751954749999989pt height=14.15524440000002pt/> - learning rate
<p align="center"><img src="/tex/52eed1b1ba9faa87857f6c66e308ca4e.svg?invert_in_darkmode&sanitize=true" align=middle width=185.58313289999998pt height=16.438356pt/></p>
<p align="center"><img src="/tex/21a09949ad47d2c72cc1386ff92ba521.svg?invert_in_darkmode&sanitize=true" align=middle width=299.7532032pt height=16.438356pt/></p>

### Bayesian inference model
Parameters: <img src="/tex/8371297b6cf0fc66bdbb7baf58cdd5df.svg?invert_in_darkmode&sanitize=true" align=middle width=9.794543549999991pt height=22.831056599999986pt/> - shape of prior distribution
<p align="center"><img src="/tex/f7f51b4ce63818a96c9f350194cc82d4.svg?invert_in_darkmode&sanitize=true" align=middle width=187.5403992pt height=16.438356pt/></p>
<p align="center"><img src="/tex/ffdceb3a506cc07ca63587e2bff326d3.svg?invert_in_darkmode&sanitize=true" align=middle width=285.20368635pt height=36.164383199999996pt/></p> 
<p align="center"><img src="/tex/ea96c7618fc123c0f6a76a23fc85c4e0.svg?invert_in_darkmode&sanitize=true" align=middle width=176.1981342pt height=38.83491479999999pt/></p>

### Choice probability (for both models)
Parameters: <img src="/tex/9480545cb12c693db1b6559e43971278.svg?invert_in_darkmode&sanitize=true" align=middle width=10.16555099999999pt height=22.831056599999986pt/> - inverse temperature
<p align="center"><img src="/tex/818211182bbae6b85fd10d22b94b92dc.svg?invert_in_darkmode&sanitize=true" align=middle width=131.52708525pt height=42.21837675pt/></p>

Legend: <img src="/tex/bb17b0e6d694fc6d731ee88afe1bae60.svg?invert_in_darkmode&sanitize=true" align=middle width=12.99542474999999pt height=22.465723500000017pt/> - expected value, <img src="/tex/3b9edf07f403d97e9f5bbd73dc66aae4.svg?invert_in_darkmode&sanitize=true" align=middle width=7.11380504999999pt height=14.15524440000002pt/> - choice, <img src="/tex/99d32c17b0344b01c18cce1e210642dc.svg?invert_in_darkmode&sanitize=true" align=middle width=5.936097749999991pt height=20.221802699999984pt/> - trial
## Scripts
 - **demo.m**:   demonstrates fitting the two models to simulated data
 - **simulate_data.m**:   simulate data from a reinforcement learning agent
 - **lik_rl.m**:          reinforcement learning likelihood function
 - **lik_bayes.m**:       Bayesian inference likelihood function
 - **mfUtil.m**:          various functions including the below
    - *.randomP*           - Sample parameter values from prior distributions
    - *.computeEstimates*  - Resample all parameters based on their posterior probability
    - *.computeEstimate*   - Resample one parameter based on its posterior probability
    - *.fit_prior*         - Update the hyperparameters of the prior distribution to reflect the posterior
    - *.logsumexp*         - Compute log(sum(exp(x),dim)) avoiding numerical underflow
    - *.randmultinomial*   - Generate multinomial random numbers

