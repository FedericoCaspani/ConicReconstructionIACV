function [P1, P2] = computeCameras(image1, image2, cameraParams, display, firstCamera)
    intrinsics = cameraParams.Intrinsics;
    
    if display == 1
        figure 
        imshowpair(image1, image2, 'montage');
        title('Original Images');
    end


    image1 = undistortImage(image1, intrinsics);
    image2 = undistortImage(image2, intrinsics);

    if display == 1
        figure 
        imshowpair(image1, image2, 'montage');
        title('Undistorted Images');
    end

    % Detect feature points
    imagePoints1 = detectMinEigenFeatures(im2gray(image1), MinQuality = 0.1);

    % Visualize detected points
    if display == 1
        figure
        imshow(image1, InitialMagnification = 50);
        title('150 Strongest Corners from the First Image');
        hold on
        plot(selectStrongest(imagePoints1, 150));
    end

    % Create the point tracker
    tracker = vision.PointTracker(MaxBidirectionalError=1, NumPyramidLevels=5);
    
    % Initialize the point tracker
    imagePoints1 = imagePoints1.Location;
    initialize(tracker, imagePoints1, image1);
    
    % Track the points
    [imagePoints2, validIdx] = step(tracker, image2);
    matchedPoints1 = imagePoints1(validIdx, :);
    matchedPoints2 = imagePoints2(validIdx, :);

    % Visualize correspondences
    if display == 1
        figure
        showMatchedFeatures(image1, image2, matchedPoints1, matchedPoints2);
        title('Tracked Features');
    end

    % Estimate the fundamental matrix
    [E, epipolarInliers] = estimateEssentialMatrix(...
        matchedPoints1, matchedPoints2, intrinsics, Confidence = 99.99);
    
    % Find epipolar inliers
    inlierPoints1 = matchedPoints1(epipolarInliers, :);
    inlierPoints2 = matchedPoints2(epipolarInliers, :);

    % Display inlier matches
    if display == 1
        figure
        showMatchedFeatures(image1, image2, inlierPoints1, inlierPoints2);
        title('Epipolar Inliers');
    end


    relPose = estrelpose(E, intrinsics, inlierPoints1, inlierPoints2);

    if ~exist("firstCamera", "var")
        tform = rigidtform3d;
    else
        tform = rigidtform3d(intrinsics.K \ firstCamera);
    end

    P1 = cameraProjection(intrinsics, tform);

    tform2 = rigidtform3d(tform.A * pose2extr(relPose).A);
    P2 = cameraProjection(intrinsics, tform2);




