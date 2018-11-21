function [lik, latents] = lik_rl(P,data)
    
    % Likelihood function for reinforcement learning agent on two-armed bandit
    %
    % USAGE: lik = lik_rl(P,data)
    %
    % INPUTS:
    %   P - structure of S parameter samples, with the following fields:
    %           .invtemp - [S x 1] inverse temperatures
    %           .lrate - [S x 1] learning rates
    %   data - structure with the following fields:
    %          .C - [N x 1] choices
    %          .O - [N x 1] rewards
    %
    % OUTPUTS:
    %   lik - [S x 1] log-likelihoods
    %   latents - structure with following fields (only works when S = 1):
    %               .q - [N x O] q values for N trials and O possible actions
    %               .rpe - [N x 1] prediction errors
    %               .sim_C - [N x 1] simulated choices
    %
    % Eran Eldar, June 2018
    
    S = size(P.invtemp,1); % number of samples
    O = max(unique(data.C)); % number of options
    q = zeros(S,O);  % initial values
    lik = zeros(S,1);
    invtemp = P.invtemp;
    lrate = P.lrate;
    
    for t = 1:data.T 
        c = data.C(t); 
        o = data.O(t);
        lik = lik + invtemp.*q(:,c) - mfUtil.logsumexp(bsxfun(@times,invtemp,q),2);
        rpe = o-q(:,c);       % reward prediction error
        
        if nargout>=2 && S==1 % simulate choices and store q values and rpes
            p = exp(invtemp*q - mfUtil.logsumexp(invtemp*q,2));  % softmax choice probability
            latents.sim_C(t,1) = mfUtil.randmultinomial(p);      % random choice
            latents.q(t,:) = q;      
            latents.rpe(t,:) = rpe;      
        end        
        
        q(:,c) = q(:,c) + lrate.*rpe;      % update values for chosen option
    end
end
