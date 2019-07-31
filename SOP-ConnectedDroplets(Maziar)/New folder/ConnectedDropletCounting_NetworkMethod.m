%Jan 9, 2018

clear
clc

%To use: Follow SOP for connected droplets to obtain an excel document with
%data from the pore network model. Update lines 10 to 16 below with the
%series number, data file, and excel file to hold the formatted results.

Identifier = '0.8%';
Data_File = 'Series007_0.8%HMDS_Data.xml';    %File holding input data
Results_File = 'Series007_0.8%HMDS_Results.xlsx';   %file to hold formatted output

Num_Objects = 45;       %from pore network model of liquid only
Num_Channels = 30;      %from pore network model of liquid only
Num_Connections = 83;  %from pore network model of both channels

Pores = xlsread(Data_File,1,strcat('B2:D',num2str(Num_Objects+1))); %volume, area, radius

Channels = zeros(Num_Channels,4);
Channels(:,1:2) = xlsread(Data_File,2,strcat('B2:C',num2str(Num_Channels+1)));
Channels(:,3:4) = xlsread(Data_File,2,strcat('E2:F',num2str(Num_Channels+1))); %array holds data: area, radius, pore 1, pore 2
Channels(:,3:4) = Channels(:,3:4) + 1; %adjust pore index number

Channel_Connection_Matrix = zeros(Num_Objects,Num_Objects); %1 represents presence of channel
Indv_Channel_Area = zeros(Num_Objects,Num_Objects);
Droplet_Channel_Area = zeros(Num_Objects,1); %total channel area for each droplet

for i = 1:Num_Channels
    Channel_Connection_Matrix(Channels(i,3),Channels(i,4)) = 1;
    Channel_Connection_Matrix(Channels(i,4),Channels(i,3)) = 1;
    
    Indv_Channel_Area(Channels(i,3),Channels(i,4)) = Channels(i,1);
    Indv_Channel_Area(Channels(i,4),Channels(i,3)) = Channels(i,1);
    
    Droplet_Channel_Area(Channels(i,3)) = Droplet_Channel_Area(Channels(i,3)) + Channels(i,1);
    Droplet_Channel_Area(Channels(i,4)) = Droplet_Channel_Area(Channels(i,4)) + Channels(i,1);
end


Num_Channels_Per_Drop = sum(Channel_Connection_Matrix,2); %number of channels connected to each droplet
Num_Drops_W_Channels = nnz(Num_Channels_Per_Drop); %number of droplets with channels

Pct_Obj_W_Channels = Num_Drops_W_Channels/Num_Objects; %percentage of droplets that have channels

Pct_Channels_Vs_Connections = Num_Channels / Num_Connections; %percent of connections that are channels

Avg_Channel_Area = mean(Channels(:,1));
Avg_Channel_Radius = mean(Channels(:,2));
Avg_Channel_Diameter = Avg_Channel_Radius * 2;

Avg_Num_Channels = mean(Num_Channels_Per_Drop); %average number of channels per droplet
Avg_Num_Channels_NonZero = mean(nonzeros(Num_Channels_Per_Drop));

Num_Channels_Per_Vol = Num_Channels_Per_Drop ./ Pores(:,1); %number of channels per droplet volume
Avg_Channels_Per_Vol = mean(Num_Channels_Per_Vol(:));
Avg_Channels_Per_Vol_NonZero = mean(nonzeros(Num_Channels_Per_Vol));

%individual channel area / vol
Indv_Area_Per_Vol = zeros(Num_Objects,Num_Objects);
for i = 1:Num_Channels
    Indv_Area_Per_Vol( Channels(i,3),Channels(i,4) ) = ( Channels(i,1) / Pores(Channels(i,3),1) );
    Indv_Area_Per_Vol( Channels(i,4),Channels(i,3) ) = ( Channels(i,1) / Pores(Channels(i,4),1) );
end
Avg_Indv_Area_Per_Vol = mean(mean(Indv_Area_Per_Vol));
Avg_Indv_Area_Per_Vol_NonZero = mean( nonzeros( mean(nonzeros(Indv_Area_Per_Vol)) ) );

Total_Area_Per_Vol = Droplet_Channel_Area(:) ./ Pores(:,1); %total channel area on droplet per droplet volume
Avg_Total_Area_Per_Vol = mean(Total_Area_Per_Vol);
Avg_Total_Area_Per_Vol_NonZero = mean(nonzeros(Total_Area_Per_Vol));


%Write data to an excel document
Output1 = [{'Series'},Identifier;{'# droplets'},Num_Objects;{'# droplets w/ channels'},Num_Drops_W_Channels;...
    {'Total connections (jamming & channels)'},Num_Connections;{'Total channels'},Num_Channels;...
    {'% objects w/ channels'},Pct_Obj_W_Channels;{'% channels as connections'},Pct_Channels_Vs_Connections;...
    {'Average # channels (including 0s)'},Avg_Num_Channels ;...
    {'Average # channels (not including 0s)'},Avg_Num_Channels_NonZero ;...
    {'Average # channels/vol (including 0s)'},Avg_Channels_Per_Vol;...
    {'Average # channels/vol (not including 0s)'},Avg_Channels_Per_Vol_NonZero;...
    {'Average Channel Area'},Avg_Channel_Area;...
    {'Average Channel Radius'},Avg_Channel_Radius;...
    {'Avg individual channel area/vol (including 0s)'},Avg_Indv_Area_Per_Vol;...
    {'Avg individual channel area/vol (not including 0s)'},Avg_Indv_Area_Per_Vol_NonZero;...
    {'Avg total channel area/vol (including 0s)'},Avg_Total_Area_Per_Vol;...
    {'Avg total channel area/vol (not including 0s)'},Avg_Total_Area_Per_Vol_NonZero];
xlswrite(Results_File,Output1,1);

Output2 = {'Droplet Volume'};
xlswrite(Results_File,Output2,2,'A1');
xlswrite(Results_File,Pores(:,1),2,'A3');

Output3 = {'# of channels / droplet'};
xlswrite(Results_File,Output3,3,'A1');
xlswrite(Results_File,Num_Channels_Per_Drop,3,'A3');

Output4 = {'Area of each channel'};
xlswrite(Results_File,Output4,4,'A1');
xlswrite(Results_File,Indv_Channel_Area,4,'A3');

Output5 = {'# of channels / Droplet Volume'};
xlswrite(Results_File,Output5,5,'A1');
xlswrite(Results_File,Num_Channels_Per_Vol,5,'A3');

Output6 = {'Total Channel area / Droplet Volume'};
xlswrite(Results_File,Output6,6,'A1');
xlswrite(Results_File,Total_Area_Per_Vol,6,'A3');

Output7 = {'Individual Channel area / Volume'};
xlswrite(Results_File,Output7,7,'A1');
xlswrite(Results_File,Indv_Area_Per_Vol,7,'A3');


