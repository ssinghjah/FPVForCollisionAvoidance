function [m,c] = getMCSFromIndex(MCSIndex)
    MODULATIONS = [2, 4, 8, 16, 32];
    CODING_RATES = [1, 1, 1, 1, 1];
    m = MODULATIONS(MCSIndex);
    c = CODING_RATES(MCSIndex);
end

