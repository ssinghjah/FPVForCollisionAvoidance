function [lowerVal, upperVal] = calculate99PercConfidenceInterval(data) 
    CI_Const = 2.576;
    stdError = std(data)/sqrt(length(data));
    lowerVal = mean(data) - CI_Const*stdError;
    upperVal =  mean(data) + CI_Const*stdError;
end

