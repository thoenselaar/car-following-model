clear all; warning off;

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
a = 1.0; 
b = 2.0;
delta = 4;
l_avg = 4.8;

sim('car_following_model')
disp('Simulation done')

%%
figure(1)
subplot(3,1,1)
hold on
plot(x_ddot_leader.Time,x_ddot_leader.Data)
plot(x_ddot_follower.Time,x_ddot_follower.Data)
plot(x_ddot_follower_model.Time,x_ddot_follower_model.Data)
legend('Leader','Follower (implementation)','Follower (model)')

subplot(3,1,2)
hold on
plot(x_dot_leader.Time,x_dot_leader.Data)
plot(x_dot_follower.Time,x_dot_follower.Data)
plot(x_dot_follower_model.Time,x_dot_follower_model.Data)
legend('Leader','Follower (implementation)','Follower (model)')

subplot(3,1,3)
hold on
plot(x_leader.Time,x_leader.Data)
plot(x_follower.Time,x_follower.Data)
plot(x_follower_model.Time,x_follower_model.Data)
legend('Leader','Follower (implementation)','Follower (model)')


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