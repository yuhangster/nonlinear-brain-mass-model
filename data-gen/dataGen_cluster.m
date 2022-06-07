%~~~~~~~~~~~~~~~~~~~~~~Data Generation V2~~~~~~~~~~~~~~~~~~~~~~~~~%
%This code use cluster to generate the data for single column 
%The data is saved in 'single-column-data' folder  
%The output will be single '.mat' file for each unique arrayNum
%Dimension of the data is (Value at time stamps * Category * Trails)

%local testing 
clear all
close all 
clc
arrayNum=1;

%Set the random seed
rng('default')
rng(arrayNum)
%% data generation
%Parameter Initialization
L = 1; %L is the total number of columns
c = initC(L);
AF = 0;
AB=0;
AL=0;
tspan = [0 400];
delta = 10; % ms
lags = [delta];
opts = odeset('MaxStep',1);

%resample the data to a consistent faster frequency
fs = 10;
%test 1: ed = 17000; str = 1500
%test 2: ed = 30000; str = 500
str = 50;
ed  = 3000;

%number of trials simulated
itr = 2;

%zero padding
pad = zeros(8*L,1);

%no zero padding 
len = ed - str + 1; 

%zero padding 
% len = ed - str + 2; 

data_t = zeros(len, 1, itr);
data_x = zeros(len, 8*L, itr);
data_xdot = zeros(len, 8*L, itr);

figure;

%Use parfor for parallel running
for i = 1:itr
    % c = 2 case
    disp(['Iteration: ', num2str(i)])
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

    plot(t(str:ed), y(2,str:ed) - y(3,str:ed),'o', t, y(2,:) - y(3,:),'.');
    hold on

    %data generation

    %no data padding
    data_t(:,:,i) = t(str:ed);
    data_x(:,:,i) = y(:,str:ed)';
    data_xdot(:,:,i) = yp(:,str:ed)';

%     %zero padding (for csv) 
%     data_t(:,:,i) = [0; t(str:ed)]';
%     data_x(:,:,i) = [pad y(:,str:ed)];
%     data_xdot(:,:,i) = [pad yp(:,str:ed)];
end

%Make directory data if not exist
if ~isfolder('single-column-dataMat')
    mkdir('single-column-dataMat')
end

%Export the file to single-column-dataMat
fNameOut = ['data_' num2str(arrayNum)];
save(fullfile('single-column-dataMat', fNameOut), 'data_t', 'data_x', 'data_xdot')

