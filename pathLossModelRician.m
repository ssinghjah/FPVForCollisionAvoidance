function [pathLoss, ricianK] = pathLossModelRician(d, h)
    k2 = 2.7631;
    ricianGaussianStd = 3.68; % C-band
    ricianGaussian = normrnd(0, ricianGaussianStd);
    ricianK = -1.17 + 0.4195*h + ricianGaussian;
    pathLoss = k2*10*log10(d);
end

