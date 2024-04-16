function cameraParams = calibrationFunction(images)
% Estimate camera intrinsic parameters by confronting some points on a
% checkboard and the relative points captured in the image

[imagePoints,boardSize] = detectCheckerboardPoints(images.Files);

squareSize = 13; 
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
I = readimage(images,2);
imageSize = [size(I,1),size(I,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                       'ImageSize',imageSize);

end
