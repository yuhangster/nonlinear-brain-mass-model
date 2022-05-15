%% dydt
% x is a 8 by 1 vector which is x1 ... x8 
function dydt = ddefun(t, x, Z, L, c, H_e, Tao_e,H_i, Tao_i, gamma,AF,AB,AL)
    t_imp = 10;
    t_end = 600;
    u = interpU(t_imp, t_end, t);
    
    dydt = zeros(8*L,1);
    for i = 1:L
        dydt(1+8*(i-1):8*i,1) = column(L, i, t, x, Z, u, c, H_e, Tao_e, H_i, Tao_i, gamma, AF,AB,AL);
    end
end

% Ode funtcion for one column (8 by 1)
function Ode = column(L, i, t, x, Z, u, c, H_e, Tao_e, H_i, Tao_i, gamma, AF,AB,AL)
    %simplify terms
    k = H_e/Tao_e;
    y = x(2+8*(i-1))-x(3+8*(i-1));
    %set up the equation
    dydt = zeros(8,1);
    dydt(1) = x(4+8*(i-1));
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     xlag1 = Z(:,1);
%     S_yj = zeros(L,1); 
%     for k = 1:L
%         tmp = xlag1(2+8*(k-1)) - xlag1(3+8*(k-1));
%         S_yj(k,1) = S(tmp);
%     end
    %dydt(4) = k*( AF(i,1)*S_yj(1)+c(1,i)*u+gamma(1)*(S(y)))-2*x(4+8*(i-1))/Tao_e-x(1+8*(i-1))/(Tao_e^2);
    xlag = Z(:,1);
    S_yj = zeros(L,1);
    for tp = 1:L
        yj = xlag(2+8*(tp-1)) - xlag(3+8*(tp-1));
        S_yj(tp) = S(yj);
    end
    dydt(4) = k*( AF(i,:)*S_yj+c(1,i)*u+gamma(1)*(S(y)))-2*x(4+8*(i-1))/Tao_e-x(1+8*(i-1))/(Tao_e^2);
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    dydt(2) = x(5+8*(i-1));
    dydt(5) = k*( gamma(2)*(S(x(1+8*(i-1)))) )-2*x(5+8*(i-1))/Tao_e-x(2+8*(i-1))/(Tao_e^2);
    dydt(3) = x(6+8*(i-1));
    dydt(6) = (H_i/Tao_i)*( gamma(4)*(S(x(7+8*(i-1)))) )-2*x(6+8*(i-1))/Tao_i-x(3+8*(i-1))/(Tao_i^2);
    dydt(7) = x(8+8*(i-1));
    dydt(8) = k*( gamma(3)*(S(y)) )-2*x(8+8*(i-1))/Tao_e-x(7+8*(i-1))/(Tao_e^2);

    Ode = dydt;
end

% Interpolation of the delta function
%   input: t_imp  = time of desired impulse (ms)
%          t_end = duration of the signal from 0 (ms)
%          t = time of the estimation
%   output: the interpolate delta function at t 
function signal = interpU(t_imp, t_end, t)
    ts = t_imp; %ts means a impulse at (ts) second
    ft = 0:1:t_end;
    u = zeros(1,length(ft));
    u((ts/1)+1) = 1;     % set Inf to finite value
    signal = interp1(ft, u, t, 'nearest');
    %     if signal ~= 0
    %         keyboard
    %     end
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

