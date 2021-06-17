function [pmfVals, pmfProbs] = pmfFrameLatencyPacketReTx(maxReTx, ber, numPackets, PACKET_OVERHEAD, PACKET_SIZE, txRate, T_N, T_P, T_O, T_ENCODE, T_DECODE, FL_MAX)
    EPSILON = 10^-5;
    STxAll = {numPackets};
    pmfVals = [];
    pmfProbs = [];
    frontier = 1;
    for nTx = [1:maxReTx+1]
        if nTx == maxReTx + 1
            for seqNum = 1:numel(STxAll)
                sequence = [cell2mat(STxAll(seqNum)) 0];
                pSequence = pTxSequence(sequence, ber, PACKET_SIZE);
                latSeq = latTxSequence(sequence, PACKET_SIZE, txRate, T_O, T_P, PACKET_OVERHEAD);
                pmfProbs = [pmfProbs pSequence];
                pmfVals = [pmfVals latSeq];
            end
            continue;
         end
        startLen = numel(STxAll);
        for seqNum = frontier:numel(STxAll)
            sequence = cell2mat(STxAll(seqNum));
            
            % get all next valid sequences
            sLast = sequence(end);
            for sNext = [1:sLast]
                candidateSequence = [sequence sNext];
                pCandidateSequence = pTxSequence(candidateSequence, ber, PACKET_SIZE);
                if pCandidateSequence > EPSILON
                    STxAll = [STxAll candidateSequence];
                end
            end
        end
        frontier = startLen + 1;
    end
    
    pLoss = 1 - sum(pmfProbs);
    pmfProbs = [pmfProbs, pLoss];
    pmfVals = pmfVals + T_ENCODE + T_DECODE + T_P + T_N;
    pmfVals= [pmfVals, FL_MAX];
end
