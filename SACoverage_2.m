clc
clear

%Name of droplet data set
S1='Droplets';
S3='.tif';

%Name of particle data set
N1='Particles';
N3='.tif';

Nimages = 90; %Total number of images in a data set
% pixels = size(imread([S1,'000',S3])); % Read dimensions of images
pixels = [1050,1050];
array_p = zeros(pixels(1), pixels(2), Nimages); 
array_d = zeros(pixels(1), pixels(2), Nimages);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = 0 : Nimages-1

    S2=int2str(slice);
    if slice<10
        S=[S1,'00',S2,S3];
     elseif slice<100
        S=[S1,'0',S2,S3];
    else
        S=[S1,S2,S3];
    end
    
        N2=int2str(slice);
    if slice<10
        N=[N1,'00',N2,N3];
     elseif slice<100
        N=[N1,'0',N2,N3];
    else
        N=[N1,N2,N3];
    end
    
%_d is droplet, _p is particle, text value is the name of the folder in
%which the data is stored
fullFileName_d = fullfile('0.50','Images', S);
fullFileName_p = fullfile('0.50','Images', N);

thisSlice_d = imread(fullFileName_d);
thisSlice_p = imread(fullFileName_p);
array_p(:,:,slice+1) = thisSlice_p;
array_d(:,:,slice+1) = thisSlice_d;

end

SurfVox = 0; %Number of voxels at droplet surface
CovVox = 0; %Number of covered voxels at droplet surface

%Checks if surface of the droplet is next to a particle
for n = 2:Nimages-1
    for j =2:pixels(2)-1
        for i = 2:pixels(1)-1
            
            if array_d(i-1,j,n) + array_d(i,j,n) + array_d(i+1,j,n) == 2
                SurfVox = SurfVox + 1;
                if array_p(i-1,j,n) == 1% || array_p(i-2,j,n) == 1 %|| array_p(i-3,j,n) == 1 || array_p(i-4,j,n) == 1
                    CovVox = CovVox + 1;
                elseif array_p(i+1,j,n) == 1% || array_p(i+2,j,n) == 1 %|| array_p(i+3,j,n) == 1 || array_p(i+4,j,n) == 1
                    CovVox = CovVox + 1;
                end
            end
            
           if array_d(i,j-1,n) + array_d(i,j,n) + array_d(i,j+1,n) == 2
                SurfVox = SurfVox + 1;
                if array_p(i,j-1,n) == 1
                    CovVox = CovVox + 1;
                elseif array_p(i,j+1,n) == 1
                    CovVox = CovVox + 1;
                end
           end
            
            if array_d(i,j,n-1) + array_d(i,j,n) + array_d(i,j,n+1) == 2
                SurfVox = SurfVox + 1;
                if array_p(i,j,n-1) == 1
                    CovVox = CovVox + 1;
                elseif array_p(i,j,n+1) == 1
                    CovVox = CovVox + 1;
                end
            end
            
        end
    end
end
%Compares covered and uncovered surface --- % of surface covered
CovVox/SurfVox