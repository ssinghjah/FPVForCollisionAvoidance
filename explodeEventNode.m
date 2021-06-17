function [allSequences] = explodeEventNode(path, maxReTx, allSequences)
nextPaths = [];
currentNode = path(end);
for packetNum = 1:currentNode
    allSequences = [allSequences; [path packetNum]];
    nextPaths = [nextPaths ; [path packetNum]];
end
currentRexNum = numel(path) + 1;
numRows = size(nextPaths, 1);
if currentRexNum < maxReTx - 1
    for pathNum = [1:numRows]
        nextPath = nextPaths(pathNum,:);
        allSequences = explodeEventNode(nextPath, maxReTx, allSequences);
    end
end
% Child nodes are all packet numbers < the packet number of the event node
        % Retx attempt is one more than current
        % For each child node
            % Add to the current path
            % calculate probability of this sequence and the corresponding frame latency
            % If current retransmission attempt is not the max, explode child node again
end

