%Feb 1, 2018
%This program analyzes the connectivity of the lutidine and water phase of
%Rachel's bijels
%Note: this program makes use of the function "confocal_connectivity_3d"

%To use: from avizo export the excel files with data from the 'auto
%skeleton'and 'spatial graph statistics' modules for the lutidine and water 
%phases. Update lines 15-26 below and run the program. Output will be 
%formatted and saved in the file specified in "output_file".

clc
clear

%Update lines 15-26 below
series = '9';

sample_name = ['5wt% Homo Series ',series];
particles_skeleton_file = ['Connectivity/S',series,'_c1.xml'];   %from auto skeleton module
particles_statistics_file = ['Connectivity/S',series,'_c2.xml'];   %from spatial graph statistics module
void_skeleton_file = ['Connectivity/S',series,'_c3.xml'];   %from auto skeleton module
void_statistics_file = ['Connectivity/S',series,'_c4.xml'];   %from spatial graph statistics module
output_file = ['Connectivity/S',series,'_Connectivity.xlsx'];

%Number of isolated objects for each channel
lutidine_nobj = 1;
water_nobj = 2;

%call function to calculate connectivity data. Return variable is a column
%vector
particles_data = confocal_connectivity_3d(particles_skeleton_file, particles_statistics_file);
void_data = confocal_connectivity_3d(void_skeleton_file, void_statistics_file);


%write results to output file
headers = [{'Number of Nodes'};{'Max Coordination Number'}; ...
    {'Avg Coordination Number'};{'Max Branch Length'}; ...
    {'Avg Branch Length'};{'Max Branch Diameter'};{'Avg Branch Diameter'}; ...
    {'Tails not on Boarder'};{'Tail Percentage'};{'Isolated Objects'}];

xlswrite(output_file,[{sample_name}],1,'B1:B1');
xlswrite(output_file,[{'Lutidine'},{'Water'}],1,'B2:C2');
xlswrite(output_file,headers,1,'A3:A12');
xlswrite(output_file,[particles_data, void_data],1,'B3:C11');
xlswrite(output_file, [lutidine_nobj,water_nobj],1,'B12:C12');
