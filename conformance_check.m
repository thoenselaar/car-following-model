% =========================================================================
% Title         : TJte_closeness.m
% Author        : Arend Aerts
% Project       : Model-Based testing tool for hybrid systems in Acumen
% Date          : 10-04-2015
% Description   : Determine conformance with(T,tau,epsilon)-closeness) 
%
%                                ---
%
% Copyright (©) 2010-2014, Acumen Individual Contributors (AIC)
% All rights reserved.
%
% See LICENSE-AIC for licensing details. 
% =========================================================================


%function [conformance] = TJte_closeness(testcase,acumen,TJte_closeness_mode,conformance)

% testcase = handles.testcase;
% acumen = handles.acumen;
% TJte_closeness_mode = 0;
% 
% for m=1:1:max(size(conformance.var))  
% 
%     % Load implementation and model data
%     if acumen.instances > 1
%         X2 = acumen.time;
%         index=find(ismember(acumen.var,conformance.var(1,m)));
%         Y2 = acumen.data2(index,:);
%     else
%         X2 = acumen.time;
%         index=find(ismember(acumen.var,conformance.var(1,m)));
%         Y2 = acumen.data1(index,:);
%     end
% 
%     if TJte_closeness_mode == 0
%         X1 = acumen.time;
%         index=find(ismember(acumen.var,conformance.var(1,m)));
%         Y1 = acumen.data1(index,:);
%     else
%         X1 = testcase.time;
%         index=find(ismember(testcase.var,conformance.var(1,m)));
%         Y1 = testcase.data(index,:);
%     end
% 
% 
%     % Check ((T,J,(tau,epsilon))-closeness) --
% 
%     % Conformance is standard true, unless otherwise proven
%     result = true;
%     res = 10^-6; %Compensator for simulation time deviation (rounding)
% 
%     % Iteration 1 ([X1,Y1] w.r.t. [X2,Y2])
%     for(k=1:1:max(size(X1)))
%         % Check if conformance still holds
%         if(result == false)
%             break;
%         end
% 
%         % Construct min/max time boundaries of X1 instance
%         time_min = max(0,X1(1,k)-conformance.tau(1,m));
%         time_max = min(max(X1),X1(1,k)+conformance.tau(1,m));
% 
%         % Find corresponding time matrix instances of X2 
%         time_min_index = find(X2 >= time_min-res,1,'first');
%         time_max_index = find(X2 <= time_max+res,1,'last');
% 
%         % Conformance check Y1 w.r.t. Y2
%         for(i=time_min_index:1:time_max_index)
%             if(abs(Y1(1,k)-Y2(1,i)) <= conformance.epsilon(1,m))
%                 result = true;
%                 break;
%             else
%                 result = false;
%                 ref_index = k;
%                 error_index_begin = time_min_index;
%                 error_index_end = i;
%                 conformance.iteration = 1;
%             end
%         end    
%     end
% 
%     % Iteration 2 ([X2,Y2] w.r.t. [X1,Y1])
%     for(k=1:1:max(size(X2)))
%         % Check if conformance still holds
%         if(result == false)
%             break;
%         end
% 
%         % Construct min/max time boundaries of X1 instance
%         time_min = max(0,X2(1,k)-conformance.tau(1,m));
%         time_max = min(max(X2),X2(1,k)+conformance.tau(1,m));
% 
%         % Find corresponding time matrix instances of X2 
%         time_min_index = find(X1 >= time_min-res,1,'first');
%         time_max_index = find(X1 <= time_max+res,1,'last');
% 
%         % Compare Y1 instance with Y2 instances
%         for(i=time_min_index:1:time_max_index)
%             if(abs(Y2(1,k)-Y1(1,i)) <= conformance.epsilon(1,m))
%                 result = true;
%                 break;
%             else
%                 result = false;
%                 ref_index = k;
%                 error_index_begin = time_min_index;
%                 error_index_end = i;
%                 conformance.iteration = 2;
%             end
%         end
%     end
% end

variable_to_evaluate = 'a';
index_model=find(ismember(model.variables,variable_to_evaluate));
index_implementation=find(ismember(implementation.variables,variable_to_evaluate));


X1 = model.time;
Y1 = model.data(index_model,:);

X2 = implementation.time;
Y2 = implementation.data(index_implementation,:);


% Check ((T,J,(tau,epsilon))-closeness) --

    % Conformance is standard true, unless otherwise proven
    result = true;
    res = 10^-6; %Compensator for simulation time deviation (rounding)

    % Iteration 1 ([X1,Y1] w.r.t. [X2,Y2])
    for(k=1:1:max(size(X1)))
        % Check if conformance still holds
        if(result == false)
            break;
        end

        % Construct min/max time boundaries of X1 instance
        time_min = max(0,X1(1,k)-tau);
        time_max = min(max(X1),X1(1,k)+tau);

        % Find corresponding time matrix instances of X2 
        time_min_index = find(X2 >= time_min-res,1,'first');
        time_max_index = find(X2 <= time_max+res,1,'last');

        % Conformance check Y1 w.r.t. Y2
        for(i=time_min_index:1:time_max_index)
            if(abs(Y1(1,k)-Y2(1,i)) <= epsilon)
                result = true;
                break;
            else
                result = false;
                ref_index = k;
                error_index_begin = time_min_index;
                error_index_end = i;
                conformance.iteration = 1;
            end
        end    
    end

    % Iteration 2 ([X2,Y2] w.r.t. [X1,Y1])
    for(k=1:1:max(size(X2)))
        % Check if conformance still holds
        if(result == false)
            break;
        end

        % Construct min/max time boundaries of X1 instance
        time_min = max(0,X2(1,k)-tau);
        time_max = min(max(X2),X2(1,k)+tau);

        % Find corresponding time matrix instances of X2 
        time_min_index = find(X1 >= time_min-res,1,'first');
        time_max_index = find(X1 <= time_max+res,1,'last');

        % Compare Y1 instance with Y2 instances
        for(i=time_min_index:1:time_max_index)
            if(abs(Y2(1,k)-Y1(1,i)) <= epsilon)
                result = true;
                break;
            else
                result = false;
                ref_index = k;
                error_index_begin = time_min_index;
                error_index_end = i;
                conformance.iteration = 2;
            end
        end
    end
    