%Feb 14, 2018   -- used for Rachel's Bijels
%Algorithm from "On the coarsening of immiscible polymer blends with
%cocontinuous morphology" by Carlos Rene Lopez-Barron
 
%Note: script makes use of the functions 'stlread' and 'calculate_areas'.

%To use: from avizo, export an stl file of the surface, and text files of
%the mean and gaussian curvatures for each face. Update lines 15-23 below.
%Images and excel files of the pdf data will be saved for both mean and
%gaussian curvatures

clc
clear

series = '16_t3';

areavol = 6950.16/7703.76; %Update for area to volume ratio

meancurv_file = ['Curvatures/Mean/S',series,'.txt'];  %text file with mean curvatures
gausscurv_file = ['Curvatures/Gaussian/S',series,'.txt']; %text file with gaussian curvatures
surface_file = ['Surfaces/S',series,'.stl'];  %surface stl file
mean_output = ['PDFs/S',series,'_mean'];   %output name for mean curvature pdfs
gauss_output = ['PDFs/S',series,'_gaussian']; %output name for gaussian curvature pdfs


str = fileread(meancurv_file);
mean_curvatures = str2num(str); %mean curvatures for each face

str = fileread(gausscurv_file);
gauss_curvatures = str2num(str);    %gauss curvatures for each face

[faces, vertices, normals] = stlread(surface_file);  %normal vectors are read in but not used
areas = calculate_areas(faces,vertices);    %calculate area of each triangle

delta_h = 0.08; %bin width
denominator = sum(areas) * delta_h;
i = 1;

for h = -2:delta_h:2
    upper_bound = h+delta_h/2;
    lower_bound = h-delta_h/2;
    x_plot1(i,1) = h;

    array = mean_curvatures >= lower_bound & mean_curvatures < upper_bound;
    numerator = sum(areas .* array);
    y_plot1(i,1) = numerator/denominator;

    i = i+1;
end

%plot and save mean curvature pdf
plot(x_plot1,y_plot1,'LineWidth',2)
title(['Mean Curvature - Series 16 t3']);
xlabel('H');
ylabel('P(H)');
grid on
saveas(figure(1),[mean_output,'.jpg']);    %save plot
xlswrite([mean_output,'.xlsx'],[x_plot1,y_plot1]);  %save data points

%plot and save normalized mean curvature pdf
figure
plot(x_plot1 ./ areavol,y_plot1 .* areavol,'LineWidth',2)
title(['Normalized Mean Curvature - Series 16 t3']);
xlabel('H/Q');
ylabel('QP(H)');
grid on
saveas(figure(2),[mean_output,'-normalized.jpg']);    %save plot
xlswrite([mean_output,'-normalized.xlsx'],[x_plot1 ./ areavol,y_plot1 .* areavol]); %save data points


delta_k = 0.02; %bin width
denominator = sum(areas) * delta_k;
i = 1;

for k = -0.4:delta_k:0.4
    upper_bound = k+delta_k/2;
    lower_bound = k-delta_k/2;
    x_plot2(i,1) = k;
   
    array = gauss_curvatures >= lower_bound & gauss_curvatures < upper_bound;
    numerator = sum(areas .* array);
    y_plot2(i,1) = numerator/denominator;
   
    i = i+1;
end

%plot and save gaussian curvature pdf
figure
plot(x_plot2,y_plot2,'LineWidth',2)
title(['Gaussian Curvature - Series 16 t3']);
xlabel('K');
ylabel('P(K)');
grid on
saveas(figure(3),[gauss_output,'.jpg']);   %save plot
xlswrite([gauss_output,'.xlsx'],[x_plot2,y_plot2]); %save data points

%plot and save normalized gaussian curvature pdf
figure
plot(x_plot2 ./ (areavol^2),y_plot2 .* (areavol^2),'LineWidth',2)
title(['Normalized Gaussian Curvature - Series 16 t3']);
xlabel('K/Q^2');
ylabel('Q^2P(H)');
grid on
saveas(figure(4),[gauss_output,'-normalized.jpg']);   %save plot
xlswrite([gauss_output,'-normalized.xlsx'],[x_plot2 ./ (areavol^2),y_plot2] .* (areavol^2));    %save data points



