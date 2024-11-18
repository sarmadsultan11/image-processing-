% Define the folder containing the images
folder_path = 'C:\Users\garav\OneDrive\Pictures\dsp_project_images';  % Change this to your folder path

% Get all image files in the folder (you can specify a file extension like *.jpg, *.png, etc.)
image_files = dir(fullfile(folder_path, '*.jpg'));  % Change the extension as needed (e.g., *.png)

% Create a cell array of full paths to the images
image_paths = cell(1, numel(image_files));
for i = 1:numel(image_files)
    image_paths{i} = fullfile(folder_path, image_files(i).name);
end

% Call the wavelet_dwt_compression function with the list of image paths
[compressed_images, compressed_sizes, compression_ratios, psnrs] = wavelet_dwt_compression(image_paths);

% Function Definition
function [compressed_images, compressed_sizes, compression_ratios, psnrs] = wavelet_dwt_compression(image_files)
    % Initialize output variables for multiple images
    num_images = numel(image_files);
    compressed_images = cell(num_images, 1);
    compressed_sizes = zeros(num_images, 1);
    compression_ratios = zeros(num_images, 1);
    psnrs = zeros(num_images, 1);
    
    % Loop through each image file
    for i = 1:num_images
        % Load the current image
        img = imread(image_files{i});
        img = double(img);  % Convert to double for processing
        [rows, cols, num_channels] = size(img);
        
        % Initialize compressed image and size tracker for this image
        compressed_image = cell(num_channels, 1);  
        compressed_size = 0;
        
        % Process each channel
        for ch = 1:num_channels
            channel_data = img(:, :, ch);  % Extract channel
            
            % Apply 2D DWT on the entire channel to get approximation coefficients
            [cA, cH, cV, cD] = dwt2(channel_data, 'haar');
            
            % Store the compressed (downsampled) version of the channel
            compressed_image{ch} = cA;  % Store approximation coefficients
            compressed_size = compressed_size + numel(cA) * 8;  % Assume 8 bits per coefficient
        end
        
        % Calculate original size and compression ratio
        original_size = rows * cols * num_channels * 8;  % Assume 8 bits per pixel for grayscale, 24 bits for RGB
        compression_ratio = original_size / compressed_size;
        fprintf('Image %d Compression Ratio: %.2f\n', i, compression_ratio);
        
        % Decompress the image by upsampling the approximation coefficients
        decompressed_img = zeros(size(img));
        for ch = 1:num_channels
            cA = compressed_image{ch};
            
            % Define zero matrices for the missing detail coefficients
            [cH, cV, cD] = deal(zeros(size(cA)));
            
            % Reconstruct the full channel from approximation coefficients
            decompressed_img(:, :, ch) = idwt2(cA, cH, cV, cD, 'haar', [rows, cols]);
        end
        
        % Calculate PSNR
        mse = sum((img(:) - decompressed_img(:)).^2) / numel(img);
        max_pixel_value = 255;
        psnr = 10 * log10((max_pixel_value^2) / mse);
        fprintf('Image %d PSNR: %.2f dB\n', i, psnr);
        
        % Store results for this image
        compressed_images{i} = compressed_image;
        compressed_sizes(i) = compressed_size;
        compression_ratios(i) = compression_ratio;
        psnrs(i) = psnr;
        
        % Display original, compressed, and decompressed images for comparison
        figure;
        subplot(1, 3, 1); imshow(uint8(img)); title('Original Image');
        subplot(1, 3, 2); imshow(uint8(cell2mat(compressed_image))); title('Compressed Image');
        subplot(1, 3, 3); imshow(uint8(decompressed_img)); title('Decompressed Image');
    end
end
