clc
clear

NSections = 9;
Nimages = 90; %Total number of images in a data set

SurfVox = 0; %Number of voxels at droplet surface
CovVox = 0; %Number of covered voxels at droplet surface

for Sec = 1:NSections

    %Name of droplet data set
    S1='Droplets';
    S3='.tif';

    %Name of particle data set
    N1='Particles';
    N3='.tif';

    % pixels = size(imread([S1,'000',S3])); % Read dimensions of images
    pixels = size(imread(fullfile('stitched','0.50',[int2str(Sec),'Droplets','00','.tif'])));
    array_p = zeros(pixels(1), pixels(2), Nimages); 
    array_d = zeros(pixels(1), pixels(2), Nimages);

    %Load the 2 image sets, sections needs adjusting based on number of images
    for slice = 0 : Nimages-1

        S2=int2str(slice);
        if slice<10
            S=[int2str(Sec),S1,'00',S2,S3];
         elseif slice<100
            S=[int2str(Sec),S1,'0',S2,S3];
        else
            S=[int2str(Sec),S1,S2,S3];
        end

            N2=int2str(slice);
        if slice<10
            N=[int2str(Sec),N1,'00',N2,N3];
         elseif slice<100
            N=[int2str(Sec),N1,'0',N2,N3];
        else
            N=[int2str(Sec),N1,N2,N3];
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



    %Checks if surface of the droplet is next to a particle
    for n = 2:Nimages-1
        for j =2:pixels(2)-1
            for i = 2:pixels(1)-1

                if array_d(i-1,j,n) + array_d(i,j,n) + array_d(i+1,j,n) == 2
                    SurfVox = SurfVox + 1;
                    if array_p(i-1,j,n) == 1
                        CovVox = CovVox + 1;
                    elseif array_p(i+1,j,n) == 1
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

clear array_p;
clear array_d;
end

%Compares covered and uncovered surface --- % of surface covered
CovVox/SurfVox