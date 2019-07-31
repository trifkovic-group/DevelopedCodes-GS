clc
clear

%Name of droplet data set
S1='Subtraction';
S3='.tif';

D1='Dilation';
D3='.tif';

%pathway to excel document for data
pathway = fullfile('stitched','0.50','excelfile');

INobjects
FNobjects = 62; %total number of separated objects from avizo label analysis
Nimages = 60; %Total number of images in a data set
pixels = size(imread(fullfile('stitched','0.50',['Subtraction','000','.tif'])));
array_S = zeros(pixels(1), pixels(2), Nimages); 
array_D = zeros(pixels(1), pixels(2), Nimages); 

%conversion between pixels and microns
%Update for each set of images
MicronsPerPixelX = 0.43152;
MicronsPerPixelY = 0.43152;
MicronsPerPixelZ = 1.1932; 

%Load the image set, sections needs adjusting based on number of images
%S is image after subtraction, D before subtraction
for slice = 0 : Nimages-1

    S2=int2str(slice);
    if slice<10
        S=[S1,'0',S2,S3];
    elseif slice<100
        S=[S1,S2,S3];
    else
        S=[S1,S2,S3];
    end
    
    D2=int2str(slice);
    if slice<10
        D=[S1,'0',S2,S3];
    elseif slice<100
        D=[S1,S2,S3];
    else
        D=[S1,S2,S3];
    end

    
%_S is subtraction, _D is dilation, text value is the name of the folder in
%which the data is stored
fullFileName_S = fullfile('stitched','0.50','Images', S);
thisSlice_S = imread(fullFileName_S);
array_S(:,:,slice+1) = thisSlice_S;

fullFileName_D = fullfile('stitched','0.50','Images', D);
thisSlice_D = imread(fullFileName_D);
array_D(:,:,slice+1) = thisSlice_D;

end



VolDroplets = zeros(FNobjects,1);

%determining volume of each droplet
for k = 1:Nimages
    for j =1:pixels(2)
        for i = 1:pixels(1)
            
            if array_S(i,j,k) > 0
               VolDroplets(array_S(i,j,k)) = VolDroplets(array_S(i,j,k)) + ...
                   (MicronsPerPixelX * MicronsPerPixelY * MicronsPerPixelZ);
            end
            
        end
    end
end
%convert from pixels^3 to microns^3
% VolDroplets = VolDroplets .* (MicronsPerPixelX * MicronsPerPixelY * MicronsPerPixelZ);

ChannelConnection = zeros(FNobjects,FNobjects);% matrix with 1 indicating a channel between droplets
AllConnections = zeros(FNobjects,FNobjects); %Matrix with 1 indicating droplets touching before subtracting particles
ChannelAreaConnected = zeros(FNobjects,FNobjects); %matrix holding the number of pixels in each connection

%Checks if surface of the droplet is next to a different droplet
for k = 1:Nimages-1
    for j =1:pixels(2)-1
        for i = 1:pixels(1)-1
            
            %checks if the current pixel is beside a pixel from another
            %droplet
            if array_S(i,j,k) > 0 && array_S(i+1,j,k) > 0 && array_S(i+1,j,k) ~= array_S(i,j,k)
                ChannelConnection(array_S(i,j,k),array_S(i+1,j,k)) = 1;
                ChannelConnection(array_S(i+1,j,k),array_S(i,j,k)) = 1;
                
                ChannelAreaConnected(array_S(i,j,k),array_S(i+1,j,k)) = ChannelAreaConnected(array_S(i,j,k),array_S(i+1,j,k)) + (MicronsPerPixelY * MicronsPerPixelZ);
                ChannelAreaConnected(array_S(i+1,j,k),array_S(i,j,k)) = ChannelAreaConnected(array_S(i+1,j,k),array_S(i,j,k)) + (MicronsPerPixelY * MicronsPerPixelZ);

            end
            
            if array_S(i,j,k) > 0 && array_S(i,j+1,k) > 0 && array_S(i,j+1,k) ~= array_S(i,j,k)
                ChannelConnection(array_S(i,j,k),array_S(i,j+1,k)) = 1;
                ChannelConnection(array_S(i,j+1,k),array_S(i,j,k)) = 1;
                
                ChannelAreaConnected(array_S(i,j,k),array_S(i,j+1,k)) = ChannelAreaConnected(array_S(i,j,k),array_S(i,j+1,k)) + (MicronsPerPixelX * MicronsPerPixelZ);
                ChannelAreaConnected(array_S(i,j+1,k),array_S(i,j,k)) = ChannelAreaConnected(array_S(i,j+1,k),array_S(i,j,k)) + (MicronsPerPixelX * MicronsPerPixelZ);

            end
            
            if array_S(i,j,k) > 0 && array_S(i,j,k+1) > 0 && array_S(i,j,k+1) ~= array_S(i,j,k)
                ChannelConnection(array_S(i,j,k),array_S(i,j,k+1)) = 1;
                ChannelConnection(array_S(i,j,k+1),array_S(i,j,k)) = 1;
                
                ChannelAreaConnected(array_S(i,j,k),array_S(i,j,k+1)) = ChannelAreaConnected(array_S(i,j,k),array_S(i,j,k+1)) + (MicronsPerPixelX * MicronsPerPixelY);
                ChannelAreaConnected(array_S(i,j,k+1),array_S(i,j,k)) = ChannelAreaConnected(array_S(i,j,k+1),array_S(i,j,k)) + (MicronsPerPixelX * MicronsPerPixelY);
            end
            
            %Check for an adjacent object before subtraction of particles
            if array_D(i,j,k) > 0 && array_D(i+1,j,k) > 0 && array_D(i+1,j,k) ~= array_D(i,j,k)
                AllConnections(array_D(i,j,k),array_D(i+1,j,k)) = 1;
                AllConnections(array_D(i+1,j,k),array_D(i,j,k)) = 1;
            end
                        
            if array_D(i,j,k) > 0 && array_D(i,j+1,k) > 0 && array_D(i,j+1,k) ~= array_D(i,j,k)
                AllConnections(array_D(i,j,k),array_D(i,j+1,k)) = 1;
                AllConnections(array_D(i,j+1,k),array_D(i,j,k)) = 1;
            end
            
            if array_D(i,j,k) > 0 && array_D(i,j,k+1) > 0 && array_D(i,j,k+1) ~= array_D(i,j,k)
                AllConnections(array_D(i,j,k),array_D(i,j,k+1)) = 1;
                AllConnections(array_D(i,j,k+1),array_D(i,j,k)) = 1;
            end
            
            
        end
    end
