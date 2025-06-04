% Script to generate a 32x32 image with a line pattern and alternating colors
% Author: Your Name
% Date: Today

% Dimensions of the image
img_size = 32;

% Initialize the image matrix
image_matrix = zeros(img_size, img_size, 3, 'uint8');

% Generate alternating line colors
% Use unique 10-bit colors for each row (5-bit red, 3-bit green, 2-bit blue)
red_values = 0:31;   % 5 bits (0-31)
green_values = 0:7;  % 3 bits (0-7)
blue_values = 0:3;   % 2 bits (0-3)

% Generate 32 unique colors (one for each row)
line_colors = zeros(32, 3, 'uint8');
index = 1;
for red = red_values
    for green = green_values
        for blue = blue_values
            if index > 32
                break; % Only need 32 colors (one for each row)
            end
            line_colors(index, :) = [red * 8, green * 32, blue * 64]; % Scale to 8-bit
            index = index + 1;
        end
    end
end

% Fill the 32x32 image with the line pattern
for row = 1:img_size
    for col = 1:img_size
        if mod(col, 2) == 0
            % Fill every second column with the row's color
            image_matrix(row, col, :) = line_colors(row, :);
        else
            % Keep the other columns black
            image_matrix(row, col, :) = [0, 0, 0];
        end
    end
end

% Save the image as a PNG
output_filename = 'line_pattern_32x32.png';
imwrite(image_matrix, output_filename);

% Display the image
imshow(image_matrix);
title('32x32 Line Pattern with Alternating Colors');

% Confirm completion
fprintf('Image saved as %s\n', output_filename);
