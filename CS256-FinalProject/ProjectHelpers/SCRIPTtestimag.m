% MATLAB Script to Convert PNG Image to .coe File
% Author: Your Name
% Date: YYYY-MM-DD

% Parameters
image_path = 'test_image_32x32_10bit.png'; % Input PNG file
output_file = 'testimagcolors.coe'; % Output .coe file
bit_depth = 4; % Bit depth for each color channel (e.g., 4 bits per R, G, B)

% Load the image
img = imread(image_path);
% Transpose
for i = size(img,3)
    img(:,:,i) = img(:,:,i)';
end

% Ensure the image is RGB (strip alpha channel if present)
if size(img, 3) == 4
    img = img(:, :, 1:3); % Retain only R, G, and B channels
end

% Resize image if necessary (modify as needed)
% For example, to ensure a specific resolution:
% img = imresize(img, [desired_height, desired_width], 'nearest');

% Scale RGB values to the desired bit depth
max_val = 2^bit_depth - 1; % Maximum value for the specified bit depth
img = round(double(img) / 255 * max_val); % Scale to bit_depth values

% Convert the image to a vector (row-by-row)
pixel_vector = reshape(img, [], 3); % Each row is [R, G, B]

% Convert RGB values to combined integer
% Example: If bit_depth = 4, 12-bit RGB = R(4 bits), G(4 bits), B(4 bits)
pixel_values = pixel_vector(:, 1) * (2^(2*bit_depth)) + ...
               pixel_vector(:, 2) * (2^bit_depth) + ...
               pixel_vector(:, 3);

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
fprintf('Image converted to .coe file and saved as %s\n', output_file);
