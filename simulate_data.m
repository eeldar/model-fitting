function data = simulate_data(P,R,T)
    
    % Simulate data from reinforcement learning agent on an X-armed bandit.
    %
    % USAGE: data = simulate_data(P,R,T)
    %
    % INPUTS:
    %   P - [N x 1] structure of parameters for N subjects, with the following fields:
    %           .invtemp - inverse temperature
    %           .lrate - learning rate
    %   R - [1 x X] reward probabilities for X arms
    %   T - number of trials
    %
    % OUTPUTS:
    %   data - [N x 1] structure with the following fields
    %           .C - [T x 1] choices
    %           .O - [T x 1] outcomes: 1=reward, 0=no-reward
    %           .P - parameter structure
    %           .R - reward probabilities
    %           .T - number of trials
    %
    % Eran Eldar, June 2018
    
    N = numel(P); % number of subjects
    
    for n = 1:N
        
        data(n).P = P(n);
        data(n).R = R;
        data(n).T = T;
        
        q = zeros(1,numel(R));  % initial values
        invtemp = P(n).invtemp;
        lrate = P(n).lrate;
        
        for t = 1:T
            p = exp(invtemp*q - mfUtil.logsumexp(invtemp*q,2));  % softmax choice probability
            c = mfUtil.randmultinomial(p);            % random choice
            o = double(rand<R(c));            % reward feedback
            q(c) = q(c) + lrate*(o-q(c));        % update values
            data(n).C(t,1) = c;
            data(n).O(t,1) = o;
        end
    end
end