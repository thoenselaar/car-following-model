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
    