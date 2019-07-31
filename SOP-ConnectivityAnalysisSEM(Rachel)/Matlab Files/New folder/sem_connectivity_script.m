%Feb 1, 2018    --  Used for Rachel's SEM (and confocal) 2d images

%This program makes use of the function 'sem_connectivity' in
%'sem_connectivity.m'

%To use: export excel files with data from auto skeleton and spatial graph
%statistics for the particle and void space in avizo. Update lines 15-25
%below and run. Output will be formatted and saved in the specified output
%excel file.

clc
clear

%Update lines 15-25 below
series = 25;
sample_name = ['vortex_10wt_bijel',pad(num2str(series),2,'left','0')];
particles_skeleton_file = ['vortex_10wt_bijel',pad(num2str(series),2,'left','0'),'_PartSkel.xml'];   %from auto skeleton module
particles_statistics_file = ['vortex_10wt_bijel',pad(num2str(series),2,'left','0'),'_PartStat.xml'];   %from spatial graph statistics module
void_skeleton_file = ['vortex_10wt_bijel',pad(num2str(series),2,'left','0'),'_VoidSkel.xml'];   %from auto skeleton module
void_statistics_file = ['vortex_10wt_bijel',pad(num2str(series),2,'left','0'),'_VoidStat.xml'];   %from spatial graph statistics module
output_file = ['vortex_10wt_bijel',pad(num2str(series),2,'left','0'),'.xlsx'];

%number of isolated objects
particles_nobj = 1;
void_nobj = 1;

%call function to calculate connectivity data. Return variable is a column
%vector
particles_data = sem_connectivity(particles_skeleton_file, particles_statistics_file);
void_data = sem_connectivity(void_skeleton_file, void_statistics_file);

%write results to output file
headers = [{'Number of Nodes'};{'Max Coordination Number'}; ...
    {'Avg Coordination Number'};{'Max Branch Length'}; ...
    {'Avg Branch Length'};{'Max Branch Diameter'};{'Avg Branch Diameter'}; ...
    {'Tails not on Boarder'};{'Tail Percentage'};{'Isolated Objects'}];

xlswrite(output_file,[{sample_name}],1,'B1:B1');
xlswrite(output_file,[{'Particles'},{'Void'}],1,'B2:C2');
xlswrite(output_file,headers,1,'A3:A12');
xlswrite(output_file,[particles_data, void_data],1,'B3:C11');
xlswrite(output_file,[particles_nobj,void_nobj],1,'B12:C12');

