function [pSequence] = pTxSequence(sequence, ber, packetSize)
    numStates = numel(sequence);
    pPacketError = 1 - (1-ber)^packetSize;
    pSequence = 1;
    if numStates == 1
        error("Only 1 state in the transmission sequence")
    end
    for stateNum = 1:numStates-1
        successes = sequence(stateNum) - sequence(stateNum + 1);
        errors = sequence(stateNum + 1);
        pTransition = nchoosek(sequence(stateNum), errors)*(pPacketError^errors)*(1-pPacketError)^(successes);
        pSequence = pSequence*pTransition;
    end
end

