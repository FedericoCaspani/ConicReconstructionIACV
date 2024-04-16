clear;
clc;

% Synthetic case

n_sample_points = 30; %number of sample points to which apply noise
noise = 2;
epsilon=1e-25; %threshold for correspondence

P1 = [1.393757 -0.244708 -14.170794 368.0;
    10.624195 2.396275 -0.433595 202.0;
    0.002859 0.011811 -0.003481 1.0];

P2 = [1.374060 -0.612998 -14.189693 371.0;
    10.979978 -1.621189 -0.469463 207.0;
    0.007648 0.010572 -0.003449 1.0];

Q1 = [-0.0013 0.5*10^(-5) -0.00023 0.0058;
    0.5*10^(-5) -0.000078 -0.00034 0.0033;
    -0.00023 -0.00034 -0.0014 0.011;
    0.0058 0.0033 0.011 -0.038];

Plane1_paper = [-0.021 -0.16 -0.092 1.0].';

Q2 = [1.0 0.0 0.0 -9.0;
    0.0 1.0 0.0 -2.0;
    0.0 0.0 1.0 -10.0;
    -9.0 -2.0 -10.0 85.0];


Plane2_paper = [-0.196589 -0.812143 0.239359 1.0].';

%using conic deriving from Q1 and Plane1

M1 = getPlaneSpan(Plane1_paper);
C_space1 = M1.' * Q1 * M1;

%try to project to Image
% assuming world reference frame aligned with the plane containing the
% conic -> points on plane are [x y 0 w].'
% I need 3 point correspondences from plane to image

P1_plane = [P1*M1(:,1) P1*M1(:,2) P1*M1(:,3)];
P2_plane = [P2*M1(:,1) P2*M1(:,2) P2*M1(:,3)];

C1_1 = inv(P1_plane).' * C_space1 * inv(P1_plane);
C2_1 = inv(P2_plane).' * C_space1 * inv(P2_plane);

%using conic deriving from Q2 and Plane2

M2 = getPlaneSpan(Plane2_paper);
C_space2 = M2.' * Q2 * M2;

%try to project to Image
% assuming world reference frame aligned with the plane containing the
% conic -> points on plane are [x y 0 w].'
% I need 3 point correspondences from plane to image

P1_plane = [P1*M2(:,1) P1*M2(:,2) P1*M2(:,3)];
P2_plane = [P2*M2(:,1) P2*M2(:,2) P2*M2(:,3)];

C1_2 = inv(P1_plane).' * C_space2 * inv(P1_plane);
C2_2 = inv(P2_plane).' * C_space2 * inv(P2_plane);


C1_1 = addNoise2Conic(C1_1, n_sample_points, noise);
C1_2 = addNoise2Conic(C1_2, n_sample_points, noise);
C2_1 = addNoise2Conic(C2_1, n_sample_points, noise);
C2_2 = addNoise2Conic(C2_2, n_sample_points, noise);

Conics= [C1_1 C1_2 C2_1 C2_2];

Cameras = [P1 P2];
n_conics = 2;
n_views = 2;


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

%visualize true conics
plotSurfaceIntersection(Q1, "Q1", Plane1_paper, range, fileID);
plotSurfaceIntersection(Q2, "Q2", Plane2_paper, range, fileID);

fclose(fileID);
