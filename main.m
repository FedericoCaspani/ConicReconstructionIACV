clear;
clc;

var = 0;
calculateCameraParams = 0;
display = 0;

if var == 1
    image1 = imread('Photo/set5/image1.jpg');
    image2 = imread('Photo/set5/image2.jpg');
    
    
    if calculateCameraParams == 1
        calibrationImages = imageDatastore('Photo/calibrazione');

        cameraParams = calibrationFunction(calibrationImages);
        save saved_variables.mat cameraParams -mat
    else
        load saved_variables.mat;
    end

    [P1, P2] = findExtrinsicParams(cameraParams, display);

    %intrinsic = findIntrinsic(calibrationImages);
    %%
    imshow(image1);
    hold on;
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    C1 = leastSquaresConic(x, y);

    hold off;

    imshow(image2);
    hold on;
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    
    C2 = leastSquaresConic(x, y);
    
    hold off;

    %draw Conics
    drawConic(C1, image1);
    drawConic(C2, image2);
      
else
    P1 = [1.393757 -0.244708 -14.170794 368.0;
        10.624195 2.396275 -0.433595 202.0;
        0.002859 0.011811 -0.003481 1.0];

    P2 = [1.374060 -0.612998 -14.189693 371.0;
        10.979978 -1.621189 -0.469463 207.0;
        0.007648 0.010572 -0.003449 1.0];

    Q1 = [-0.0013 0.4710^-5 -0.00023 0.0058;
        0.4710^-5 -0.000078 -0.00034 0.0033;
        -0.00023 -0.00034 -0.0014 0.011;
        0.0058 0.0033 0.011 -0.038];

    Plane1_paper = [-0.021 -0.16 -0.092 1.0].';

    Q2 = [1.0 0.0 0.0 -9.0;
        0.0 1.0 0.0 -2.0;
        0.0 0.0 1.0 -10.0;
        -9.0 -2.0 -10.0 85.0];


    Plane2_paper = [-0.196589 -0.812143 0.239359 1.0].';

    % using conic deriving from Q1 and Plane1, first conic in space
    
    M1 = getPlaneSpan(Plane1_paper);
    C_space1 = M1.' * Q1 * M1;

    %try to project to Image
    % assuming world reference frame aligned with the plane containing the
    % conic -> points on plane are [x y 0 w].'
    % I need 3 point correspondences from plane to image


    P1_plane_1 = [P1*M1(:,1) P1*M1(:,2) P1*M1(:,3)];
    P2_plane_1 = [P2*M1(:,1) P2*M1(:,2) P2*M1(:,3)];

    C1_1 = inv(P1_plane_1).' * C_space1 * inv(P1_plane_1);
    C2_1 = inv(P2_plane_1).' * C_space1 * inv(P2_plane_1);

    %using conic deriving from Q2 and Plane2

    M2 = getPlaneSpan(Plane2_paper);
    C_space2 = M2.' * Q2 * M2;

    P1_plane_2 = [P1*M2(:,1) P1*M2(:,2) P1*M2(:,3)];
    P2_plane_2 = [P2*M2(:,1) P2*M2(:,2) P2*M2(:,3)];

    C1_2 = inv(P1_plane_2).' * C_space2 * inv(P1_plane_2);
    C2_2 = inv(P2_plane_2).' * C_space2 * inv(P2_plane_2);
    
%     Point1 = [748/21 1 1 1].';
%     Point2 = [769/21 1 71/92 1].';
%     Point3 = [748/21 2 -17/23 1].';
% 
%     M1 = [Point1 Point2 Point3];
%     
%     C1 = M1.' * Q1 * M1;
% 
%     x = sym('x',[1 4]).';
%     assume(x ~= 0);
% 
%     eqns = Plane2.' * x == 0;
% 
%     point = solve(eqns, x);
%     point = [point.x1 point.x2 point.x3 point.x4];
% 
%     Point1 = point.';
%     Point2 = [point(1)+1 point(1,2) point(1,3)+(-Plane2(1,1))/Plane2(3,1) 1].';
%     Point3 = [point(1) point(1,2)+1 point(1,3)+(-Plane2(2,1))/Plane2(3,1) 1].';
%     
% 
%     M2 = double([Point1 Point2 Point3]);
%     
%     C2 = M2.' * Q2 * M2;
% 
%     for i=1:3
%         for j=1:3
%             C1(i,j) = C1(i,j)/C1(3,3);
%             C2(i,j) = C2(i,j)/C2(3,3);
%         end
%     end
% 
%     %drawconic( C1, [ -100 100 -100 100 ], [ 0.1 0.1 ], 'b-' ), grid;
%     %drawconic( C2, [ -100 100 -100 100 ], [ 0.1 0.1 ], 'b-' ), grid; 

end
%% use C1_1 and C2_1 or C1_2 and C2_2

A = P1.' * C1_2 * P1;
B = P2.' * C2_2 * P2;

lambda = computeLambda(A, B);
delta = computeDelta(A, B);

C = A + lambda*B;

%save saved_variables C1 C2 C P1 P2 A B lambda -mat
%%

e = eig(C);

%equation = mu^2 + a_lam_coeffs(4)*mu + a_lam_coeffs(3) == 0;

%sols = solve(equation, mu);
I = eye(4);

% Singular values of A less than 0.001 are treated as zero (tolerance)
v1 = null(C - e(1)*I, 0.001);
v2 = null(C - e(2)*I, 0.001);

%{
eqns1 = [bho1(1,:)*v1 == 0, bho1(2,:)*v1 == 0, bho1(3,:)*v1 == 0, bho1(4,:)*v1 == 0];
v1 = solve(eqns1, v1);

eqns2 = [bho1(1,:)*v1 == 0, bho1(2,:)*v1 == 0, bho1(3,:)*v1 == 0, bho1(4,:)*v1 == 0];
v2 = solve(eqns2, v2);
%}
if e(1) < 0
    Plane1 = sqrt(-e(1)) * v1 + sqrt(e(2)) * v2;
    Plane2 = sqrt(-e(1)) * v1 - sqrt(e(2)) * v2;
else
    Plane1 = sqrt(e(1)) * v1 + sqrt(-e(2)) * v2;
    Plane2 = sqrt(e(1)) * v1 - sqrt(-e(2)) * v2;
end
%%
o1 = null(P1);
o2 = null(P2);

o1 = o1 / o1(4);
o2 = o2 / o2(4);

dist_o1_plane1 = o1.' * Plane1;
dist_o2_plane1 = o2.' * Plane1;

dist_o1_plane2 = o1.' * Plane2;
dist_o2_plane2 = o2.' * Plane2;

if dist_o1_plane1*dist_o2_plane1 > 0
    Conic = conePlaneIntersection(A, Plane1);
    figure
    plotSurfaceIntersection(A, Plane1)
    
else 
    if dist_o1_plane2 * dist_o2_plane2 > 0
        Conic = conePlaneIntersection(A, Plane2);
        figure
        plotSurfaceIntersection(A, Plane2);
    else
        %give an error message
    end
end
%%
%display result
figure
plotSurfaceIntersection(A,Plane2)
hold on
plotSurfaceIntersection(B,Plane2)
hold on






