clear all; warning off;
tic     % start timing

%% Variables being varied
a_list = 1:0.25:2;
tau_list = 0.5:0.5:2;

%% Model parameters
stepsize = 1e-3;

T_MIN_THRESHOLD = 0.1;    % time threshold
T_MAX_THRESHOLD = 1;    % time threshold
D_THRESHOLD = 4;    % distance threshold
S_THRESHOLD = 0.5;  % speed threshold
N = 1000;           % moving average parameter

%% car parameters
car.v_0 = 120;
car.delta = 4;
car.T = 1.5;
car.s_0 = 2.0;
car.a = 1.4;
car.b = 2.0;
car.l_avg = 4.8;
    
leader = car;
follower_1 = car;

leader.x0 = 150;
leader.v0 = 20;

follower_1.x0 = leader.x0 - leader.l_avg - leader.v0 * follower_1.T - follower_1.s_0;
follower_1.v0 = 20;

% figure(2)
%% First iteration

for a_i = 1:length(a_list)
    follower_1.a = a_list(a_i);
    
    a_max = 1;      % maximum acceleration of the leading car
    a_min = -0.5;   % minimum acceleration of the leading car

    fprintf('%s Simulation %d/%d started \n',datetime('now', 'format','HH:mm:ss'),a_i,length(a_list))
    sim('car_following_model')
    fprintf('%s Simulation done \n',datetime('now', 'format','HH:mm:ss'))

    t_start = 10 / stepsize + 1;
    
    model.variables = {'x','v','a','delta_x'};
    model.data(1,:) = x_follower_model.Data(t_start:end)';
    model.data(2,:) = x_dot_follower_model.Data(t_start:end)';
    model.data(3,:) = x_ddot_follower_model.Data(t_start:end)';
    model.data(4,:) = x_leader.Data(t_start:end)' - x_follower_model.Data(t_start:end)';
    model.time = x_ddot_follower_model.Time(t_start:end)';

    implementation.variables = {'x','v','a','delta_x'};
    implementation.data(1,:) = x_follower_implementation.Data(t_start:end)';
    implementation.data(2,:) = x_ddot_follower_implementation.Data(t_start:end)';
    implementation.data(3,:) = x_ddot_follower_implementation.Data(t_start:end)';
    implementation.data(4,:) = x_leader.Data(t_start:end)' - x_follower_implementation.Data(t_start:end)';
    implementation.time = x_ddot_follower_implementation.Time(t_start:end)';
    
    % Determine the critical (tau,epsilon)
    for tau_i = 1:length(tau_list)
        disp('-------------------------------------------------------')
        fprintf('%s Determine critical epsilon %d/%d \n',datetime('now', 'format','HH:mm:ss'),tau_i,length(tau_list))
        %% Low precision conformance checks
        delta_epsilon = 0.01;
        tau = tau_list(tau_i);
        epsilon = 0.03;             % guess
        fprintf('%s Low precision \n',datetime('now', 'format','HH:mm:ss'));
        fprintf('%s Trying tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
        run('conformance_check.m')

        if result == 0
            while result ~= 1
                epsilon = epsilon + delta_epsilon;
                fprintf('%s Trying tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
                run('conformance_check.m');
            end

        else
            while result ~= 0
                epsilon = epsilon - delta_epsilon;
                fprintf('%s Trying tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
                run('conformance_check.m');
            end
            epsilon = epsilon + delta_epsilon;
        end
        fprintf('%s Found critical tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
        epsilon_raw(a_i,tau_i) = epsilon;
        
        %% Higher precision conformance checks
        delta_epsilon = 0.001;
        fprintf('%s High precision \n',datetime('now', 'format','HH:mm:ss'));
        run('conformance_check.m')

        if result == 0
            while result ~= 1
                epsilon = epsilon + delta_epsilon;
                fprintf('%s Trying tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
                run('conformance_check.m');
            end

        else
            while result ~= 0
                epsilon = epsilon - delta_epsilon;
                fprintf('%s Trying tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
                run('conformance_check.m');
            end
            epsilon = epsilon + delta_epsilon;
        end

        fprintf('%s Found critical tau=%.2f, epsilon=%.3f \n',datetime('now', 'format','HH:mm:ss'),tau,epsilon);
        epsilon_list(a_i,tau_i) = epsilon;
        
    end
    
    clear model implementation x_follower_model x_dot_follower_model x_ddot_follower_model x_follower_implementation x_ddot_follower_implementation x_ddot_follower_implementation
    fprintf('\n');
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