function [SNR] = calculateSNR(dR, h)
    BANDWIDTH = 10e6;
    SIGMA = 1.380649*10^(-23)*298;
    I = 20;
    txPower = 0; % dBm
    [pathLoss, K] = pathLossModelRician(dR, h);
    dominantPower = txPower - pathLoss;
    fadingPower = dominantPower - K;
    rxPower = 10*log10(10^(0.1*dominantPower) + 10^(0.1*fadingPower));
    N = 10*log10(BANDWIDTH*SIGMA) + 30;
    SNR = rxPower - N - I;
    SNR = 10^(SNR*0.1);
end

