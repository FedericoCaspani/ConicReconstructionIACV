function plotPlaneSurface(plane, range,n)
a = plane(1);
b = plane(2);
c = plane(3);
d = plane(4);

xx = linspace(range(1), range(2), n);
yy = linspace(range(3), range(4), n);
zz = linspace(range(5), range(6), n);

[x,y,z] = meshgrid(xx,yy,zz);
F = a*x+b*y+c*z+d;
isosurface(x,y,z,F,0)
alpha(0.5)
