function [sigma] = calculateSigma(pACs, ts, dOInit, vD)
    [GOP, QP, PACKET_OVERHEAD, PACKET_SIZE, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR, T_HUMAN_RESPONSE, T_ENCODE, T_DECODE, T_PROPAGATION, T_RETRANS, FL_MAX, BRAKING_ACCEL, PAC_TIME_INTERVAL] = getParameters();
    tCI = calculateTCI(dOInit, vD);
    ideal = 0;
    resultant = 0;
    counter = 1;
    sigma = 0;
    for t = ts
        if t > tCI
            sigma = resultant/ideal;
            if ideal == 0
                sigma = 0;
            end
            return
        end
        ideal = ideal + 1;
        resultant = resultant + pACs(counter);
        counter = counter + 1;
    end
end