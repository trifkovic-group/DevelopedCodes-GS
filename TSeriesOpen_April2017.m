clc
clear

%Name of data set before index and file type
S1='S';
S3='.tiff';

Nimages = 25; %Total number of images in a data set
pixels = size(imread([S1,'00',S3])); % Read dimensions of images
array = zeros(pixels(1), pixels(2), Nimages); 

%S variables are the names of the data, updated each loop to load all files
C = zeros(30,5,415);
for tslice = 1:300
    tslice
    S4 = int2str(tslice);
    for slice = 0 : Nimages
        
        S2=int2str(slice);
        if slice<10
            S=[S1,'0',S2,S3];
        elseif slice<100
            S=[S1,S2,S3];
            
        end
        
        
        %S4 is the folder name corresponding to the current time slice
        fullFileName = fullfile(S4, S);     
        thisSlice = imread(fullFileName);
        array(:,:,slice+1,tslice+1) = thisSlice;
    end
   %{ 
    %Get volume and center information on the droplets
    A = bwconncomp(array(:,:,:,tslice+1));
    B = regionprops('table',A,'centroid','area');
    C(1:height(B),1:4,tslice+1) = [B.Area,B.Centroid];
    %}
end

% for i = 1:11
%     X = C(:,:,2) - C(i,:,3);
%     Y = sqrt(X(:,3).^2 + X(:,4).^2)
%     find(Y == min(Y));
% end
    