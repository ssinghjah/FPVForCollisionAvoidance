function [pACts, pACs] = runScenario(dOInit, vD)
    % Scenario Parameters
    [C_JPG, COLOR_DEPTH, PACKET_OVERHEAD, PACKET_SIZE, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR, T_HUMAN_RESPONSE, T_ENCODE, T_DECODE, T_PROPAGATION, T_O, FL_MAX, aBD, PAC_TIME_INTERVAL, RESOLUTIONS, N_RETRANS, MCSs, B, TN_MEAN, TN_SD] = getParameters();
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
    while t < T_END
        bestReward = -1;
        bestResolution = [-1 ; -1];
        bestReTranses = -1;
        bestPacketSizes = [];
        bestPOR = -1;
        bestMCS = -1;
        bestTimeStep = 0;
        bestPDFVals = zeros(1, max(N_RETRANS)+2);
        bestPDFProbs = zeros(1, max(N_RETRANS)+2);
        [aD, dO, dRHoriz, h, T_N, T_P] = getState(t, dOInit, vD, TN_MEAN, TN_SD);
        for resolution = RESOLUTIONS
            for nMaxRetx = N_RETRANS
               for MCS = MCSs
                        [M,C] = getMCSFromIndex(MCS);
                        TX_RATE = calculateTxRate(M,C,B);
                        SNR = calculateSNR(dRHoriz, h);
                        BER = calculateErrorRateMQAM(M, C, SNR, B, TX_RATE);
                        wFr = resolution(1);
                        hFr = resolution(2);
                        
                        %%%%%%%%%%%%%%%%%%
                        % Reward Calculation
                        % calculate POR
                        pOR = pObstacleRecognizable(hFr, dO, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR); 
                        % calculate TC,n as roots of a quadratic equation
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
                        encodedFrameBits = calculateJPEGSize(C_JPG, COLOR_DEPTH, wFr, hFr);
                        NUM_PACKETS = ceil(encodedFrameBits/PACKET_SIZE);
                        txTime = (encodedFrameBits + NUM_PACKETS * PACKET_OVERHEAD) / (TX_RATE);
                        [flValues, flProbabilities] = pmfFrameLatencyPacketReTx(nMaxRetx, BER,  NUM_PACKETS, PACKET_OVERHEAD, ENCODED_FRAME_BITS, TX_RATE, T_N, T_P, T_O, T_ENCODE, T_DECODE, FL_MAX);
                        cdfValue = cdfCalculator(flValues, flProbabilities, Tc);
                        timeStep = expectedInterFrameInterval(nMaxRetx, BER, T_P, NUM_PACKETS, PACKET_OVERHEAD, ENCODED_FRAME_BITS, TX_RATE, flValues, flProbabilities, T_ENCODE, T_DECODE);

                        % calculate reward
                        reward = cdfValue * pOR;

                        % Choose the action that gives the best reward
                        if reward > bestReward
                            bestReward = reward;
                            bestTimeStep = timeStep;
                            bestPacketSize = PACKET_SIZE;
                            bestResolution = resolution;
                            bestReTrans = nMaxRetx;
			    bestMCS = MCS;	
                            bestPOR = pOR;
                            bestPDFVals = [flValues zeros(1, numel(N_RETRANS) + 1 - numel(flValues))];
                            bestPDFProbs = [flProbabilities zeros(1, numel(N_RETRANS) + 1 - numel(flProbabilities))];

                     end
                    end
                end
            end
        ts = [ts, t];
        bestPORs = [bestPORs, bestPOR];
        bestResolutions = [bestResolutions; bestResolution'];
        bestNumRetxs = [bestNumRetxs, bestReTrans];
        bestPacketSizes = [bestPacketSizes, bestPacketSize];
        bestMCSs = [bestMCSs, bestMCS];
        flPDFVals = [flPDFVals; bestPDFVals];
        flPDFProbs = [flPDFProbs; bestPDFProbs];
        t = t + bestTimeStep;
    end
        [pACts, pACs] = calculatePac(ts, 0, T_END, T_CI, bestPORs, flPDFVals, flPDFProbs);
end
