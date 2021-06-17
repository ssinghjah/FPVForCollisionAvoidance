function [averageInterFrameInterval] = expectedInterFrameInterval(nMaxRetrans, ber, T_PROP, numPackets, packetOverhead, encodedFrameBits, r, flVals, flProbs, T_ENCODE, T_DECODE)
    interFrameIntervals = [];
    numFls = numel(flVals); 
    probabilities  = [];
    for flNum = 1:numFls-1      
        interFrameIntervals = [interFrameIntervals flVals(flNum) - T_ENCODE - T_DECODE];
        probabilities = [probabilities flProbs(flNum)];
    end
    interFrameIntervals = [interFrameIntervals interFrameIntervals(end)];
    probabilities = [probabilities flProbs(end)];
    averageInterFrameInterval = sum(interFrameIntervals.*probabilities);
end