end


NChannelConnections = zeros(FNobjects,1); %Total number of connections associated with each droplet
% AreaConnection = ChannelPixelsConnected .* (MicronsPerPixelX * MicronsPerPixelY); %conversion of the area of each connection from pixels^2 to microns^2
% AreaConnection = ChannelAreaConnected;

for i = 1:FNobjects
   for j = 1:FNobjects
       
       if ChannelConnection(i,j) == 1 && ChannelAreaConnected(i,j) > 3 %connections with < 3 microns^2 not counted as a channel
          NChannelConnections(i) = NChannelConnections(i) + 1; 
       end
       
   end
end

%Total number of channels connections in entire sample
TotalChannels = sum(NChannelConnections)/2;

%Total numer of droplets touching or connecting
TotalConnections = sum(AllConnections(:))/2;

%Number of droplets with channels
NwChannels = nnz(NChannelConnections);

%Average number of channels per droplet
AvgNChannels = mean(NChannelConnections);
NonzeroAvgNChannels = mean(nonzeros(NChannelConnections));

%Percent of objects with a channel connection (# channels / # objects)
PctObjWChannels = NwChannels/FNobjects;

%percent of connections that are channels (# channels / # touching objects)
PctChannelConn = TotalChannels/TotalConnections;

%# of channels / volume of droplet
NChannelsVSvol = NChannelConnections ./ VolDroplets;
AvgNConnectionsVSvol = mean(mean(NChannelsVSvol));
NonzeroAvgNConnectionsVSvol = mean(nonzeros(NChannelsVSvol));

%area of individual channels / volume of droplet
AreaVSvol = zeros(FNobjects,FNobjects);
for i = 1:FNobjects
    for j = 1:FNobjects
       AreaVSvol(i,j) = ChannelAreaConnected(i,j) / VolDroplets(i);
    end
end
AvgAreaVSvol = mean(mean(AreaVSvol));
NonzeroAvgAreaVSvol = mean(nonzeros(AreaVSvol));

TotalAreaConnection = sum(ChannelAreaConnected,2); %total area of each droplet's channels

AvgChannelArea = mean(nonzeros(mean(nonzeros(ChannelAreaConnected)))); %Average area of channels


%total area of channels / volume of droplet
TotalChannelAreaVSvol = TotalAreaConnection ./ VolDroplets;
AvgTotalAreaVSvol = mean(TotalChannelAreaVSvol);
NonzeroAvgTotalAreaVSvol = mean(nonzeros(TotalChannelAreaVSvol));





%Write data to an excel document
%change series number for each data set
Output1 = [{'Series'},11;{'# droplets'},FNobjects;{'# droplets w/ channels'},NwChannels;...
    {'Total connections'},TotalConnections;{'Total channels'},TotalChannels;...
    {'% objects w/ channels'},PctObjWChannels;{'% channels as connections'},PctChannelConn;...
    {'Average # channels (including 0s)'},AvgNChannels ;...
    {'Average # channels (not including 0s)'},NonzeroAvgNChannels ;...
    {'Average # channels/vol (including 0s)'},AvgNConnectionsVSvol;...
    {'Average # channels/vol (not including 0s)'},NonzeroAvgNConnectionsVSvol;...
    {'Average Channel Area'},AvgChannelArea;...
    {'Average Channel Diameter'},(2*(AvgChannelArea/pi)^(1/2));...
    {'Avg individual channel area/vol (including 0s)'},AvgAreaVSvol;...
    {'Avg individual channel area/vol (not including 0s)'},NonzeroAvgAreaVSvol;...
    {'Avg total channel area/vol (including 0s)'},AvgTotalAreaVSvol;...
    {'Avg total channel area/vol (not including 0s)'},NonzeroAvgTotalAreaVSvol];
xlswrite(pathway,Output1,1);

Output2 = {'Droplet Volume'};
xlswrite(pathway,Output2,2,'A1');
xlswrite(pathway,VolDroplets,2,'A3');

Output3 = {'# of channels / droplet'};
xlswrite(pathway,Output3,3,'A1');
xlswrite(pathway,NChannelConnections,3,'A3');

Output4 = {'Area of each channel'};
xlswrite(pathway,Output4,4,'A1');
xlswrite(pathway,ChannelAreaConnected,4,'A3');

Output5 = {'# of channels / Droplet Volume'};
xlswrite(pathway,Output5,5,'A1');
xlswrite(pathway,NChannelsVSvol,5,'A3');

Output6 = {'Total Channel area / Droplet Volume'};
xlswrite(pathway,Output6,6,'A1');
xlswrite(pathway,TotalChannelAreaVSvol,6,'A3');

Output7 = {'Individual Channel area / Volume'};
xlswrite(pathway,Output7,7,'A1');
xlswrite(pathway,AreaVSvol,7,'A3');
