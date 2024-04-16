function H = intercurve(hel1, hel2)
%INTERCURVE Plot the intersections of 2 surface.
%   h = INTERCURVE(hel1, hel2) plots the intersections of surface hel1 and
%   hel2, where hel1 and hel2 must come from "imsurf" function.
%   
%   Example:
%   ---------
%   [h1, hel1] = imsurf(@(x,y,z)5*x.^2+6*x.*z+5*z.^2+8*y.^2-8, [-4,4,-4,4,-4,4]);
%   hold on;axis equal;
%   [h2, hel2] = imsurf(@(x,y,z)5*x.^2-6*x.*z+5*z.^2+8*y.^2-10, [-4,4,-4,4,-4,4]);
%   h2.FaceAlpha = 0.6;
%   h = intercurve(hel1, hel2);
%   h.Color = 'r';
%   camlight;
%
%   See also IMSURF.

%   Copyright 2015 Mike on MATLAB Graphics.
%   (The algorithm comes from a blog on MATLAB Central:
%    http://blogs.mathworks.com/graphics/2015/07/22/implicit-surface-intersections/#
%    whose author is "Mike on MATLAB Graphics". And "TimeCoder" packaged it into a function in 2017)

    FVC1 = hel1.fvc;
    f2 = hel2.func;
    
    x1_surf = FVC1.vertices(:,1);
    y1_surf = FVC1.vertices(:,2);
    z1_surf = FVC1.vertices(:,3);
    v3 = f2(x1_surf, y1_surf, z1_surf);
    mask = v3>0;
    outcount = sum(mask(FVC1.faces),2);
    cross = (outcount == 2) | (outcount == 1);
    crossing_tris = FVC1.faces(cross,:);

    out_vert = mask(crossing_tris);
    flip = sum(out_vert,2) == 1;
    out_vert(flip,:) = 1-out_vert(flip,:);
    ntri = size(out_vert,1);
    overt = zeros(ntri,3);
    for i=1:ntri
        v1i = find(~out_vert(i,:));
        v2i = 1 + mod(v1i,3);
        v3i = 1 + mod(v1i+1,3);
        overt(i,:) = crossing_tris(i,[v1i v2i v3i]);
    end

    u = -v3(overt(:,1)) ./ (v3(overt(:,2)) - v3(overt(:,1)));
    v = -v3(overt(:,1)) ./ (v3(overt(:,3)) - v3(overt(:,1)));
    uverts = repmat((1-u),[1 3]).*FVC1.vertices(overt(:,1),:) + repmat(u,[1 3]).*FVC1.vertices(overt(:,2),:);
    vverts = repmat((1-v),[1 3]).*FVC1.vertices(overt(:,1),:) + repmat(v,[1 3]).*FVC1.vertices(overt(:,3),:);
    x1 = nan(3,ntri);
    x1(1,:) = uverts(:,1)';
    x1(2,:) = vverts(:,1)';
    y1 = nan(3,ntri);
    y1(1,:) = uverts(:,2)';
    y1(2,:) = vverts(:,2)';
    z1 = nan(3,ntri);
    z1(1,:) = uverts(:,3)';
    z1(2,:) = vverts(:,3)';
    h = plot3(x1(:), y1(:), z1(:));
    h.LineWidth = 1;
    if nargout~=0
        H = h;
    end
    view(3);
end