%Feb 26, 2018
%This program creates PDFs of mean and gaussian curvature and plots & saves
%the data.
%Use with the functions 'stlread', 'calculate_areas' and 'ShadedError'

%To use: Export the surface stl files and curvature data (in text file)
%from avizo for each quadrant of the surface. Update lines 14-31 below and
%run. The curvature pdf plots and data will be saved to the specified
%output files.

clc
clear

series = '14';    %update series number

area_to_vol = [0.29133962   0.331539547	0.265481057	0.206828307];   %area to volume fraction in order [q1 q2 q3 q4]

%update for input and output file names
mc1 = ['Curvatures/Mean/S',series,'_Q'];
mc2 = '.txt';
gc1 = ['Curvatures/Gaussian/S',series,'_Q'];
gc2 = '.txt';
s1 = ['Surfaces/S',series,'_Q'];
s2 = '.stl';
mc_output = ['PDFs/S',series,'_mean'];
gc_output = ['PDFs/S',series,'_gaussian'];

h_range = 4;
k_range = 2;
delta_h = 0.08; %bin width for mean curvature
delta_k = 0.02; %bin width for gaussian curvature

%for each quadrant of sample, calculate data for 
for Q = 1:4
    %read and parse curvature values from text file
    str = fileread([mc1,num2str(Q),mc2]);
    mean_curvatures = str2num(str);
    str = fileread([gc1,num2str(Q),gc2]);
    gauss_curvatures = str2num(str);
    
    [faces, vertices, normals] = stlread([s1,num2str(Q),s2]);   %use function to get surface data
    areas = calculate_areas(faces,vertices);    %calculate area of each triangle
    
    %calculate mean curvature data for quadrant
    denominator = sum(areas) * delta_h;
    i = 1;
    for h = -h_range:delta_h:h_range
        upper_bound = h+delta_h/2;
        lower_bound = h-delta_h/2;
        x_plot1(i,1) = h;

        array = mean_curvatures >= lower_bound & mean_curvatures < upper_bound;
        numerator = sum(areas .* array);
        y_plot1(i,1) = numerator/denominator;

        i = i+1;
    end
    
    %calculate gaussian curvature data for quadrant
    denominator = sum(areas) * delta_k;
    i = 1;
    for k = -k_range:delta_k:k_range
        upper_bound = k+delta_k/2;
        lower_bound = k-delta_k/2;
        x_plot2(i,1) = k;

        array = gauss_curvatures >= lower_bound & gauss_curvatures < upper_bound;
        numerator = sum(areas .* array);
        y_plot2(i,1) = numerator/denominator;

        i = i+1;
    end
    
    %add mean, gauss and normalized data for quadrant to variables
    if Q == 1
        mean_pdf(:,1:2) = [x_plot1, y_plot1];
        gauss_pdf(:,1:2) = [x_plot2, y_plot2];
        norm_mean_pdf(:,1:2) = [x_plot1./area_to_vol(Q), y_plot1.*area_to_vol(Q)];
        norm_gauss_pdf(:,1:2) = [x_plot2./(area_to_vol(Q)^2), y_plot2.*(area_to_vol(Q)^2)];
    else
        mean_pdf(:,Q+1) = y_plot1;
        gauss_pdf(:,Q+1) = y_plot2;
        norm_mean_pdf(:,2*Q-1:2*Q) = [x_plot1./area_to_vol(Q), y_plot1.*area_to_vol(Q)];
        norm_gauss_pdf(:,2*Q-1:2*Q) = [x_plot2./(area_to_vol(Q)^2), y_plot2.*(area_to_vol(Q)^2)];
    end
    
end

%calculate means and standard deviations for mean curvature
for n = 1:length(mean_pdf)
   mean_pdf(n,6) = mean(mean_pdf(n,2:5));   %y mean
   mean_pdf(n,7) = std(mean_pdf(n,2:5));    %y stdev
   norm_mean_pdf(n,9) = mean(norm_mean_pdf(n,1:2:7));   %x mean
   norm_mean_pdf(n,10) = mean(norm_mean_pdf(n,2:2:8));  %y mean
   norm_mean_pdf(n,11) = std(norm_mean_pdf(n,1:2:7));   %x stdev
   norm_mean_pdf(n,12) = std(norm_mean_pdf(n,2:2:8));   %ystdev
end

%calculate means and standard deviations for gaussian curvature
for n = 1:length(gauss_pdf)
   gauss_pdf(n,6) = mean(gauss_pdf(n,2:5)); %y mean
   gauss_pdf(n,7) = std(gauss_pdf(n,2:5));  %y stdev
   norm_gauss_pdf(n,9) = mean(norm_gauss_pdf(n,1:2:7)); %x mean
   norm_gauss_pdf(n,10) = mean(norm_gauss_pdf(n,2:2:8));    %y mean
   norm_gauss_pdf(n,11) = std(norm_gauss_pdf(n,1:2:7)); %x stdev
   norm_gauss_pdf(n,12) = std(norm_gauss_pdf(n,2:2:8)); %y stdev
end

%plot mean curvature data with shaded error bar
figure(1)
mean_line = ShadedError(mean_pdf(:,1),mean_pdf(:,6),mean_pdf(:,7),'k','r',1);
grid on
title(['Mean Curvature Probability Density - Series ',num2str(series)],'Interpreter','none');
xlabel('H');
ylabel('P(H)');

%plot gaussian curvature data with shaded error bar
figure(2)
gauss_line = ShadedError(gauss_pdf(:,1),gauss_pdf(:,6),gauss_pdf(:,7),'k','r',1);
grid on
title(['Gaussian Curvature Probability Density - Series ',num2str(series)],'Interpreter','none');
xlabel('K');
ylabel('P(K)');

%plot normalized mean curvature data with shaded error bar
figure(3)
norm_mean_line = ShadedError(norm_mean_pdf(:,9),norm_mean_pdf(:,10),norm_mean_pdf(:,12),'k','r',1);
grid on
title(['Mean Curvature Normalized Probability Density - Series ',num2str(series)],'Interpreter','none');
xlabel('H/Q');
ylabel('Q P(H)');

%plot normalized gaussian curvature data with shaded error bar
figure(4)
norm_gauss_line = ShadedError(norm_gauss_pdf(:,9),norm_gauss_pdf(:,10),norm_gauss_pdf(:,12),'k','r',1);
grid on
title(['Gaussian Curvature Normalized Probability Density - Series ',num2str(series)],'Interpreter','none');
xlabel('K/Q^2');
ylabel('Q^2P(H)');

%save curvature data used in plotting to excel files
saveas(figure(1),[mc_output,'-quadrants.jpg']);
saveas(figure(2),[gc_output,'-quadrants.jpg']);
saveas(figure(3),[mc_output,'_normalized-quadrants.jpg']);
saveas(figure(4),[gc_output,'_normalized-quadrants.jpg']);

xlswrite([mc_output,'-quadrants.xlsx'],mean_pdf);
xlswrite([gc_output,'-quadrants.xlsx'],gauss_pdf);
xlswrite([mc_output,'_normalized-quadrants.xlsx'],norm_mean_pdf);
xlswrite([gc_output,'_normalized-quadrants.xlsx'],norm_gauss_pdf);

