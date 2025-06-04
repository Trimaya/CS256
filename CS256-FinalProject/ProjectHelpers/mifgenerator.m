% MATLAB Script to Convert Audio Array to MIF File
% Replace 'audio_array' with your imported audio data
audio_array = int16(data); % Ensure the array is 16-bit integers
output_file = 'output.mif'; % Name of the MIF file

% Open file for writing
fid = fopen(output_file, 'w');

% Write MIF headers
fprintf(fid, 'DEPTH = %d;\n', length(audio_array)); % Number of samples
fprintf(fid, 'WIDTH = 16;\n'); % 16-bit data
fprintf(fid, 'ADDRESS_RADIX = HEX;\n'); % Address in hex
fprintf(fid, 'DATA_RADIX = HEX;\n'); % Data in hex
fprintf(fid, 'CONTENT\nBEGIN\n'); % Start of data

% Write each audio sample
for i = 1:length(audio_array)
    % Address in HEX
    addr = dec2hex(i-1); % Addresses start at 0
    % Value in HEX
    value = dec2hex(typecast(audio_array(i), 'uint16'), 4); % Convert to unsigned, pad to 4 hex digits
    % Write to file
    fprintf(fid, '%s : %s;\n', addr, value);
end

% End MIF file
fprintf(fid, 'END;\n');

% Close file
fclose(fid);

disp(['MIF file generated: ', output_file]);
