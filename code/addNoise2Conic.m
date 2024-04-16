function C = addNoise2Conic(C, n_points, noise_power)
    % Samples points from conic C and adds a Gaussian noise


    %get conic center
    A = C(1:2,1:2);
    B = C(1:2,3);
    Center = A\(-B);
    
    angles =2*pi * rand([1 n_points]);
    
    x_data = zeros([n_points 1]);
    y_data = zeros([n_points 1]);

    for i=1:n_points
        d = [cos(angles(i)) sin(angles(i))].';
        a = d.' * A * d;
        b = Center.' * A * d + d.' * B;
        c = Center.' * A * Center + 2 * Center.' * B + C(3,3);

        delta = b^2 - a * c;
        t1 = (-b + sqrt(delta))/a;
        %t2 = (-b - sqrt(delta))/a;
        
        point = Center + t1 * d + noise_power * randn([2 1]);
        x_data(i) = point(1);
        y_data(i) = point(2);
    end
    %scatter(x_data, y_data)
    C = leastSquaresConic(x_data, y_data);
