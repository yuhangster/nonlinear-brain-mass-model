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
itr = 200;
%zero padding
pad = zeros(8*L,1);

% data_t = zeros(1,1);
% data_x = pad;
% data_xdot = pad;

%15502
len = ed - str +2;
data_t = zeros(1,len,itr);
data_x = zeros(8*L,len,itr);
data_xdot = zeros(8*L,len,itr);

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
    plot(t(str:ed), y(2,str:ed) - y(3,str:ed),'o', t, y(2,:) - y(3,:),'.');
    hold on
    %prelocation of the memory for faster speed
    %only the first iteration will have the 

    data_t(:,:,i) = [0; t(str:ed)]';
    data_x(:,:,i) = [pad y(:,str:ed)];
    data_xdot(:,:,i) = [pad yp(:,str:ed)];

    writematrix( data_t(:,:,i)', "C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-data\No." + i +" data-t.csv");
    writematrix( data_x(:,:,i)', "C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-data\No." + i +" data-x.csv");
    writematrix( data_xdot(:,:,i)', "C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-data\No." + i +" data-xdot.csv");
end
 
