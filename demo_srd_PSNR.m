clear;
tic

% Read test file names
fd = fopen('SRD.txt');
a = textscan(fd, '%s');
fclose(fd);
testfnlist = a{1};

fprintf('Starting evaluation. Total %d images\n', numel(testfnlist));

% Initialize PSNR arrays
total_psnr_l2 = zeros(1, numel(testfnlist));
total_psnr_l4 = zeros(1, numel(testfnlist));
total_psnr_l6 = zeros(1, numel(testfnlist));

parfor recovery_count = 1:numel(testfnlist)
    % Load images
    gt_recovery = imread(['shadow_free\' testfnlist{recovery_count}(1:end-4) '.jpg']);
    recovered_recovery = imread(['output\' testfnlist{recovery_count}(1:end-4) '.png']);
    m = imread(['mask\' testfnlist{recovery_count}(1:end-4) '.jpg']);
    
    % Resize recovered image if necessary
    if any(size(gt_recovery) ~= size(recovered_recovery))
        recovered_recovery = imresize(recovered_recovery, [size(gt_recovery, 1), size(gt_recovery, 2)]);
    end
    
    % Resize mask if necessary
    if size(m, 1) ~= size(gt_recovery, 1) || size(m, 2) ~= size(gt_recovery, 2)
        m = imresize(m, [size(gt_recovery, 1), size(gt_recovery, 2)]);
    end
    
    % Convert mask to grayscale if it's a color image
    if size(m, 3) == 3
        m = rgb2gray(m);
    end
    
    % Binarize the mask
    m = double(m ~= 0);
    
    % Calculate PSNR for different regions
    total_psnr_l2(recovery_count) = compute_psnr(gt_recovery, recovered_recovery, m); % Shadow region
    total_psnr_l4(recovery_count) = compute_psnr(gt_recovery, recovered_recovery, 1 - m); % Non-shadow region
    total_psnr_l6(recovery_count) = compute_psnr(gt_recovery, recovered_recovery, ones(size(m))); % Entire image
end

% Calculate mean PSNR values
psnr_12 = mean(total_psnr_l2);
psnr_14 = mean(total_psnr_l4);
psnr_16 = mean(total_psnr_l6);

% Print results
fprintf('Overall/%.2f/S/%.2f/NS/%.2f\n', psnr_12, psnr_14, psnr_16);
fprintf('Evaluation complete! Total %d images in %.2f mins\n', numel(testfnlist), toc/60);

% Function to compute PSNR given a mask
function psnr = compute_psnr(original, recovered, mask)
    original = double(original) .* mask;
    recovered = double(recovered) .* mask;
    
    mse = sum((original(:) - recovered(:)).^2) / sum(mask(:));
    
    if mse == 0
        psnr = Inf; % Perfect recovery
    else
        max_pixel = 255.0; % Assuming the pixel values range from 0 to 255
        psnr = 10 * log10(max_pixel^2 / mse);
    end
end
