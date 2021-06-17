function [pACts, pACs] = calculatePACNoLC(dOInit, vD)
    
    % Parameters
    [GOP, QP, PACKET_OVERHEAD, PACKET_SIZE, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR, T_HUMAN_RESPONSE, T_ENCODE, T_DECODE, T_PROPAGATION, T_RETRANS, FL_MAX, BRAKING_ACCEL, PAC_TIME_INTERVAL] = getParameters();
    RESOLUTIONS = [426, 640, 854, 1280, 1920, 2560, 3840 
                   240, 360, 480, 720, 1080, 1440, 2160];   
    N_RETRANS   = [0:2];
    SCENARIO = 1;
    t=0;
    dO = dOInit;
    T_CI = dO/vD - vD/(BRAKING_ACCEL) - (T_HUMAN_RESPONSE + T_PROPAGATION);
    T_END = dOInit/vD;
    ts = [];
    bestResolutions = [];
    bestNumRetxs = [];
    bestMCSs = [];
    pORs = [];
    flPDFVals= {};
    flPDFProbs = {};
    bestPORs = [];
    MCSs = 1:5
    [GOP, QP, PACKET_OVERHEAD, PACKET_SIZE, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR, T_HUMAN_RESPONSE, T_ENCODE, T_DECODE, T_PROPAGATION, T_RETRANS, FL_MAX,  BRAKING_ACCEL, PAC_TIME_INTERVAL, B] = getParameters();
    while t < T_END
        % State
        aD = 0;
        aBD = 4;
        bestReward = -1;
        bestResolution = [-1 ; -1];
        bestReTranses = -1;
        bestPacketSizes = [];
        bestPOR = -1;
        bestMCS = -1;
        bestTimeStep = 0;
        bestPDFVals = zeros(1, max(N_RETRANS)+2);
        bestPDFProbs = zeros(1, max(N_RETRANS)+2);
        [aD, dO, dRHoriz, h, T_N, T_P] = getState(t, dOInit, vD);

            % action
            for resolution = RESOLUTIONS
                %resolution
                for nMaxRetx = N_RETRANS
                    for MCS = MCSs
                        [M,C] = getMCSFromIndex(MCS);
                        TX_RATE = calculateTxRate(M,C);
                        SNR = calculateSNR(dRHoriz, h);
                        BER = calculateErrorRate(M, C, SNR, B, TX_RATE);
                        wFr = resolution(1);
                        hFr = resolution(2);
                        
                        %%%%%%%%%%%%%%%%%%
                        % Reward Calculation
                        % calculate POR
                        pOR = pObstacleRecognizableExp(hFr, dO, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR); 
                        % calculate TC,i as roots of the equation
                        syms a b c x
                        TvisResp = (T_HUMAN_RESPONSE + T_P + T_N);
                        a = aD^2/(2*aBD) + 0.5*aD;
                        b = aD*vD/aBD + vD + 0.5*aD*(TvisResp);
                        c = vD^2/(2*aBD) + (vD)*(TvisResp) +0.5*aD*(TvisResp)^2 - dO;
                        roots = solve(a*x^2 + b*x + c, x, 'Real', true);
                        roots = roots(roots > 0);
                        Tc = getValidTc(roots);
                        if Tc == -1
                            disp('Error: no valid value found for Tc');
                            continue;
                        end
                        % calculate CDF at TC,i
                        ENCODED_FRAME_BITS = calculateJPEGSize(wFr, hFr);

                        NUM_PACKETS = ceil(ENCODED_FRAME_BITS/PACKET_SIZE);
                        txTime = (ENCODED_FRAME_BITS + NUM_PACKETS * PACKET_OVERHEAD) / (TX_RATE);
                        [flValues, flProbabilities] = pmfFrameLatencyPacketReTx(nMaxRetx, BER,  NUM_PACKETS, PACKET_OVERHEAD, ENCODED_FRAME_BITS, TX_RATE, T_N, T_P);
                        cdfValue = cdfCalculator(flValues, flProbabilities, Tc);
                        timeStep = expectedInterFrameInterval(nMaxRetx, BER, T_P, NUM_PACKETS, PACKET_OVERHEAD, ENCODED_FRAME_BITS, TX_RATE, flValues, flProbabilities);

                        % calculate reward
                        reward = cdfValue * pOR;

                         if dO > 10^4
                                reward = 1;
                         end

                        % Choose the action that gives the best reward
                        if reward > bestReward
                            bestReward = reward;
                            bestTimeStep = timeStep;
                            bestPacketSize = PACKET_SIZE;
                            bestResolution = resolution;
                            bestReTrans = nMaxRetx;
                            bestPOR = pOR;
                            bestPDFVals = [flValues zeros(1, numel(N_RETRANS) + 1 - numel(flValues))];
                            bestPDFProbs = [flProbabilities zeros(1, numel(N_RETRANS) + 1 - numel(flProbabilities))];
                            bestMCS = MCS;
                            %bestAction = currentAction;
                     end
                    end
                end
            end
        %t
        %bestResolution
        %bestReTrans
        if bestTimeStep == 0
            bestTimeStep = 0.5;
            bestResolution = [426; 240];
            wFr = bestResolution(1);
            hFr = bestResolution(2);
            bestReTrans = 0;
            [bestPDFVals, bestPDFProbs] = pmfFrameLatencyPacketReTx(bestReTrans, BER,  NUM_PACKETS, PACKET_OVERHEAD, ENCODED_FRAME_BITS, TX_RATE, T_N, T_P);
            bestPDFVals = [bestPDFVals zeros(1, numel(N_RETRANS) + 1 - numel(bestPDFVals))];
            bestPDFProbs = [bestPDFProbs zeros(1, numel(N_RETRANS) + 1 - numel(bestPDFProbs))];
            bestPOR= pObstacleRecognizableExp(hFr, dO, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR); 
        end
        bestReward
        ts = [ts, t];
        bestPORs = [bestPORs, bestPOR];
        bestResolutions = [bestResolutions; bestResolution'];
        bestNumRetxs = [bestNumRetxs, bestReTrans];
        bestPacketSizes = [bestPacketSizes, bestPacketSize];

        %bestPDFVals
        flPDFVals = [flPDFVals; bestPDFVals];
        flPDFProbs = [flPDFProbs; bestPDFProbs];

        %t + bestTimeStep
        t = t + bestTimeStep;
        %dO
        %
    end
    if SCENARIO == 2
           OBSTACLE_BREAK = 8;
           [pACts1, pACs1] = calculatePac(ts, 0, OBSTACLE_BREAK, T_CI,  bestPORs, flPDFVals, flPDFProbs);
           [pACts2, pACs2] = calculatePac(ts, OBSTACLE_BREAK, T_END, T_CI, bestPORs, flPDFVals, flPDFProbs);
           timeInstants = [pACts1, pACts2];
           pACs = [pACs1, pACs2];
    else
        [pACts, pACs] = calculatePac(ts, 0, T_END, T_CI, bestPORs, flPDFVals, flPDFProbs);
        [timeInstants, pACs] = calculatePac(ts, 0, T_END, T_CI, bestPORs, flPDFVals, flPDFProbs);
    end
end

