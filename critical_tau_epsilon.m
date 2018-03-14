clear all; warning off;
tic     % start timing

%% Variables being varied
a_list = 0.25:0.25:1;
tau_list = 0.5:0.25:2;

T_THRESHOLD = 1;    % time threshold
D_THRESHOLD = 4;    % distance threshold
S_THRESHOLD = 0.5;  % speed threshold
N = 1000;           % moving average parameter

%% car parameters
car.v_0 = 120/3.6;
car.delta = 4;
car.T = 1.6;
car.s_0 = 2.0;
car.a = 1.4;
car.b = 1.67;
car.l_avg = 5;
    
leader = car;
follower_1 = car;

leader.x0 = 150;
leader.v0 = 20;

follower_1.x0 = leader.x0 - leader.l_avg - leader.v0 * follower_1.T - follower_1.s_0;
follower_1.v0 = 20;


%% First iteration

for a_i = 1:length(a_list)
    a_factor = a_list(a_i);
    
    a_max = 1*a_factor;      % maximum acceleration of the leading car
    a_min = -0.5*a_factor;   % minimum acceleration of the leading car

    fprintf('Simulation %d/%d started \n',a_i,length(a_list))
    sim('car_following_model')
    disp('Simulation done')

    model.variables = {'x','v','a'};
    model.data(1,:) = x_follower_model.Data(10001:end)';
    model.data(2,:) = x_dot_follower_model.Data(10001:end)';
    model.data(3,:) = x_ddot_follower_model.Data(10001:end)';
    model.time = x_ddot_follower_model.Time(10001:end)';

    implementation.variables = {'x','v','a'};
    implementation.data(1,:) = x_follower_implementation.Data(10001:end)';
    implementation.data(2,:) = x_ddot_follower_implementation.Data(10001:end)';
    implementation.data(3,:) = x_ddot_follower_implementation.Data(10001:end)';
    implementation.time = x_ddot_follower_implementation.Time(10001:end)';


    % Determine the critical (tau,epsilon)
    for tau_i = 1:length(tau_list)
        fprintf('Determine critical epsilon %d/%d \n',tau_i,length(tau_list))
        
        %% Low precision conformance checks
        delta_epsilon = 0.01;
        tau = tau_list(tau_i);
        epsilon = 0.03;             % guess
        disp('Low precision');
        run('conformance_check.m')

        if result == 0
            while result ~= 1
                epsilon = epsilon + delta_epsilon;
                run('conformance_check.m');
            end

        else
            while result ~= 0
                epsilon = epsilon - delta_epsilon;
                run('conformance_check.m');
            end
            epsilon = epsilon + delta_epsilon;
        end

        epsilon_raw(a_i,tau_i) = epsilon;
        %% Higher precision conformance checks
        delta_epsilon = 0.001;
        disp('High precision');
        run('conformance_check.m')

        if result == 0
            while result ~= 1
                epsilon = epsilon + delta_epsilon;
                run('conformance_check.m');
            end

        else
            while result ~= 0
                epsilon = epsilon - delta_epsilon;
                run('conformance_check.m');
            end
            epsilon = epsilon + delta_epsilon;
        end

        epsilon_list(a_i,tau_i) = epsilon;
        
    end
    
    clear model implementation x_follower_model x_dot_follower_model x_ddot_follower_model x_follower_implementation x_ddot_follower_implementation x_ddot_follower_implementation
    
end

toc     % stop timing

%% Plot the results
figure(1)
surf(a_list,tau_list,epsilon_raw')
xlabel('a')
ylabel('Tau')
zlabel('Epsilon')
title('Low precision')

figure(2)
surf(a_list,tau_list,epsilon_list')
xlabel('a')
ylabel('Tau')
zlabel('Epsilon')
title('High precision')