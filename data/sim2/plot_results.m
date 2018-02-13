[a,tau] = meshgrid(1:0.5:2,0.5:0.5:2);

load('epsilon_1.mat')
load('epsilon_2.mat')
load('epsilon_3.mat')

eps = [epsilon_1;epsilon_2;epsilon_3];

figure(3)
surf(a,tau,eps')
xlabel('a')
ylabel('Tau')
zlabel('Epsilon')