function [ber] = calculateErrorRateMQAM(M, C, SNR, B, r)
    EbNo = SNR*B/r;
    ber = (4/log2(M))*(1-1/sqrt(M));
    summation = 0;
    for i = 1:ceil(sqrt(M)/2)
        summation = summation + qfunc((2*i-1)*sqrt(3*EbNo*log2(M)/((M-1))));
    end 
    ber = ber*summation;
end

