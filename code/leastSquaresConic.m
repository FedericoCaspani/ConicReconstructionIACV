function C = leastSquaresConic(x,y)
    % applies least squares on conic
    % model used is f(x,y) = a*x^2 + b*xy + c*y^2 + d*x + e*y
    % target for every data is t = -1 (in the conic the last parameter is
    % set to 1)
    X = [x.^2 x.*y y.^2 x y];

    Y = -1 * ones(length(x), 1);

    cc = pinv(X)*Y;


    [a, b, c, d, e, f] = deal(cc(1), cc(2), cc(3), cc(4), cc(5), 1);
    C = [a b/2 d/2; b/2 c e/2; d/2 e/2 f];
end