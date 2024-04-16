function Conic = conePlaneIntersection(Cone,Plane)
    % Compute cone plane intersection thanks to the span representation of
    % the plane

    M = getPlaneSpan(Plane);

    Conic = M.' * Cone * M;
    
end