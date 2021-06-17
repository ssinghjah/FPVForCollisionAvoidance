function [values, probabilites] = pmfdObstacleVisible(frameLatencyValues, dObstacle, v, fps, frameNum)
    values = dObstacle - v*(frameLatencyValues + (frameNum-1)/fps);
    values((values<0))=0;
end