clear
clc


a1 = 'Z';
a3 = '.tif';

Nimages = 132;
pixels = [4400,4400];
array = zeros(pixels(1),pixels(2));
Thin = zeros(pixels(1),pixels(2));
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
    
    fullFileName = fullfile('D:/Geena/For Maziar/ConnectedDroplets/stitched/0.60/Images',a);     
    thisSlice = imread(fullFileName);

    thisSlice = bwmorph(thisSlice,'thin',Inf);
    thisSlice = imdilate(thisSlice,se);
    
    
    b = ['Thin','.tif'];
    file = fullfile('D:/Geena/For Maziar/ConnectedDroplets/stitched/0.60/Images',b);

    if slice ==0
            imwrite(thisSlice,file);
    else 
            imwrite(thisSlice,file,'WriteMode','append','Compression','none');
    end

end


