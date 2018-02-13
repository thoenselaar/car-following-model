% clear all;

load('tau_1.mat');


load('epsilon_1.mat');


%% plot the results

figure(2)
plot(tau_1,epsilon_1, 'o-', 'LineWidth', 2)

hold off
xlabel('\tau','FontSize',32)
ylabel('\epsilon','FontSize',32)
title('Critical values for (\tau,\epsilon)','FontSize',24)
% set(h,'FontSize',16);
set(gca,'fontsize',16)