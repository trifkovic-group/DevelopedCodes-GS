%Name of data set before index and file type
S1='s';
a3='.tif';

a1 = 'Project001.lif_4D_t';
a2 = '_z';

Nimages = 26; %Total number of images in a data set
Ntslices = 300; %Total number of time slices
pixels = size(imread([a1,'000',a2,'00',a3])); % Read dimensions of images
% pixels = size(imread([S1,'00',S3])); % Read dimensions of images
array = zeros(pixels(1), pixels(2), Nimages); 

%a variables are the names of the data, updated each loop to load all files
for tslice = 0:(Ntslices-1)
    tslice
    S4 = int2str(tslice);
    for slice = 0 : (Nimages-1)
        
        S2=int2str(slice);
        
        if slice<10
%             S=[S1,'0',S2,S3];
            if tslice < 10
                a = [a1,'00',int2str(tslice),a2,'0',int2str(slice),a3];
            elseif tslice<100
                a = [a1,'0',int2str(tslice),a2,'0',int2str(slice),a3];
            elseif tslice<1000
                a = [a1,int2str(tslice),a2,'0',int2str(slice),a3];

            end
        elseif slice<100
%             S=[S1,S2,S3];
            if tslice < 10
                a = [a1,'00',int2str(tslice),a2,int2str(slice),a3];
            elseif tslice<100
                a = [a1,'0',int2str(tslice),a2,int2str(slice),a3];
            elseif tslice<1000
                a = [a1,int2str(tslice),a2,int2str(slice),a3];
            end
            
            
        end
        
        %S4 is the folder name corresponding to the current time slice
%         fullFileName = fullfile(S4, S);     
        fullFileName = fullfile(a);     
% 
%         thisSlice = imread(fullFileName);
%         array(:,:,slice+1,tslice+1) = rgb2gray(thisSlice);
        thisSlice = imread(a);
        thisSlice = thisSlice(:,:,1:3);
        array(:,:,slice+1,tslice+1) = rgb2gray(thisSlice);

%         imshow( rgb2gray(thisSlice));
        
    end

end

% break;

disp = zeros(Nimages,Ntslices-1);
dispy = zeros(Nimages,Ntslices-1);

for tslice = 0:(Ntslices-2)
    for slice = 0:(Nimages-1)
     slice %update on how many time steps are completed
        %read images
%        A = imread(['0/' num2str(t+1) '.tiff']);
%        T = imread(['1/' num2str(t) '.tiff']);
     A = array(:,:,slice+1,tslice+2);
     T = array(:,:,slice+1,tslice+1);
    
      %averaging filtr on images
     A = imfilter(A,ones(5)/25);
     T = imfilter(T,ones(5)/25);

     
     h = fspecial('prewitt');
     
     A = imfilter(A,h);
     T = imfilter(T,h);


      %crop template (current slice image)
      T = T(:,25:end);

      %perfrom cross correlation, finding how far the template has moved over
      %one time step, effectively finding the velocity in pixels of the
      %entire image
      cc = normxcorr2(T,A);
      [max_cc, imax] = max(abs(cc(:)));
      [ypeak, xpeak] = ind2sub(size(cc),imax(1));
      
      yoffset = (ypeak-size(A,1));
      xoffset = (xpeak-size(A,2));
      
      %displacement between current and next timeslice
      disp(slice+1,tslice+1) = xoffset;
      dispy(slice+1,tslice+1) = yoffset;
      
    end
end


corrVec = zeros(Nimages,Ntslices-1);
velshift = zeros(Nimages,Ntslices-1);

% for img = 1:Nimages
%     for ts = 1:(Ntslices-2)
%         
%         velshift(img,ts) = (disp(img,ts) + disp(img,ts+1))/2;
%         corrVec(img,ts+1) = velshift(img,ts) - disp(img,ts);
% 
%     end
% 
% end


for img = 1:Nimages
    ts = 1;
    while ts < Ntslices-1
        
        velshift(img,ts) = (disp(img,ts) + disp(img,ts+1))/2;
        corrVec(img,ts+1) = velshift(img,ts) - disp(img,ts);
        
        ts = ts+2;
    end

end

 
% break;


newImages = zeros(pixels(1),pixels(2),Ntslices,Nimages);
for ts = 1:(Ntslices-1)
    for img = 4:Nimages-3
        newImages(:,:,ts,img) = imtranslate(array(:,:,img,ts),[corrVec(img,ts),0]);
%     
%         name = ['S',int2str(img),'.tiff'];
%         pathway = ['TestOutput/',int2str(ts),'/',name];
%         file = fullfile(pathway);
%         image = uint8(newImages(:,:,ts,img)*2);
%         image = imsharpen(image);
%         imwrite(image,file);


%         newImages(:,:,ts,img) = array(:,:,img,ts);


        
    %writing 3d .tiff file
        name = ['TS',int2str(ts),'.tiff'];
        pathway = ['TestOutput/',name];
        file = fullfile(pathway);
        image = uint8(newImages(:,:,ts,img)*2);

        if img == 4
            imwrite(image,file);
        else
            imwrite(image,file,'WriteMode','append','Compression','none');
        end


    end
end

