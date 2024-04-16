function [H, hel] = imsurf(func, range, along)
%IMSURF Surface for 3-D implicit function.
%   h = imsurf(func, range) plots the colored parametric
%   surface defined by implicit function "func(x,y,z)=0" within axis limite "range"
%   
%   [h, hel] = imsurf(func, range) where hel is used for ploting
%   intersection with other surface. See also "intercurve".
%
%   imsurf(func, range, along) with "along" determines the direction of
%   interp color. It must be in class "char". And it can be in the
%   following value: 'x', 'y', 'z', '|x|', '|y|', '|z|', 'r', or other math
%   expression in char.
%
%   Example:
%   ---------
%   h = imsurf(@(x,y,z)5*x.^2+6*x.*z+5*z.^2+8*y.^2-8, [-4,4,-4,4,-4,4], 'r');
%   axis equal;
%   camlight;
%
%   See also INTERCURVE.

%   Copyright 2017 TimeCoder.

    x = linspace(range(1), range(2), 150);
    y = linspace(range(3), range(4), 150);
    z = linspace(range(5), range(6), 150);
    [x, y, z] = meshgrid(x, y, z);

    v = func(x, y, z);
    
    if nargin==2
        along = 'z';
    end
    
    if strcmp(along, '|x|')
        isovalue = abs(x);
    elseif strcmp(along, '|y|')
        isovalue = abs(y);
    elseif strcmp(along, '|z|')
        isovalue = abs(z);
    elseif strcmp(along, 'r')
        isovalue = sqrt(x.^2+y.^2+z.^2);
    else
        isovalue = eval(along);
    end

    FVC = isosurface(x, y, z, v, 0, isovalue);
    h = patch(FVC, 'FaceColor','none', 'EdgeColor', 'none');
    
    view(3);
    
    hel.fvc = FVC;
    hel.func = func;
    if nargout~=0
        H = h;
    end
end