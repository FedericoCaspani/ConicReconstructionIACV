function drawConic(C, image)
    im_size = size(image);
    im = zeros(im_size(1), im_size(2));
    for i=1:im_size(1)
        for j=1:im_size(2)
            im(i,j)=[j i 1]*C*[j i 1]';
            if im(i,j) < 0
                image(i,j) = 1;
            end
        end
    end

    imshow(image);
end