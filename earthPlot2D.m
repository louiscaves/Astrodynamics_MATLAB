% Puts an image of the earth on a 2D plot
function []=earthPlot2D    
    img = imread('2_no_clouds_4k.jpg'); %load picture of earth
    
    % Define the range of coordinates (x, y) to scale the image to
    x_range = [-180, 180]; % Replace xmin and xmax with your desired values
    y_range = [90, -90]; % Replace ymin and ymax with your desired values
    
    % Define the corresponding x and y values for the image dimensions
    x = linspace(x_range(1), x_range(2), size(img, 2));
    y = linspace(y_range(1), y_range(2), size(img, 1));
    
    % Plot the scaled image
    imagesc(x, y, img);
    axis equal
    set(gca, 'YDir', 'normal');
end