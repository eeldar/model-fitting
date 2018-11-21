classdef mfUtil < handle
    
    properties
        
    end
    
    methods(Static)        
        
        function s = logsumexp(x, dim)
            % Returns log(sum(exp(x),dim)) while avoiding numerical underflow.
            % Default is dim = 1 (columns).
            % Written by Mo Chen (mochen@ie.cuhk.edu.hk). March 2009.
            
            if nargin == 1, 
                % Determine which dimension sum will use
                dim = find(size(x)~=1,1);
                if isempty(dim), dim = 1; end
            end

            % subtract the largest in each column
            y = max(x,[],dim);
            x = bsxfun(@minus,x,y);
            s = y + log(sum(exp(x),dim));
            i = find(~isfinite(y));
            if ~isempty(i)
                s(i) = y(i);
            end
        end
        
        
        function y = randmultinomial(p,n)

            % Multinomial random numbers.
            %
            % USAGE: y = randmultinomial(p,n)

            if nargin < 2; n=1; end
            [~, y] = histc(rand(1,n),[0 cumsum(p)]);
        end        
        
        function model = randomP(model, S)        
            %
            % sample parameters values
            % 
            % USAGE: model = mfUtils.randomP(model, S)
            %
            % INPUTS:
            %   model - structure with the following fields:
            %               .spec - structure with the following fields:
            %                           .{parameter_name} - structure array with the following fields:       
            %                                       .type - parameter distrbution type ('norm', 'beta', 'gamma', 'binom')
            %                                       .val - [1 Nh] Nh hyperparameters of the distribution
            %   S - number of samples
            %
            % OUTPUTS:
            %   model - structure with the inputted fields plus:
            %               .P - structure with the following fields:
            %                           .{parameter_name} - [S x 1] parameter samples
            %
            
            spec = model.spec;
            fnames = fieldnames(spec);
            for f = 1:length(fnames)
                param = spec.(fnames{f});
                switch param.type
                    case 'norm'
                        P.(fnames{f}) = param.val(1) + randn(S, 1) .* param.val(2);
                    case 'beta'
                        P.(fnames{f}) = betarnd(param.val(1), param.val(2), S, 1);
                    case 'gamma'
                        P.(fnames{f}) = gamrnd(param.val(1), param.val(2), S, 1);
                    case 'binom'
                        P.(fnames{f}) = rand(S,1)<=param.val(1);
                end
            end
            model.P = P;
        end
        
        function model = computeEstimates(lik, model, n)
            %
            % Resample all parameters based on their posterior probability
            %
            % INPUTS:
            %   lik - [S x 1] likelihood for each sample
            %   model - structure with the following fields:
            %               .spec - structure with the following fields:
            %                           .{parameter_name} - structure array with the following fields:       
            %                                       .type - parameter distrbution type (e.g., 'norm', 'beta', 'gamma', etc.)
            %               .P - structure with the following fields:
            %                           .{parameter_name} - [S x 1] parameter samples
            %   n - fit number
            %
            % OUTPUTS: 
            %   model - structure with the inputted fields plus:
            %               .fit(n,1) - structure with the following fields:
            %                           .evidence - log mean likelihood       
            %                           .samples - number of valid samples  
            %                           .P - structure with the following fields:       
            %                                       .{parameter_name} - structure with the following fields:       
            %                                                   .val - mean of the parameter's posterior distribution
            %                                                   .ci - [1 x 2] 95% credible interval
            %                                                   .samp - [1 x 1000] uniform samples from the posterior
            %            
            
            % number of valid samples
            inc = find(~isinf(lik) & ~isnan(lik));
            fit.samples = size(lik(inc),1); 
            
            % compute evidence (log mean likelihood)
            sumlik = mfUtil.logsumexp(lik(inc)); 
            fit.evidence = sumlik - log(fit.samples); 
            
            % computes weights for resampling
            weights = exp(lik(inc)-sumlik); 
            
            % resample bases on weights
            fnames = fieldnames(model.P);
            for f = 1:length(fnames)
                param{f} = model.P.(fnames{f});
                [val{f}, ci{f}, samp{f}] = mfUtil.computeEstimate(param{f}(inc), weights);
                fit.P.(fnames{f}).val = val{f};
                fit.P.(fnames{f}).ci  = ci{f};
                fit.P.(fnames{f}).samp = samp{f};
            end
            model.fit(n,1) = fit;
            
        end
        
        function [val, ci, samp] = computeEstimate(param, weights)
            %
            % Resample one parameter based on its posterior probability
            %
            % INPUTS:
            %   param - [S x 1] parameter samples
            %   weights - [S x 1] weights for resampling
            %
            % OUTPUTS: 
            %   val - mean of the parameter's posterior distribution 
            %   ci - [1 x 2] 95% credible interval
            %   samp - [1000 x 1] uniform samples from the posterior
            %            
            
            weights = weights ./ sum(weights);
            [oparam, rank] = sort(param);
            oweights = weights(rank);
            cdf = cumsum(oweights);
            ci = [oparam(find(cdf > 0.05, 1, 'first'),:) oparam(find(cdf > 0.95, 1, 'first'),:)];
            val = sum(repmat(oweights,[1,size(oparam,2)]).*oparam); 
            sampp = 0.0005:0.001:1;
            ind = 1;
            for i=1:length(sampp)
                if ~isempty(find(cdf(ind:end) > sampp(i), 1, 'first'))
                    ind = ind - 1 + find(cdf(ind:end) > sampp(i), 1, 'first');
                end
                samp(i,:) = oparam(ind,:);
            end                    
        end 
                
        function model = fit_prior(model)
            % 
            % update the hyperparameters of the prior distribution to reflect the posterior distribution
            %
            % USAGE: model = fit_prior(model)
            %
            % INPUTS:
            %   model - structure with the following fields:
            %               .spec - structure with the following fields:
            %                           .{parameter_name} - structure array with the following fields:       
            %                                   .type - parameter distrbution type (e.g., 'norm', 'beta', 'gamma', etc.)
            %               .fit - [N x 1] structure array with the following fields:
            %                           .P - structure with the following fields:
            %                                   .{parameter_name} - structure array with the following fields:       
            %                                           .samp - [1 x 1000] uniform samples from the posterior
            %
            % OUTPUTS: 
            %   model - structure with the inputted fields, with .spec fitted to .fit.P.{parameter_name}.samp
            
            fnames = fieldnames(model.spec);
            for f = 1:length(fnames)
                
                oldval = model.spec.(fnames{f}).val;
                
                % collect resampled samples from all subjects
                samp = [];
                for n = 1:length(model.fit)
                    samp = cat(1, samp, model.fit(n).P.(fnames{f}).samp);
                end
                
                % fit hyper parameters
                switch model.spec.(fnames{f}).type
                    case 'beta'
                        model.spec.(fnames{f}).val = betafit(double(samp(~isnan(samp))));
                    case 'binom'
                        model.spec.(fnames{f}).val = nanmean(double(samp(~isnan(samp))));
                    case 'gamma'
                        model.spec.(fnames{f}).val = gamfit(double(samp(~isnan(samp))));
                    case 'norm'
                        [model.spec.(fnames{f}).val(1), model.spec.(fnames{f}).val(2)] = normfit(double(samp(~isnan(samp))));
                end
                fprintf('%s - %s    old: %.2f %.2f      new: %.2f %.2f \n', model.name, fnames{f}, oldval(1), oldval(2), model.spec.(fnames{f}).val(1), model.spec.(fnames{f}).val(2))
            end
                        
        end
        
        function P = fit2P(fit)
            %
            % organize the results of model fitting for one subject such that they can be fed back into the likelihiid function for simulation
            % 
            % USAGE: model = fitToModel(fit)
            %
            % INPUTS:
            %   fit - structure with the following fields:
            %               .P - structure with the following fields:
            %                       .{parameter_name} - structure array with the following fields:       
            %                               .val - fitted parameter value
            % OUTPUTS: 
            %   P - structure with the following fields:
            %               .{parameter_name} - fitted parameter value
            %
            fnames = fieldnames(fit.P);
            for f = 1:length(fnames)
                P.(fnames{f}) = fit.P.(fnames{f}).val;
            end
        end
    end
end