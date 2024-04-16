function [Q,finalPlane] = reconstructConic(C1, P1, C2, P2, epsilon)
    A = P1.' * C1 * P1;
    B = P2.' * C2 * P2;

    lambda = computeLambda(A, B);
    delta = computeDelta(A, B);           

    disp(delta);
    finalPlane = [];
    Q = A;
    if abs(delta) < epsilon                

        C = A + lambda*B;
                    
        e = eigs(C);
        
        I = eye(4);
        
        

        if e(1)>0 && e(2)<0
            % Singular values of A less than 0.0001 are treated as zero (tolerance)
            v1 = null(C - e(1)*I, 0.0001);
            v2 = null(C - e(2)*I, 0.0001);
            
            Plane1 = sqrt(e(1)) * v1 + sqrt(-e(2)) * v2;
            Plane2 = sqrt(e(1)) * v1 - sqrt(-e(2)) * v2;
        else
            % Singular values of A less than 0.0001 are treated as zero (tolerance)
            v1 = null(C - e(2)*I, 0.0001);
            v2 = null(C - e(1)*I, 0.0001);
            
            Plane1 = sqrt(e(2)) * v1 + sqrt(-e(1)) * v2;
            Plane2 = sqrt(e(2)) * v1 - sqrt(-e(1)) * v2;
        end
        
        o1 = null(P1);
        o2 = null(P2);

        o1 = o1 / o1(4);
        o2 = o2 / o2(4);
                    
        dist_o1_plane1 = o1.' * Plane1;
        dist_o2_plane1 = o2.' * Plane1;
        
        dist_o1_plane2 = o1.' * Plane2;
        dist_o2_plane2 = o2.' * Plane2;
        
        if (dist_o1_plane1*dist_o2_plane1) > 0
            finalPlane = Plane1;
            %Conic = conePlaneIntersection(A, Plane1);
            %plotSurfaceIntersection(A, "A",  Plane1, range, fileID)

            
        elseif (dist_o1_plane2 * dist_o2_plane2) > 0
            finalPlane = Plane2;
            %Conic = conePlaneIntersection(A, Plane2);
            %plotSurfaceIntersection(A, "A",  Plane2, range, fileID)
            
        else
                disp("Error in reconstruction")
                finalPlane = [];
        end       
    end
end
        