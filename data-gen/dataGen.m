%%solve the differential equation in ode 45
clear all;
close all;
clc;
%%sol.y 
%%sol.yp are x and x_dot
delta = 10; % ms
opts = odeset('MaxStep',1);
%% part 1
L = 1; %L is the total number of columns
c = initC(L);
AF = 0;
AB=0;
AL=0;
tspan = [0 400];
lags = [delta];
%resample the data to a consistent faster frequency
fs = 100;
str = 1;
ed  = 4000;

figure;
for i = 1:10
    % c = 2 case
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB,AL), lags, @(t) history(t,L), tspan, opts);

    [tempy, tempt] = resample(sol.y(2,:) - sol.y(3,:),sol.x(:),fs);
    plot(sol.x,sol.y(2,:) - sol.y(3,:),'.');

    %800 & 11220 from reading the t value
    %plot(t(800:11220), y(2,800:11220) - y(3,800:11220),'bo', t, y(2,:) - y(3,:),'r.');
end
%     y = zeros(8,length(tempy));
%     yp = zeros(8,length(tempy));
%     for j = 1:8
%         [y(j,:),t]  = resample(sol.y(j,:), sol.x(:), fs);
%         [yp(j,:),t1]  = resample(sol.yp(j,:), sol.x(:), fs);
%     end
% pad = zeros(8*L,1);
% writematrix( [0 t(800:11220)]', "data-12-t.csv");
% writematrix( [pad y(:,800:11220)]', "data-12-x.csv");
% writematrix( [pad yp(:,800:11220)]', "data-12-xdot.csv");