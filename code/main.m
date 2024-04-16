clc;
clear;
close all;

im1 = imread("Photo/set8/im1.png");
im2 = imread("Photo/set8/im2.png");
im3 = imread("Photo/set8/im3.png");

images = [im1, im2, im3]; %README!!! if adding or removing images be sure to apply changes also in the "undistort images" cell below


%control flow variables
calibrate_intrinsics = 1;
select_points = 0;
display = 0; %display intermediate steps

%general parameters
n_views = 3;
n_conics = 2;

%% COMPUTE INTRINSICS PARAMETERS
if calibrate_intrinsics == 1
    calibrationImages = imageDatastore('Photo/calibrazione_vero');
    cameraParams = calibrationFunction(calibrationImages);
    save cameraParameters.mat cameraParams -mat
else
    load cameraParameters.mat
end

%% COMPUTE EXTRINSICS PARAMETERS OF CAMERAS

Cameras = zeros([3 4*n_views]);
[height, width, ~] = size(im1);
for i=1:n_views-1

    img_start1 = (i-1)*width + 1;
    img_end1 = img_start1 + width - 1;

    img_start2 = i * width + 1;
    img_end2 = img_start2 + width - 1;

    %if using 3 or more views computeCameras need to know if this is the
    %first pair of cameras. (the first camera will be set at the origin of
    %the reference system)
    if i==1
        [P1, P2] = computeCameras(images(:,img_start1:img_end1), images(:,img_start2:img_end2), cameraParams, display);
        
    else
        [P1, P2] = computeCameras(images(:,img_start1:img_end1), images(:,img_start2:img_end2), cameraParams, display, P2);

    end

    start_idx = (i - 1) * 4 + 1;
    Cameras(:, start_idx:start_idx+7) = [P1 P2];
end
%% UNDISTORT IMAGES

hold off;

im1 = undistortImage(im1, cameraParams.Intrinsics);
im2 = undistortImage(im2, cameraParams.Intrinsics);
im3 = undistortImage(im3, cameraParams.Intrinsics);


images = [im1, im2, im3];
%% GET POINTS TO FIT CONICS
% Showing images and asking 5 or more points to extract the image of
% each conic

if select_points == 1

    Conics = zeros([3 n_views*n_conics*3]);
    
    for i=1:n_views
        img_start = (i-1)*width + 1;
        img_end = img_start + width - 1;
    
        figure;
        imshow(images(:,img_start:img_end));
        hold on;
    
        for j=1:n_conics
            
            [x, y] = getpts();
            C = leastSquaresConic(x,y);
    
            conic_idx = (i-1)*3*n_conics + 1 + (j-1)*3;
    
            Conics(:, conic_idx:conic_idx+2) = C;
        end
    
        hold off;
    
    end

    save conics.mat Conics -mat;

else
    load conics.mat
end

%%
epsilon=9e-1; %threshold for correspondence
fileID = fopen("Conic_and_Planes.txt", "w+"); %where to write equations for plots in geogebra

figure;
hold on;
range = 4*[-10 10 -10 10 0 10]; %range for MATLAB plots. (We prefer Geogebra because it does not need range)
for i=1:(n_views - 1)                                              
    for j=1:n_conics                                           
        for w=1:n_conics
            first_idx = (i - 1) * n_conics * 3 + 1 + (j - 1) * 3; %-1 and +1 for stupid MATLAB indexing starting with 1
            second_idx = (i) * n_conics * 3 + 1 + (w - 1) * 3;
            C1 = Conics(:,first_idx:first_idx+2);
            C2 = Conics(:, second_idx:second_idx+2);

            P1_idx = (i - 1)*4 + 1;
            P1 = Cameras(:, P1_idx:P1_idx+3);

            P2_idx = (i)*4 + 1;
            P2 = Cameras(:, P2_idx:P2_idx+3);

            [Q, plane] = reconstructConic(C1, P1, C2, P2, epsilon); %main reconstruction function

            if size(plane) == [4 1]
                plotSurfaceIntersection(Q, "Q", plane, range, fileID);
            end
            
        end
    end
end

fclose(fileID);






