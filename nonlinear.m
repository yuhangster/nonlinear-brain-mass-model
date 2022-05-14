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

% initialize the second column to the 1st column instead of zero
%% part 1
L = 1; %L is the total number of columns
AF = 0;
AB=0;
AL=0;
tspan = [0 400];
x0 = zeros(1,8*L);
%plot and calculate the terms
figure;
for i = 1:length(c)
    [t,x] = ode45(@(t,x) odefun(t, x, L, c(i), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL,delta), tspan, x0, opts);
    subplot(2,2,i);
    plot(t, (x(:,2) - x(:,3)));
end

%% part 2
L = 2; 
x0 = zeros(1,8*L);
tspan = [0 800];
%plot and calculate the terms
figure;
AF = [0 0; 10/10 0];
for i = 1:4
    AF = AF*10;
    [t,x] = ode45(@(t,x) odefun(t, x, L, c(2), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL,delta), tspan, x0, opts);
    subplot(2,2,i);
    plot(t, (x(:,2) - x(:,3)),'r', t, (x(:,10) - x(:,11)),'k');
    title('foward = ', AF(2,1));
end
