function lik = lik_bayes(P,data)
    
    % Likelihood function for Bayesian learning agent on two-armed bandit
    %
    % USAGE: lik = lik_rl(P,data)
    %
    % INPUTS:
    %   P - structure of S parameter samples, with the following fields:
    %           .alphabeta - [S x 1] parameter of prior beta distribution (assumes alpha = beta)
    %           .invtemp - [S x 1] beta parameter of prior beta distribution
    %   data - structure with the following fields:
    %          .C - [N x 1] choices
    %          .O - [N x 1] rewards
    %
    % OUTPUTS:
    %   lik - [S x 1] log-likelihoods
    %
    % Eran Eldar, June 2018
    
    S = size(P.invtemp,1); % number of samples
    lik = zeros(S,1); 
    Nc = max(unique(data.C)); % number of options
    
    invtemp = P.invtemp;
    % initialize beta distribution for each option
    alpha = repmat(P.alphabeta, [1 Nc]); 
    beta = repmat(P.alphabeta, [1 Nc]);
    
    
    for t = 1:data.T 
        c = data.C(t); 
        o = data.O(t);
        q = alpha./(alpha+beta); % compute mean of beta distributions 
        lik = lik + invtemp.*q(:,c) - mfUtil.logsumexp(bsxfun(@times,invtemp,q),2);
        
        % update beta distribution for chosen option
        if o==1; alpha(:,c) = alpha(:,c) + 1;
        else beta(:,c) = beta(:,c) + 1;
        end    
    end
end
