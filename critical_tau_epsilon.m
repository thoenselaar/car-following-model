clear all; warning off;

tic 

load('data/eps.mat')

count = 1;
% last_epsilon = 0.04;

a_list = 1:0.5:2; 
for a_i = 1:length(a_list)
    a = a_list(a_i);
    
    [count a]
    
    a_max = 1;      % maximum acceleration of the leading car
    a_min = -0.5;   % minimum acceleration of the leading car

    T_THRESHOLD = 1;   % time threshold
    D_THRESHOLD = 4;   % distance threshold
    S_THRESHOLD = 0.5; % speed threshold

    N = 1000; % moving average parameter

    %% car parameters
    v_0 = 120;
    T = 1.5;
    s_0 = 2.0;
    % a = 1.0;
    b = 2.0;
    delta = 4;
    l_avg = 4.8;

    fprintf('Simulation started, a=%.2f ',a)
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


%     tau_list = 0.1:0.1:3.5;
    tau_list = 0.5:0.5:2;
    delta_epsilon = 0.001;

    for tau_i = 1:length(tau_list)
        waitbar(tau_i / length(tau_list))
        tau = tau_list(tau_i);
        epsilon = eps(a_i,tau_i);
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

        epsilon_list(tau_i) = epsilon;
%         last_epsilon = epsilon;
    end
%         % Save the variables
    temp_path = pwd;
    cd data/

    tau_name = strcat('tau_',num2str(count));
    eval([tau_name '=tau_list;']);
    tau_save_name = strcat(tau_name,'.mat');
    save(tau_save_name,tau_name);

    epsilon_name = strcat('epsilon_',num2str(count));
    eval([epsilon_name '=epsilon_list;']);
    epsilon_save_name = strcat(epsilon_name,'.mat');
    save(epsilon_save_name,epsilon_name);

    count = count + 1;
    cd(temp_path)
    clearex('count','a_list','eps')
        
end



toc
% 
% %% Plot the results
% figure(1)
% subplot(3,1,1)
% hold on
% plot(x_ddot_leader.Time,x_ddot_leader.Data)
% plot(x_ddot_follower_implementation.Time,x_ddot_follower_implementation.Data)
% plot(x_ddot_follower_model.Time,x_ddot_follower_model.Data)
% legend('Leader','Follower (implementation)','Follower (model)')
% 
% subplot(3,1,2)
% hold on
% plot(x_dot_leader.Time,x_dot_leader.Data)
% plot(x_dot_follower_implementation.Time,x_dot_follower_implementation.Data)
% plot(x_dot_follower_model.Time,x_dot_follower_model.Data)
% legend('Leader','Follower (implementation)','Follower (model)')
% 
% subplot(3,1,3)
% hold on
% plot(x_leader.Time,x_leader.Data)
% plot(x_follower_implementation.Time,x_follower_implementation.Data)
% plot(x_follower_model.Time,x_follower_model.Data)
% legend('Leader','Follower (implementation)','Follower (model)')
% 
% end


%%

% figure(1)
% plot(vel_leader.Time, vel_leader.Data)
% hold on
% plot(vel_idm.Time, vel_idm.Data)
% plot(vel_can.Time, vel_can.Data)
% legend('leader','idm','can')
% 




% times = timestamp.Time;
% time_data = timestamp.Data;
% data_previous = time_data(1);
% send_times = [];
% 
% for i = 1:length(time_data)
%     if time_data(i) ~= data_previous
%         send_times = [send_times times(i)];
%         data_previous = time_data(i);
%     end
% end
% 
% figure(2)
% plot(send_times,1:length(send_times),'.')
% 
% differences = diff(send_times);
% figure(3)
% plot(differences )
% 
% figure(4)
% hist(differences)