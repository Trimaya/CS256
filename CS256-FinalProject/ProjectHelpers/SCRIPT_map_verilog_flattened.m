% MATLAB Script to Convert Pixel Art PNG to Verilog Map with Assign and Line Breaks
% Author: Your Name
% Date: YYYY-MM-DD

% Specify the path to your PNG file
image_path = 'happybday.png'; % Replace with your exported PNG file

% Load the image
img = imread(image_path);

% Convert to grayscale if the image is colored
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Resize the image to match the map resolution (32x25 blocks)
% Use 'nearest' to preserve sharp pixel edges
map_resized = imresize(img, [25, 40], 'nearest');

% Threshold the grayscale image to binary (walls = 1, empty = 0)
binary_map = imbinarize(map_resized);

% Open a file to save the Verilog output
output_file = 'map_verilog_flattened.txt'; % Output file name
fid = fopen(output_file, 'w');

% Write Verilog assign statement header
fprintf(fid, 'assign map0 = {\n'); % Start Verilog assign statement

binary_map = flipud(fliplr(binary_map));

% Process binary map row by row
rows = size(binary_map, 1); % 25 rows
cols = size(binary_map, 2); % 40 columns

for r = 1:rows
    % Convert the current row to a binary string
    row_binary = binary_map(r, :);
    row_str = sprintf('%d', row_binary);
    
    % Write the row as a 40-bit Verilog binary string
    if r < rows
        fprintf(fid, "    40\'b%s,\n", row_str); % Add comma if not the last row
    else
        fprintf(fid, "    40\'b%s\n", row_str); % No comma for the last row
    end
end

% Close the Verilog assign statement
fprintf(fid, '};\n');

% Close the file
fclose(fid);

% Display confirmation
fprintf('Map converted and saved to %s\n', output_file);