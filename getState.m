function [aD, dO, dRHoriz, h, T_N, T_P] = getState(t, dOInit, vD, TN_MEAN, TN_SD)
    dRHoriz = 50 + t*vD;
    aD = 0;
    dO = max(dOInit - vD*t, 0);
    h = 10;
    T_N = normrnd(TN_MEAN, TN_SD);
    T_P = sqrt(dRHoriz^2 + h^2)/(3*10^8);
end

