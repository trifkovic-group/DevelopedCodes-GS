clear
clc

a1 = 'Z';
a3 = '.tif';

Nimages = 135;
pixels = [1024,1024];
array = zeros(pixels(1),pixels(2),Nimages);
Thin = zeros(pixels(1),pixels(2),Nimages);
se = strel('square',2);

for slice = 0:Nimages-1
    a2 = int2str(slice);
    
    if slice < 10
            a = [a1,'00',a2,a3];
    elseif slice < 100
            a = [a1,'0',a2,a3];
    else
            a = [a1,a2,a3];
    end
    
    fullFileName = fullfile('D:/Geena/For Maziar/ConnectedDroplets/stitched/0.50/Images',a);     
    thisSlice = imread(fullFileName);
    array(:,:,slice+1) = thisSlice;
    
    %thins particle channel to 2 pixel width
    Thin(:,:,slice+1) = bwmorph(array(:,:,slice+1),'thin',Inf);
    Thin(:,:,slice+1) = imdilate(Thin(:,:,slice+1),se);
end


%Save the thinned images as a 3D .tif
for slice = 1:Nimages
    b = ['Thin','.tif'];
    file = fullfile('D:/Geena/For Maziar/ConnectedDroplets/stitched/0.50/Images',b);

    if slice ==1
            imwrite(Thin(:,:,slice),file);
    else 
            imwrite(Thin(:,:,slice),file,'WriteMode','append','Compression','none');
    end
end