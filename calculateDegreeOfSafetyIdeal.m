function [degreeOfSafetyIdeal] = calculateDegreeOfSafetyIdeal(T_START, T_END, T_INTERVAL, T_CI)
    % From 0 to T_CI, all ones
    numOnes = floor((T_CI - T_START)/T_INTERVAL) + 1;
    % From T_CI to T_END, all zeros
    numZeros = floor((T_END - T_CI)/T_INTERVAL);
    degreeOfSafetyIdeal = sum(numOnes)/(numOnes + numZeros); 
end

