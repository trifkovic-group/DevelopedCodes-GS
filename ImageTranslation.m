I = imread('0.tiff');
% imshow(I);

V = imtranslate(I,[0,500],'FillValues',255);
imshow(V);

imwrite(V,'imagewritetest.tiff')