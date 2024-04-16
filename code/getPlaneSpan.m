function points = getPlaneSpan(plane)
% Defines plane as a matrix having as columns 3 points contained in it (the
% span)

a = plane(1);
b = plane(2);
c = plane(3);
d = plane(4);

func = @(x,y)((-1/c)*(a*x + b*y + d));
point1 = [1 0 func(1,0) 1].';
point2 = [0 1 func(0,1) 1].';
point3 = [0 0 func(0,0) 1].';
points = [point1 point2 point3];