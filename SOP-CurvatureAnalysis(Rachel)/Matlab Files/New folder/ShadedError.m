%Feb 27, 2018
%this function plots with a shaded region for error bars. Line is plotted
%and error bar represented by shaded region each with colours specified by
%input arguments. Function returns the plotted line for use in a legend.

%Note: 'include_error' is an optional argument to determine if the error bar
%should be included. If the error bar should be included, pass any value to 
%the function. 


function [ line ] = ShadedError( x,y,error,plot_colour,error_colour,include_error )
    curve1 = y-error;
    curve2 = y+error;
    
    hold on
    
    if exist('include_error','var')    %determine if error bar is included
        x2 = [x;flipud(x)];
        inBetween = [curve1;flipud(curve2)];
        fill(x2,inBetween,error_colour,'LineStyle','none');  %shading
    end
    
    line = plot(x,y,'Color',plot_colour,'LineWidth',2);   %line
    alpha(0.3)  %adjust for amount of transparency
    hold off
    
end

