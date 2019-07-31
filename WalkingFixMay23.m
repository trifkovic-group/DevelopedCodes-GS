%FIX (:,:,TSLICE,SLICE) VS (:,:,SLICE,TSLICE)


%Note: Images used are exported from LAS X and unedited

%Name of data set before index and file type
a1 = 'Project001.lif_4D_t';%update for project number
a2 = '_z';
a3='.tif';


Nimages = 26; %Total number of images in a data set
Ntslices = 20; %Total number of time slices
pixels = size(imread([a1,'000',a2,'00',a3])); % Read dimensions of images
array = zeros(pixels(1), pixels(2), Nimages); 

%a variables are the names of the data, updated each loop to load all files
for tslice = 0:(Ntslices-1)
    tslice
    S4 = int2str(tslice);
    for slice = 0 : (Nimages-1)
        
        S2=int2str(slice);
        
        if slice<10
            if tslice < 10
                a = [a1,'00',int2str(tslice),a2,'0',int2str(slice),a3];
            elseif tslice<100
                a = [a1,'0',int2str(tslice),a2,'0',int2str(slice),a3];
            elseif tslice<1000
                a = [a1,int2str(tslice),a2,'0',int2str(slice),a3];
            end
        elseif slice<100
            if tslice < 10
                a = [a1,'00',int2str(tslice),a2,int2str(slice),a3];
            elseif tslice<100
                a = [a1,'0',int2str(tslice),a2,int2str(slice),a3];
            elseif tslice<1000
                a = [a1,int2str(tslice),a2,int2str(slice),a3];
            end
            
        end
        
        %a contains the full file name for each image
        fullFileName = fullfile(a);     
        thisSlice = imread(a);
        thisSlice = thisSlice(:,:,1:3);%change .tif file to rgb
        array(:,:,slice+1,tslice+1) = rgb2gray(thisSlice); %change rgb to grayscale
        
%         imshow(uint8(array(:,:,slice+1,tslice+1)*2))
    end

end


dispx = zeros(Nimages,Ntslices-1);
dispy = zeros(Nimages,Ntslices-1);


for tslice = 1:(Ntslices-1)
    for slice = 1:(Nimages)
        slice %update on how many time steps are completed

        %read images
        A = array(:,:,slice,tslice+1);
        T = array(:,:,slice,tslice);

        %averaging filtr on images
        A = imfilter(A,ones(5)/25);
        T = imfilter(T,ones(5)/25);

        h = fspecial('prewitt');

        A = imfilter(A,h);
        T = imfilter(T,h);
% 
        %crop template (current slice image)
        T = T(:,25:end);

        %perfrom cross correlation, finding how far the template has moved over
        %one time step, effectively finding the velocity in pixels of the
        %entire image
        cc = normxcorr2(T,A);
        [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));

        xoffset = (xpeak-size(A,2));
        yoffset = (ypeak-size(A,1));

        %displacement between current and next timeslice in x direction
        dispx(slice,tslice) = xoffset;
        dispy(slice,tslice) = yoffset;

      
    end
end

corrVec = zeros(Nimages,Ntslices-1);
velshift = zeros(Nimages,Ntslices-1);


for slice = 1:Nimages
    tslice = 1;
    
    while tslice < Ntslices-1
        
        %find the average velocity between 2 time steps of an image and 
        %determine the translation needed to correct every second time step
        velshift(slice,tslice) = (dispx(slice,tslice) + dispx(slice,tslice+1))/2;
        corrVec(slice,tslice+1) = velshift(slice,tslice) - dispx(slice,tslice);
        
        tslice = tslice + 2;
    end

end


newImages = zeros(pixels(1),pixels(2),Ntslices,Nimages);
bwImages = zeros(pixels(1),pixels(2),Nimages,Ntslices);


