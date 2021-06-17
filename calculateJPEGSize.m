function [frameSize] = calculateJPEGSize(C_JPG, COLOR_DEPTH, w,h)
    frameSize = calculateRawFrameSize(COLOR_DEPTH, w, h)*C_JPG;
end

