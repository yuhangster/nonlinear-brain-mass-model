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
%plot and calculate the terms
figure;
for i = 1:length(c)
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(i,:), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
    subplot(2,2,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)));
    title('c = ', c(i));
end

%% part 2
L = 2; 
c = initC(L);
tspan = [0 600];
%plot and calculate the terms
figure;
AF = [0 0; 1 0];
AB = zeros(L,L);
AL = zeros(L,L);
lags = [delta];
for i = 1:4
    AF = AF*10;
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
    subplot(2,2,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    title('foward = ', AF(2,1));
end

%% part 3 5 consective AF only structure
L = 5; 
c = initC(L);
tspan = [0 600];
%plot and calculate the terms
AF = [0 0 0 0 0; 40 0 0 0 0; 0 40 0 0 0; 0 0 40 0 0; 0 0 0 40 0];
AB = zeros(L,L);
AL = zeros(L,L);
lags = [delta];
sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
figure;
for i =1:L
    subplot(1,5,i);
    plot(sol.x, (sol.y(2+8*(i-1),:) - sol.y(3+8*(i-1),:)));
    title('Area ', i);
end


%% part 4 Af and Ab
L = 2;
c = initC(L);
tspan = [0 1000];
%plot and calculate the terms
figure;
AF = [0 0; 40 0];
AB = zeros(2,2,4);
AB(:,:,1) = [0 1; 0 0];
AB(:,:,2) = [0 10; 0 0];
AB(:,:,3) = [0 25; 0 0];
AB(:,:,4) = [0 50; 0 0];
AL = zeros(L,L);
lags = [delta];
for i  = 1:4
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB(:,:,i),AL), lags, @(t) history(t,L), tspan, opts);
    subplot(2,2,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    title('AB = ', AB(1,2,i));
end

%% part 5 AL unidirectional
L = 2;
c = initC(L);
tspan = [0 500];
%plot and calculate the terms
figure;
AF = zeros(L,L);
AB = zeros(L,L);
AL =zeros(L,L,4);
for cur = 1:4
  AL(:,:,cur) = [0 0; 10^cur 0];  
end
lags = [delta];
for i  = 1:4
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL(:,:,i)), lags, @(t) history(t,L), tspan, opts);
    subplot(1,4,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    title('AL = ', AL(2,1,i));
end

%% part 6 AL bidirectional
L = 2;
c = initC(L);
tspan = [0 1000];
%plot and calculate the terms
figure;
AF = zeros(L,L);
AB = zeros(L,L);
AL =zeros(L,L,5);
AL(:,:,1) = [0 10; 10 0];  
AL(:,:,2) = [0 20; 20 0];  
AL(:,:,3) = [0 50; 50 0];  
AL(:,:,4) = [0 200; 200 0];  
AL(:,:,5) = [0 300; 300 0];  
lags = [delta];
for i  = 1:5
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:), H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL(:,:,i)), lags, @(t) history(t,L), tspan, opts);
    subplot(2,3,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'rx', sol.x, (sol.y(10,:) - sol.y(11,:)),'k.');
    title('AL = ', AL(2,1,i));
end
