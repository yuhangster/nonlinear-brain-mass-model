%~~~~~~~~~~~~~~~~~Data Generation V1~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%This code generates the data for single column
%The data is saved in  'single-column-data' directory 
%The outputs consist of three separate csv files for t, x, xdot

clear all;
close all;
clc;

%% data generation part 1
% %Set the random seed
% arrayNum = 1;
% rng('default')
% rng(arrayNum)
% %noisy input U
% t_end = 2500;
% ft = 0:1:t_end;
% u = normrnd(0,0.05,[1,length(ft)]);
% 
% %Parameter Initialization
% L = 1; %L is the total number of columns
% c = initC(L);
% AF = 0;
% AB=0;
% AL=0;
% tspan = [0 t_end];
% delta = 10; % ms
% lags = [delta];
% opts = odeset('MaxStep',1);
% 
% %resample the data to a consistent faster frequency
% fs = 100;
% %test 1: ed = 17000; str = 1500
% %test 2: ed = 30000; str = 500
% str = 50;
% ed  = t_end*100-2000;
% %number of trials simulated
% itr = 2;
% %zero padding
% pad = zeros(8*L,1);
% 
% % data_t = zeros(1,1);
% % data_x = pad;
% % data_xdot = pad;
% 
% %15502
% len = ed - str +2;
% data_t = zeros(1,len,itr);
% data_x = zeros(8*L,len,itr);
% data_xdot = zeros(8*L,len,itr);
% 
% figure;
% for i = 1:itr
%     % c = 2 case
%     sol = dde23(@(t,x,Z) ddefun_cluster(t, x, Z, L, c(2,:),AF,AB,AL, u, t_end), lags, @(t) history(t,L), tspan, opts);
% 
%     [tempy, tempt] = resample(sol.y(2,:) - sol.y(3,:),sol.x(:),fs);
% 
%     %plot(sol.x,sol.y(2,:) - sol.y(3,:));
%     %hold on
%     
%     y = zeros(8,length(tempy));
%     yp = zeros(8,length(tempy));
%     for j = 1:8
%         [y(j,:),t]  = resample(sol.y(j,:), sol.x(:), fs);
%         [yp(j,:),t1]  = resample(sol.yp(j,:), sol.x(:), fs);
%     end
% 
%     %sanity checking
% %     if y(1,:) ~= y(4,:)
% %         keyboard
% %     elseif y(2,:) ~= y(5,:)
% %         keyboard
% %     elseif y(3,:) ~= y(6,:)
% %         keyboard
% %     elseif y(7,:) ~= y(8,:)
% %         keyboard
% %     end
% 
%     %1500 & 17000 from reading the graph
%     plot(t(str:ed), y(2,str:ed) - y(3,str:ed),'o', t, y(2,:) - y(3,:),'.');
%     hold on
% 
%     %data generation
% %     data_t(:,:,i) = [0; t(str:ed)]';
% %     data_x(:,:,i) = [pad y(:,str:ed)];
% %     data_xdot(:,:,i) = [pad yp(:,str:ed)];
% % 
% %     writematrix( data_t(:,:,i)', "C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-dataCSV\No." + i +" data-t.csv");
% %     writematrix( data_x(:,:,i)', "C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-dataCSV\No." + i +" data-x.csv");
% %     writematrix( data_xdot(:,:,i)', "C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-dataCSV\No." + i +" data-xdot.csv");
% end
% 
%  
% if ~isfolder('data-noisyIn')
%     mkdir('data-noisyIn')
% end
% 
% fNameOut = ['data_' num2str(arrayNum)];
% save(fullfile('data-noisyIn', fNameOut), 'data_t', 'data_x', 'data_xdot')

%% Data generation Part 4 fixed AB

%noisy input U
t_end = 1000;
ft = 0:1:t_end;

% model parameter initialization
%choose AB to be the 4th one
L = 2;
c = initC(L);
tspan = [0 t_end];
AF = [0 0; 40 0];
AB = zeros(2,2,4);
AB(:,:,1) = [0 1; 0 0];
AB(:,:,2) = [0 10; 0 0];
AB(:,:,3) = [0 25; 0 0];
AB(:,:,4) = [0 50; 0 0];
AL = zeros(L,L);
%change the lags to be 0
%lag have to be positive, choose a small positive instead
delta = 0.00001;
lags = [delta];
opts = odeset('MaxStep',1);

%simulation parameter initializaiton
fs = 10;
str = 100; % the start index
ed = t_end*fs-10; % the end index (10 is selected randomly)
itr = 10;

%zero padding
pad = zeros(8*L,1);
len = ed - str +1;
data_t = zeros(len,1,itr);
data_x = zeros(len,8*L,itr);
data_xdot = zeros(len,8*L,itr);

figure;
for i  = 1:itr
    %Set the random seed
    arrayNum = i;
    rng('default')
    rng(arrayNum)
    u = normrnd(0,0.05,[1,length(ft)]);
    %AB --4th case
    sol = dde23(@(t,x,Z) ddefun_cluster(t, x, Z, L, c(2,:),AF,AB(:,:,4),AL, u, t_end), lags, @(t) history(t,L), tspan, opts);
    
    [tempy, tempt] = resample(sol.y(2,:) - sol.y(3,:),sol.x(:),fs);
    y = zeros(16,length(tempy));
    yp = zeros(16,length(tempy));
    for j = 1:16
        [y(j,:),t]  = resample(sol.y(j,:), sol.x(:), fs);
        [yp(j,:),t1]  = resample(sol.yp(j,:), sol.x(:), fs);
    end

    plot(sol.x, (sol.y(2,:) - sol.y(3,:)),'r', sol.x, (sol.y(10,:) - sol.y(11,:)),'k');
    hold on 
    title('AB = ', AB(1,2,4));

    %data generation
    data_t(:,:,i) = t(str:ed);
    data_x(:,:,i) = y(:,str:ed)';
    data_xdot(:,:,i) = yp(:,str:ed)';
end
hold off

if ~isfolder('data2col-noisyIn')
    mkdir('data2col-noisyIn')
end

fNameOut = ['data2col_' num2str(arrayNum)];
save(fullfile('data2col-noisyIn', fNameOut), 'data_t', 'data_x', 'data_xdot')
