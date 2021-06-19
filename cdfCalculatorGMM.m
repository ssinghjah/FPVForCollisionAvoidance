function [cdfProb] = cdfCalculatorGMM(means, componentWeights, sds, x)
    numComponents = numel(componentWeights);
    cdfProb = 0;
    for i = 1:numComponents 
        cdfProb = cdfProb + componentWeights(i)*normcdf(x, means(i), sds(i));   
    end
end