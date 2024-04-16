function plotSurfaceIntersection(Q, quadricName,plane, range, fileID)
% Plots the intersaction between the quadric and the plane, since the
% result is not particullarly readable it also add to a file called
% "Conic_and_Planes" the equations in order to simply represent them using
% some tool like "GeoGebra"
a = Q(1,1);
b = Q(2,2);
c = Q(3,3);
d = 2*Q(1,2);
e = 2*Q(1,3);
f = 2*Q(2,3);
g = 2*Q(1,4);
h = 2*Q(2,4);
l = 2*Q(3,4);
m = Q(4,4);
a_p = plane(1);
b_p = plane(2);
c_p = plane(3);
d_p = plane(4);

Qparams = 10^4*[a b c d e f g h l m];
Pparams = 10^4*[a_p b_p c_p d_p];


quadric = @(x,y,z)(a*x.^2 + b*y.^2 + c*z.^2 + d*x.*y + e*x.*z + f*y.*z + g*x + h*y + l*z + m);
plane = @(x,y,z)(a_p*x + b_p*y + c_p*z + d_p);


fprintf(fileID, quadricName + ": %4.4f*x^2 + %4.4f*y^2 + %4.4f*z^2 + %4.4f*x*y + %4.4f*x*z + %4.4f*y*z + %4.4f*x + %4.4f*y + %4.4f*z + %4.4f = 0 \n", Qparams);
fprintf(fileID, "plane: %4.4fx + %4.4fy + %4.4fz + %4.4f = 0 \n", Pparams);


hold on
axis equal
fimplicit3(quadric, range, 'EdgeColor','none',"FaceColor","cyan" , "FaceAlpha",0.4)
fimplicit3(plane, 'EdgeColor','none',"FaceColor","black", "FaceAlpha",0.1);

[~, hel_q] = imsurf(quadric, range);
[~, hel_p] = imsurf(plane, range);
intercurve(hel_q, hel_p)