for tslice = 1:(Ntslices-1)
    for slice = 1:(Nimages-1)
        %translate each image individually in the x direction
        newImages(:,:,tslice,slice) = imtranslate(array(:,:,slice,tslice),[corrVec(slice,tslice),0]);
        newImages(:,:,tslice,slice) = uint8(newImages(:,:,tslice,slice)*3);
        
        %Deconvolution filter
        PSF = fspecial('gaussian', pixels(1),10);
        INITPSF = ones(size(PSF));
        [J,PSF] = deconvblind(newImages(:,:,tslice,slice),INITPSF);
        newImages(:,:,tslice,slice) = J;

        %median filter
        newImages(:,:,tslice,slice) = medfilt2(newImages(:,:,tslice,slice));
        %fill holes
        newImages(:,:,tslice,slice) = imfill(newImages(:,:,tslice,slice));
 
        %save as binary image
        bwImages(:,:,slice,tslice) = im2bw(uint8(newImages(:,:,tslice,slice)));
        
        %Remove objects with less than 5 pixels
        bwImages(:,:,slice,tslice) = bwareaopen(bwImages(:,:,slice,tslice),4);
                
%         imshow(bwImages(:,:,slice,tslice))
%         imshow(uint8(newImages(:,:,tslice,slice)*2));
    end
end






%watershed testing
for tslice = 1:(Ntslices-1)
        thisimage = bwImages(:,:,:,tslice);
        D = -bwdist(~thisimage);
        L = watershed(D,6);
        thisimage(L == 0) = 0;
        
%         imshow(thisimage);

        bwImagescopy(:,:,:,tslice) = thisimage;
%         imshow(bwImagescopy(:,:,10,tslice));
end


for tslice = 1:(Ntslices-1)
    for slice = 1:(Nimages-1)
        name = ['TSWS',int2str(tslice),'.tiff'];
        pathway = ['TestOutput/',name];%modify to put in different folder
        file = fullfile(pathway);
        image = bwImagescopy(:,:,slice,tslice); %change to 8 bit unsigned integers

        %create 3d .tiff file of new images for each time step
        if slice == 1
            imwrite(image,file);
        else
            imwrite(image,file,'WriteMode','append','Compression','none');
        end

    end
end







break;

maxobj = 0;
data = zeros(Ntslices,20,7); %# tslices, # objects, x,y,z,vol


for tslice = 1:(Ntslices-1)
        A = bwconncomp(bwImages(:,:,:,tslice),6)
        B = regionprops(A,'centroid','area','BoundingBox');
        
        if A.NumObjects > maxobj && A.NumObjects ~= 0
            maxobj = A.NumObjects;
        end
      
      %store the centroid and volume of each object for each time slice
      for j = 1:A.NumObjects
          data(tslice,j,1) = B(j).Centroid(1); %x bar
          data(tslice,j,2) = B(j).Centroid(2); %y bar
          data(tslice,j,3) = B(j).Centroid(3); %z bar
          data(tslice,j,4) = B(j).Area; %Volume
          data(tslice,j,5) = B(j).BoundingBox(1); %Volume
          data(tslice,j,6) = B(j).BoundingBox(2); %Volume
          data(tslice,j,7) = B(j).BoundingBox(3); %Volume

      end

end

break;


for tslice = 1:(Ntslices-1)
    for slice = 1:(Nimages-1)
        name = ['TSbw',int2str(tslice),'.tiff'];
        pathway = ['TestOutput/',name];%modify to put in different folder
        file = fullfile(pathway);
        image = bwImages(:,:,slice,tslice); %change to 8 bit unsigned integers

        %create 3d .tiff file of new images for each time step
        if slice == 1
            imwrite(image,file);
        else
            imwrite(image,file,'WriteMode','append','Compression','none');
        end

    end
end





break;


for tslice = 1:(Ntslices-1)
    for slice = 1:(Nimages-1)
        %translate each image individually in the x direction
        newImages(:,:,tslice,slice) = imtranslate(array(:,:,slice,tslice),[corrVec(slice,tslice),0]);
        
        name = ['TS',int2str(tslice),'.tiff'];
        pathway = ['TestOutput/',name];%modify to put in different folder
        file = fullfile(pathway);
        image = uint8(newImages(:,:,tslice,slice)*2); %change to 8 bit unsigned integers

        %create 3d .tiff file of new images for each time step
        if slice == 1
            imwrite(image,file);
        else
            imwrite(image,file,'WriteMode','append','Compression','none');
        end

    end
end

