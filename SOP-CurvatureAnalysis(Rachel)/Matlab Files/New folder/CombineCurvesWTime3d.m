%April 17, 2018
%this program plots the normalized mean and gaussian curvature PDFs in 3D, 
%with the 3rd dimension being the time.

%To use: First run the program "Bijel_Curvatures_quadrants". Update lines 
%13-21 below for series, legend, time and file names for each curvature to 
%be plotted, and run the program. The each graph will be on a new figure, 
%but will not be saved automatically.

clc
clear

series = {'14';'19';'25';'29';'36';'42';'46';'54';'60'};    %each series to be plotted
lgnd = {'6 Min';'10 Min';'14 Min';'18 Min';'22 Min';'24 Min';'27 Min';'30 Min';'34 Min'};   %legend
tm = [6,10,14,18,22,24,27,30,34];   %relative time for 3rd dimension

%naming convention to locate each file
mc1 = 'PDFs/S';
mc2 = '_mean';
gc1 = 'PDFs/S';
gc2 = '_gaussian';

time=ones(51,length(tm));
timeg=ones(41,length(tm));

for i= 1:length(tm)
    time(:,i)=tm(i)*time(:,i);
    timeg(:,i)=tm(i)*timeg(:,i);
end

hold on
colorOrder = get(gca,'ColorOrder');

for i = 1:length(series)
    %read data from text file
    mean_data(:,:) = xlsread([mc1,cell2mat(series(i)),mc2,'.xlsx']);
    normmean_data(:,:) = xlsread([mc1,cell2mat(series(i)),mc2,'_normalized.xlsx']);
    gauss_data(:,:) = xlsread([gc1,cell2mat(series(i)),gc2,'.xlsx']);
    normgauss_data(:,:) = xlsread([gc1,cell2mat(series(i)),gc2,'_normalized.xlsx']);
    
    normmean_HQ(:,i)=normmean_data(:,1);
    normmean_QP(:,i)=normmean_data(:,10);
    normgauss_KQ2(:,i)=normgauss_data(:,1);
    normgauss_Q2P(:,i)=normgauss_data(:,10);
    
    hold on
    figure(1)
    t = zeros(size(normmean_data(:,1)));
    t(:) = tm(i);
    normmean_plot(i) = plot3(normmean_data(:,1),t,normmean_data(:,10),'LineWidth',3);

    hold on
    tg = zeros(size(normgauss_data(:,1)));
    tg(:) = tm(i);
    figure(2)
    normgauss_plot(i) = plot3(normgauss_data(:,1),tg,normgauss_data(:,10),'LineWidth',3);
end

%Normalized Mean Plot
figure(1)
hold on
grid on
legend(normmean_plot,lgnd)
title('Normalized Mean Curvature')  %Set labels
xlabel('H/Q')
ylabel('Heating Time (min)')
zlabel('QP(H)')
xlim([-4,4])   %adjust x,y,z ranges
ylim([0,40])
zlim([0,1])
hold off
xticks(-4:1:4)  %adjust x,y,z subticks
yticks(0:10:40)
zticks(0:0.1:1)
set(gca,'fontsize',15)  %set font size

%Normalized Gaussian Plot
figure(2)
hold on
grid on
legend(normgauss_plot,lgnd)
title('Normalized Gaussian Curvature')  %Set labels
xlabel('K/Q^2')
ylabel('Heating Time (min)')
zlabel('Q^2P(K)')
xlim([-3,3])    %adjust x,y,z ranges
ylim([0,40])
zlim([0 4.5])
hold off
xticks(-3:1:3)  %adjust x,y,z subticks
yticks(0:10:40)
zticks(0:0.5:4.5)
set(gca,'fontsize',15)  %set font size
