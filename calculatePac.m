function [timeInstants, pACs] = calculatePac(txTimes, tStart, tEnd, tCI, pORs, flVals, flProbs)
TIME_INTERVAL = 0.1;
pACs = [];
timeInstants = [tStart:TIME_INTERVAL:tEnd];
timeIndices = find(txTimes > tStart-0.001);
frameNumStart = timeIndices(1);
for t = [tStart:TIME_INTERVAL:tEnd] 
    
    if t > tCI
        pACs = [pACs, 0];
        continue;
    end
    
    % get max frame num
    timeIndices = find(txTimes > t);
    if numel(timeIndices) == 0
        frameNumMax = numel(timeIndices);
    else
        frameNumMax = timeIndices(1) - 1;
    end
    probTerm = 0;
    
    % iterate over all frames till maxIndex
    for frameNum = [frameNumStart:frameNumMax]
        txTime = txTimes(frameNum);
        
        % Get probability that each frame is received by time t
        pSuccess = cdfCalculator(cell2mat(flVals(frameNum)), cell2mat(flProbs(frameNum)), t - txTime);
        pFailure = 1;
        for j = [frameNum+1:frameNumMax]
            pFailure = (1 - cdfCalculator(cell2mat(flVals(j)), cell2mat(flProbs(j)), t - txTimes(j)))*pFailure;
        end
        probTerm = probTerm + pFailure*pSuccess*pORs(frameNum);
    end
    pACs = [pACs, probTerm];
  end
end
