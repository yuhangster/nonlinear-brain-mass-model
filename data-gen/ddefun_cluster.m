%% dydt
% x is a 8 by 1 vector which is x1 ... x8 
function dydt = ddefun_cluster(t, x, Z, L, c,AF,AB,AL, U, t_end)

   %function parameters 
    H_e = 3.25/1000;
    Tao_e = 10; % ms
    H_i = 29.3/1000;
    Tao_i = 15; % ms
    gamma1 = 50;
    gamma2 = 40;
    gamma3 = 12;
    gamma4 = 12;
    gamma = [gamma1 gamma2 gamma3 gamma4];

% %function parameters with +/- 5% gaussian noise
%     H_e = 3.25/1000 + normrnd(0, 0.05*3.25/1000);
%     Tao_e = 10 + normrnd(0, 0.05*10); % ms
%     H_i = 29.3/1000 + normrnd(0, 0.05*29.3/1000);
%     Tao_i = 15 + normrnd(0, 0.05*15); % ms
%     gamma1 = 50 + normrnd(0, 0.05*50);
%     gamma2 = 40 + normrnd(0, 0.05*40);
%     gamma3 = 12 + normrnd(0, 0.05*12);
%     gamma4 = 12 + normrnd(0, 0.05*12);
%     gamma = [gamma1 gamma2 gamma3 gamma4];

    
    %u - input signal
    %t_imp = 10;
    %U as an impulse at 10ms
    %u = interpU(t_imp, t_end, t);
    
    %disp(length(u))
    %%u as a gaussian noise with 0 mean and 0.05 standard deviation
    u = interpNoise(U, t_end, t);
    %%u  = interpRd(t_end,t);
    
    dydt = zeros(8*L,1);
    for i = 1:L
        dydt(1+8*(i-1):8*i,1) = column(L, i, x, Z, u, c, H_e, Tao_e, H_i, Tao_i, gamma, AF,AB,AL);
    end
end

% Ode funtcion for one column (8 by 1)
function Ode = column(L, i, x, Z, u, c, H_e, Tao_e, H_i, Tao_i, gamma, AF,AB,AL)
    %simplify terms
    k = H_e/Tao_e;
    y = x(2+8*(i-1))-x(3+8*(i-1));
    %time delayed vector
    xlag = Z(:,1);
    S_yj = zeros(L,1);
    for tp = 1:L
        yj = xlag(2+8*(tp-1)) - xlag(3+8*(tp-1));
        S_yj(tp) = S(yj);
    end
    %set up the equation
    dydt = zeros(8,1);

    dydt(1) = x(4+8*(i-1));
    dydt(4) = k*( AF(i,:)*S_yj + AL(i,:)*S_yj + c(1,i)*u+gamma(1)*(S(y)))-2*x(4+8*(i-1))/Tao_e-x(1+8*(i-1))/(Tao_e^2);
    
    dydt(2) = x(5+8*(i-1));
    dydt(5) = k*( AB(i,:)*S_yj + AL(i,:)*S_yj + gamma(2)*(S(x(1+8*(i-1)))) )-2*x(5+8*(i-1))/Tao_e-x(2+8*(i-1))/(Tao_e^2);
    
    dydt(3) = x(6+8*(i-1));
    dydt(6) = (H_i/Tao_i)*( gamma(4)*(S(x(7+8*(i-1)))) )-2*x(6+8*(i-1))/Tao_i-x(3+8*(i-1))/(Tao_i^2);
   
    dydt(7) = x(8+8*(i-1));
    dydt(8) = k*( AB(i,:)*S_yj + AL(i,:)*S_yj + gamma(3)*(S(y)) )-2*x(8+8*(i-1))/Tao_e-x(7+8*(i-1))/(Tao_e^2);

    Ode = dydt;
end

% Interpolation of the delta function
%   input: t_imp  = time of desired impulse (ms)
%          t_end = duration of the signal from 0 (ms)
%          t = time of the estimation
%   output: the interpolate delta function at t 
function signal = interpU(t_imp, t_end, t)
    ts = t_imp; %ts means a impulse at (ts) millisecond
    ft = 0:1:t_end;
    u = zeros(1,length(ft));
    u((ts/1)+1) = 1;     % set Inf to finite value
    signal = interp1(ft, u, t, 'nearest');
    %     if signal ~= 0
    %         keyboard
    %     end
end

% Interpolation of the gaussian noise (0 mean 0.05 standard deviation)function
%   input: t_end = duration of the signal from 0 (ms)
%          t = time of the estimation
%   output: the interpolate delta function at t 
function signal = interpNoise(U, t_end, t)
    ft = 0:1:t_end;
    signal = interp1(ft, U, t, 'nearest');
end

function rd = interpRd(t_end,t)
    ft = 0:100:t_end;
     u = rand(1,length(ft))/5 - 0.1;
    rd  = interp1(ft, u, t,'nearest');
end

% the function S for the fire rate 
% this is a modified version of sigmoid function
%   input: r ; e0  paramters
%          x = evaluate time 
%   output: value of S(x) function 
function fr = S(x)
    e0 = 2.5;
    r = 0.56;
    fr = -e0 + 2*e0/(1+exp(-r*x));
end

