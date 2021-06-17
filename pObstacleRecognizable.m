function y = pObstacleRecognizable(frameResolution, dObstacle, MIN_OBSTACLE_DIM, FOCAL_LEN, H_SENSOR, MIN_DIM_PIX, MAX_DIM_PIX)
    hObj = MIN_OBSTACLE_DIM * frameResolution * FOCAL_LEN / (H_SENSOR * dObstacle);
    y = sFunction(hObj);
end

