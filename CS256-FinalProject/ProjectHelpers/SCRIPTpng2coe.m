% MATLAB Script to Convert PNG Image to .coe File with Upright Rendering
% Author: Your Name
% Date: YYYY-MM-DD
clear
clc

% Parameters
image_path = 'TankBlue90.png'; % Input PNG file
output_file = 'TankBlue90.coe'; % Output .coe file
bit_depth = 4; % Bit depth for each color channel (e.g., 4 bits per R, G, B)

% Load the image
imgraw = imread(image_path);

% Ensure the image is RGB (strip alpha channel if present)
if size(imgraw, 3) == 4
    imgraw = imgraw(:, :, 1:3); % Retain only R, G, and B channels
end

% Scale RGB values to the desired bit depth
img = double(imgraw);
img10bit = zeros(size(imgraw, 1), size(imgraw, 2), 3);
img10bit(:, :, 1) = floor((img(:, :, 1) / 255) * (2^bit_depth - 1)); % Scale R to bit_depth
img10bit(:, :, 2) = floor((img(:, :, 2) / 255) * (2^bit_depth - 1)); % Scale G to bit_depth
img10bit(:, :, 3) = floor((img(:, :, 3) / 255) * (2^bit_depth - 1)); % Scale B to bit_depth

% Assuming img10bit is a 3D array with dimensions [height, width, channels]
pixel_values = zeros(size(img10bit, 1) * size(img10bit, 2), 1); % Preallocate for all combined RGB components

index = 1; % Initialize index for pixel_values
for y = 1:size(img10bit, 1) % Loop over rows
    for x = 1:size(img10bit, 2) % Loop over columns
        % Combine R, G, and B values into one 12-bit value
        pixel_values(index) = ...
            (img10bit(y, x, 1) * (2^(2 * bit_depth))) + ...
            (img10bit(y, x, 2) * (2^bit_depth)) + ...
            img10bit(y, x, 3);
        index = index + 1; % Increment index for the next pixel
    end
end

% Write to .coe file
fid = fopen(output_file, 'w');
fprintf(fid, 'memory_initialization_radix=16;\n'); % Set radix (e.g., hex)
fprintf(fid, 'memory_initialization_vector=\n');

% Write pixel values row by row
for i = 1:length(pixel_values)
    if i == length(pixel_values)
        fprintf(fid, '%X;\n', pixel_values(i)); % Last value ends with ;
    else
        fprintf(fid, '%X,\n', pixel_values(i)); % Others end with ,
    end
end

% Close file
fclose(fid);

% Display confirmation
fprintf('Image converted to .coe file with upright rendering and saved as %s\n', output_file);
