function [cdfProb] = cdfCalculator(pmfValues, pmfProbs, x)
    cdfProb = 0;
    i = 1;
    for value = pmfValues 
        if value < x 
            cdfProb = cdfProb + pmfProbs(i);
        end
    i = i + 1;    
    end
end