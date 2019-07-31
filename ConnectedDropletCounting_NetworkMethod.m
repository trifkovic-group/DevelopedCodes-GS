clear
clc

%update lines 5 to 14 for each data set
Series = '006';
DataPathway = 'D:/Geena/for Maziar/ConnectedDroplets/DMSO June 14/0.75/0.75Series006InitialData.xlsx';
ResultsPathway = 'D:/Geena/for Maziar/ConnectedDroplets/DMSO June 14/0.75/0.75Series006FinalData.xlsx';

NumObjects = 587;
NumChannels = 1376;
NumConnections = 1787;

PoreDataRange = 'B2:D588'; %objects
ChannelDataRange = 'B2:E1377'; %channels


Pores = xlsread(DataPathway,1,PoreDataRange); %volume, area, radius
Channels = xlsread(DataPathway,2,ChannelDataRange); %area, radius, pore 1, pore 2
Channels(:,3:4) = Channels(:,3:4) + 1; %adjust pore index number

ChannelConnectionMatrix = zeros(NumObjects,NumObjects); %1 represents presence of channel
IndvChannelArea = zeros(NumObjects,NumObjects);
DropletChannelArea = zeros(NumObjects,1); %total channel area for each droplet

for i = 1:NumChannels
    ChannelConnectionMatrix(Channels(i,3),Channels(i,4)) = 1;
    ChannelConnectionMatrix(Channels(i,4),Channels(i,3)) = 1;
    
    IndvChannelArea(Channels(i,3),Channels(i,4)) = Channels(i,1);
    IndvChannelArea(Channels(i,4),Channels(i,3)) = Channels(i,1);
    
    DropletChannelArea(Channels(i,3)) = DropletChannelArea(Channels(i,3)) + Channels(i,1);
    DropletChannelArea(Channels(i,4)) = DropletChannelArea(Channels(i,4)) + Channels(i,1);
end


NumChannelsPerDrop = sum(ChannelConnectionMatrix,2); %number of channels connected to each droplet
NumDropsWChannels = nnz(NumChannelsPerDrop); %number of droplets with channels

PctObjWChannels = NumDropsWChannels/NumObjects; %percentage of droplets that have channels

PctChannelsVsConnections = NumChannels / NumConnections; %percent of connections that are channels

AvgChannelArea = mean(Channels(:,1));
AvgChannelRadius = mean(Channels(:,2));
AvgChannelDiameter = AvgChannelRadius * 2;

AvgNumChannels = mean(NumChannelsPerDrop); %average number of channels per droplet
AvgNumChannelsNonZero = mean(nonzeros(NumChannelsPerDrop));

NumChannelsPerVol = NumChannelsPerDrop ./ Pores(:,1); %number of channels per droplet volume
AvgChannelsPerVol = mean(NumChannelsPerVol(:));
AvgChannelsPerVolNonZero = mean(nonzeros(NumChannelsPerVol));

%individual channel area / vol
IndvAreaPerVol = zeros(NumObjects,NumObjects);
for i = 1:NumChannels
    IndvAreaPerVol( Channels(i,3),Channels(i,4) ) = ( Channels(i,1) / Pores(Channels(i,3),1) );
    IndvAreaPerVol( Channels(i,4),Channels(i,3) ) = ( Channels(i,1) / Pores(Channels(i,4),1) );
end
AvgIndvAreaPerVol = mean(mean(IndvAreaPerVol));
AvgIndvAreaPerVolNonZero = mean( nonzeros( mean(nonzeros(IndvAreaPerVol)) ) );

TotalAreaPerVol = DropletChannelArea(:) ./ Pores(:,1); %total channel area on droplet per droplet volume
AvgTotalAreaPerVol = mean(TotalAreaPerVol);
AvgTotalAreaPerVolNonZero = mean(nonzeros(TotalAreaPerVol));


%Write data to an excel document
%change series number for each data set
Output1 = [{'Series'},Series;{'# droplets'},NumObjects;{'# droplets w/ channels'},NumDropsWChannels;...
    {'Total connections (jamming & channels)'},NumConnections;{'Total channels'},NumChannels;...
    {'% objects w/ channels'},PctObjWChannels;{'% channels as connections'},PctChannelsVsConnections;...
    {'Average # channels (including 0s)'},AvgNumChannels ;...
    {'Average # channels (not including 0s)'},AvgNumChannelsNonZero ;...
    {'Average # channels/vol (including 0s)'},AvgChannelsPerVol;...
    {'Average # channels/vol (not including 0s)'},AvgChannelsPerVolNonZero;...
    {'Average Channel Area'},AvgChannelArea;...
    {'Average Channel Radius'},AvgChannelRadius;...
    {'Avg individual channel area/vol (including 0s)'},AvgIndvAreaPerVol;...
    {'Avg individual channel area/vol (not including 0s)'},AvgIndvAreaPerVolNonZero;...
    {'Avg total channel area/vol (including 0s)'},AvgTotalAreaPerVol;...
    {'Avg total channel area/vol (not including 0s)'},AvgTotalAreaPerVolNonZero];
xlswrite(ResultsPathway,Output1,1);

Output2 = {'Droplet Volume'};
xlswrite(ResultsPathway,Output2,2,'A1');
xlswrite(ResultsPathway,Pores(:,1),2,'A3');

Output3 = {'# of channels / droplet'};
xlswrite(ResultsPathway,Output3,3,'A1');
xlswrite(ResultsPathway,NumChannelsPerDrop,3,'A3');

Output4 = {'Area of each channel'};
xlswrite(ResultsPathway,Output4,4,'A1');
xlswrite(ResultsPathway,IndvChannelArea,4,'A3');

Output5 = {'# of channels / Droplet Volume'};
xlswrite(ResultsPathway,Output5,5,'A1');
xlswrite(ResultsPathway,NumChannelsPerVol,5,'A3');

Output6 = {'Total Channel area / Droplet Volume'};
xlswrite(ResultsPathway,Output6,6,'A1');
xlswrite(ResultsPathway,TotalAreaPerVol,6,'A3');

Output7 = {'Individual Channel area / Volume'};
xlswrite(ResultsPathway,Output7,7,'A1');
xlswrite(ResultsPathway,IndvAreaPerVol,7,'A3');


