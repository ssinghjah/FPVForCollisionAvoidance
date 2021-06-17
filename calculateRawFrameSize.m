function [rawFrameSize] = calculateRawFrameSize(COLOR_DEPTH, w, h)
    COLOR_DEPTH = 24; % bits
    rawFrameSize = COLOR_DEPTH*w*h;
end

