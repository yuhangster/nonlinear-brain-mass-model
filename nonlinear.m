%%solve the differential equation in ode 45
clear all;
close all;
clc;

%initialization
H_e = 3.25/1000;
Tao_e = 10; % ms
H_i = 29.3/1000;
Tao_i = 15; % ms
gamma1 = 50;
gamma2 = 40;
gamma3 = 12;
gamma4 = 12;
gamma = [gamma1 gamma2 gamma3 gamma4];
c = [1 1000 1e6 1e9];
delta = 10; % ms
opts = odeset('MaxStep',1);
AB=0;
AL=0;

%% part 1
L = 1; %L is the total number of columns
AF = 0;
AB=0;
AL=0;
tspan = [0 400];
lags = [delta delta];
x0 = zeros(1,8*L);
%plot and calculate the terms
figure;
for i = 1:length(c)
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
    subplot(2,2,i);
    plot(sol.x, -(sol.yp(2,:) - sol.yp(3,:)));
end

%% part 2
L = 2; 
x0 = zeros(1,8*L);
tspan = [0 600];
%plot and calculate the terms
figure;
AF = [0 0; 1 0];
lags = [delta delta];
for i = 1:4
    AF = AF*10;
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
    subplot(2,2,i);
    plot(sol.x, -(sol.y(2,:) - sol.y(3,:)),'r', sol.x, -(sol.y(10,:) - sol.y(11,:)),'k');
    title('foward = ', AF(2,1));
end
