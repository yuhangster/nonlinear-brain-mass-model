%%solve the differential equation in ode 45
clear all;
close all;
clc;
%%sol.y 
%%sol.yp are x and x_dot
delta = 10; % ms
opts = odeset('MaxStep',1);
%% data generation
L = 1; %L is the total number of columns
c = initC(L);
AF = 0;
AB=0;
AL=0;
tspan = [0 400];
lags = [delta];

%resample the data to a consistent faster frequency
fs = 100;
str = 1500;
ed  = 17000;
%number of trials simulated
itr = 100;
%zero padding
pad = zeros(8*L,1);
data_t = zeros(1,1);
data_x = pad;
data_xdot = pad;

figure;
for i = 1:itr
    % c = 2 case
    sol = dde23(@(t,x,Z) ddefun(t, x, Z, L, c(2,:),AF,AB,AL), lags, @(t) history(t,L), tspan, opts);

    [tempy, tempt] = resample(sol.y(2,:) - sol.y(3,:),sol.x(:),fs);

    %plot(sol.x,sol.y(2,:) - sol.y(3,:));
    %hold on
    
    y = zeros(8,length(tempy));
    yp = zeros(8,length(tempy));
    for j = 1:8
        [y(j,:),t]  = resample(sol.y(j,:), sol.x(:), fs);
        [yp(j,:),t1]  = resample(sol.yp(j,:), sol.x(:), fs);
    end

    %sanity checking
    if y(1,:) ~= y(4,:)
        keyboard
    elseif y(2,:) ~= y(5,:)
        keyboard
    elseif y(3,:) ~= y(6,:)
        keyboard
    elseif y(7,:) ~= y(8,:)
        keyboard
    end

    %1500 & 17000 from reading the graph
    plot(t(1500:17000), y(2,1500:17000) - y(3,1500:17000),'o', t, y(2,:) - y(3,:),'.');
    hold on
    
    %prelocation of the memory for faster speed
    %only the first iteration will have the 

    data_t = [data_t; t(str:ed)];
    data_x = [data_x y(:,str:ed)];
    data_xdot = [data_xdot yp(:,str:ed)];
end
 
writematrix( data_t, "data-t.csv");
writematrix( data_x', "data-x.csv");
writematrix( data_xdot', "data-xdot.csv");