% Read the original image
originalImage = imread('sp.jpg'); % Replace 'image.jpg' with your image file

% Convert to grayscale if the image is in color
if size(originalImage, 3) == 3
    originalImage = rgb2gray(originalImage);
end

% Add Gaussian noise to the image
noisyImage = imnoise(originalImage, 'gaussian', 0, 0.01);

% Display the original and noisy images
figure;
subplot(1, 2, 1);
imshow(originalImage);
title('Original Image');

subplot(1, 2, 2);
imshow(noisyImage);
title('Noisy Image');

% Perform wavelet decomposition
waveletName = 'db1'; % Daubechies wavelet
[coeffs, S] = wavedec2(noisyImage, 2, waveletName);

% Thresholding
threshold = wthrmngr('dw2ddenoLVL', 'penalhi', coeffs, S, 3);
denoisedCoeffs = wthcoef2('h', coeffs, S, 2, threshold);
denoisedCoeffs = wthcoef2('v', denoisedCoeffs, S, 2, threshold);
denoisedCoeffs = wthcoef2('d', denoisedCoeffs, S, 2, threshold);

% Reconstruct the image using the denoised wavelet coefficients
denoisedImage = waverec2(denoisedCoeffs, S, waveletName);

% Display the denoised image
figure;
imshow(denoisedImage, []);
title('Denoised Image');

% Compare the images
figure;
subplot(1, 3, 1);
imshow(originalImage);
title('Original Image');

subplot(1, 3, 2);
imshow(noisyImage);
title('Noisy Image');

subplot(1, 3, 3);
imshow(denoisedImage, []);
title('Denoised Image');