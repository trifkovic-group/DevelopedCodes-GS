clc
clear

%Empty matrix to speed up loop, size of (x,2) where x is number of time
%steps
corr_offset = zeros(1054:2);

%Loop through time steps
for t = 0%:400
    t %update on how many time steps are completed
    %read images
%     A = imread(['0/' num2str(t+1) '.tiff']);
%     T = imread(['1/' num2str(t) '.tiff']);
    A = imread(['0/s20.tiff']);
    T = imread(['1/s20.tiff']);
    
    %averaging filtr on images
    A = imfilter(A,ones(5)/25);
    T = imfilter(T,ones(5)/25);
    %crop template (current slice image)
    T = T(:,25:end);

    %perfrom cross correlation, finding how far the template has moved over
    %one time step, effectively finding the velocity in pixels of the
    %entire image
    cc = normxcorr2(T,A);
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset(t+1,:) = [ (ypeak-size(A,1)) (xpeak-size(A,2)) ];
end

Slice1 = corr_offset;

% %Name of data set before index and file type
% S1='S';
% S3='.tiff';
% 
% Nimages = 10; %Total number of images in a data set
% pixels = size(imread([S1,'00',S3])); % Read dimensions of images
% array = zeros(pixels(1), pixels(2), Nimages); 
% 
%S variables are the names of the data, updated each loop to load all files
% C = zeros(30,3,400);
% 
% for i = 0:400
% 
% I = imread(['Slice1/' num2str(i) '.tiff']);
% I = imfilter(I,ones(5)/25);
% 
% % figure(1)
% % imshow(I)
% 
% se = strel('disk', 5);
% Io = imopen(I, se);
% 
% % figure(2)
% % imshow(Io)
% 
% Ie = imerode(I, se);
% Iobr = imreconstruct(Ie, I);
% 
% % figure(3)
% % imshow(Ie)
% 
% Iobrd = imdilate(Iobr, se);
% Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% Iobrcbr = imcomplement(Iobrcbr);
% 
% % figure(4)
% % imshow(Iobrcbr)
% 
% fgm = imregionalmax(Iobrcbr);
% figure(1)
% imshow(fgm)
% 
% A = bwconncomp(fgm(:,:,:));
% B = regionprops(A,'centroid','area');
% C(1:length(B),1,i+1) = [B.Area];
% D = [B.Centroid];
% L(i+1) = length(D)/2;
% C(1:length(B),2,i+1) = D(1:length(D)/2);
% C(1:length(B),3,i+1) = D(length(D)/2+1:length(D));
% i
% end
% 
% for i = 1:1
%     for j = 1:L(i)
%         
%         X = C(j,:,i);
%         Y = C(1:L(i+1),:,i+1) - X(ones(L(i+1),1),:);
%         Y(:,3) = Y(:,3) + corr_offset(i,2);
% 
%         index = find(min(sum(Y(:,2:3)'.*Y(:,2:3)')) == sum(Y(:,2:3)'.*Y(:,2:3)'));
%     end
% end
