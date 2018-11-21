%% simulate data
N = 20; % number of subjects
for n = 1:N
    P(n).lrate = betarnd(1,9); % learning rate sampled from a beta distribution with mean 0.1 (=1/(1+9))
    P(n).invtemp = gamrnd(5,1); % inverse temperature sampled from a gamma distribution with mean 5 (=5*1)
end
T = 100; % number of trials
R = [0.25 0.75]; % reward probabilities
data = simulate_data(P,R,T); % simulated data

%% initialize models

% RL model (two parameters: lrate & invtemp)
model{1}.lik_func = @lik_rl;
model{1}.name = 'RL';
model{1}.spec.lrate.type = 'beta';
model{1}.spec.lrate.val = [1 1];
model{1}.spec.invtemp.type = 'gamma';
model{1}.spec.invtemp.val = [1 1];
model{1}.bic = nan;

% Bayesian model (two parameters: alphabeta & invtemp)
model{2}.lik_func = @lik_bayes;
model{2}.name = 'Bayes';
model{2}.spec.alphabeta.type = 'gamma';
model{2}.spec.alphabeta.val = [1 1];
model{2}.spec.invtemp.type = 'gamma';
model{2}.spec.invtemp.val = [1 1];
model{2}.bic = nan;

%% fit models

S = 10000; % number of samples

for m = 1:length(model)
    
    improvement = nan;
    while ~(improvement < 0) % repeat until fit stops improving
        oldbic = model{m}.bic;

        for n = 1:N
            model{m} = mfUtil.randomP(model{m}, S); % sample random parameter values
            lik = model{m}.lik_func(model{m}.P, data(n)); % compute log-likelihood for each sample
            model{m} = mfUtil.computeEstimates(lik, model{m}, n); % resample parameter values with each sample weighted by its likelihoods
        end

        % fit prior to resampled parameters
        model{m} = mfUtil.fit_prior(model{m});

        % compute goodness-of-fit measures 
        Nparams = 2*length(fieldnames(model{m}.spec)); % number of hyperparameters (assumes 2 hyperparameters per parameter)
        Nsamples = sum([model{m}.fit.samples]); % total number of samples 
        model{m}.evidence = sum([model{m}.fit.evidence]); % total evidence
        model{m}.bic = -2*model{m}.evidence + Nparams*log(Nsamples); % Bayesian Information Criterion
        improvement = oldbic - model{m}.bic; % compute improvement of fit
        fprintf('%s - %s    old: %.2f       new: %.2f      \n', model{m}.name, 'bic', oldbic, model{m}.bic)
    end
    
end

%% display correspondence between model 1 parameters and original parameters
fits = [model{1}.fit.P];
invtemp = [fits.invtemp];
lrate = [fits.lrate];
figure; clf; subplot(1,3,1);
scatter([P.invtemp],[invtemp.val]);
title('Inverse temperature');
xlabel('true value'); ylabel('fitted value');
subplot(1,3,2);
scatter([P.lrate],[lrate.val]);
title('Learning rate');
xlabel('true value'); ylabel('fitted value');

%% simulate data from fitted model 1
for n = 1:N
    P = mfUtil.fit2P(model{1}.fit(n));
    [~, latents] = model{1}.lik_func(P, data(n)); %simulate choices for each subject
    sim_meanC(n,1) = mean(latents.sim_C); % average choice for simluated data
    real_meanC(n,1) = mean(data(n).C); % average choice for real subject
end
subplot(1,3,3);
scatter(sim_meanC, real_meanC);
title('Simulated data');
xlabel('real (i.e., original) average choice');
ylabel('simulated average choice');


