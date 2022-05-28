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
%plot and calculate the terms
%figure;
for i = 1:4
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(i,:),AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
    subplot(2,2,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'.');
    title('c = ', c(i));
end

%resample the data to a consistent faster frequency
% fs = 100;
% str = 30;
% ed  = 170;
% figure;
% [tempy, tempt] = resample(sol.y(2,str:ed) - sol.y(3,str:ed),sol.x(str:ed),fs);
% plot(tempt,tempy,'ro',sol.x,sol.y(2,:) - sol.y(3,:),'k.');
% y = zeros(8,length(tempy));
% yp = zeros(8,length(tempy));
% for j = 1:8
%     [y(j,:),t]  = resample(sol.y(j,str:ed), sol.x(str:ed), fs);
%     [yp(j,:),t1]  = resample(sol.yp(j,str:ed), sol.x(str:ed), fs);
% end
% figure;
% %800 & 11220 from reading the t value
% plot(t(800:11220), y(2,800:11220) - y(3,800:11220),'bo', t, y(2,:) - y(3,:),'r.');
% 
% pad = zeros(8*L,1);
% writematrix( [0 t(800:11220)]', "data-12-t.csv");
% writematrix( [pad y(:,800:11220)]', "data-12-x.csv");
% writematrix( [pad yp(:,800:11220)]', "data-12-xdot.csv");

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
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
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
sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB,AL), lags, @(t) history(t,L), tspan, opts);
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
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB(:,:,i),AL), lags, @(t) history(t,L), tspan, opts);
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
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB,AL(:,:,i)), lags, @(t) history(t,L), tspan, opts);
    subplot(1,4,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    title('AL = ', AL(2,1,i));
end

%% part 6 AL bidirectional
L = 2;
c = initC(L);
tspan = [0 2000];
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
for i  = 1:4
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB,AL(:,:,i)), lags, @(t) history(t,L), tspan, opts);
    subplot(2,3,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    title('AL = ', AL(2,1,i));
end


% pad = zeros(8*L,1);
% writematrix( [0 sol.x]', "data-63-t.csv");
% writematrix( [pad sol.y]', "data-63-x.csv");
% writematrix( [pad sol.yp]', "data-63-xdot.csv");

%% part 7
L = 2;
c = initC(L);
tspan = [0 2500];
%plot and calculate the terms
figure;
AF = zeros(L,L);
AF(:,:) = [0 0; 40 0];
AB = zeros(L,L,2);
AB(:,:,1) = [0 1;0 0];
AB(:,:,2) = [0 10;0 0];
AL =zeros(L,L);
lags = [delta];

for i  = 1:2
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB(:,:,i),AL), lags, @(t) history(t,L), tspan, opts);
    subplot(1,3,i);
    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    title('AB = ', AB(1,2,i));
end
