function [latSequence] = latTxSequence(sequence, packetSize, r, T_O, T_P, PACKET_OVERHEAD)
    latSequence = 0;
    numStates = numel(sequence);
    if numStates == 1
        error("Only 1 state in the transmission sequence")
    end
    for stateNum = 1:numStates-1
        numPackets = sequence(stateNum);
        latSequence = latSequence + T_O + numPackets*(packetSize + PACKET_OVERHEAD)/r;
    end
    latSequence = latSequence - T_O + T_P;
end

