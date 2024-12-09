clear;
tic
fd = fopen('SRD.txt');
a = textscan(fd, '%s');
fclose(fd);
testfnlist = a{1};

fprintf('Starting evaluation. Total %d images\n', numel(testfnlist));

total_dist_l2 = zeros(1, numel(testfnlist));
total_dist_l4 = zeros(1, numel(testfnlist));
total_dist_l6 = zeros(1, numel(testfnlist));
total_pix_l2 = zeros(1, numel(testfnlist));
total_pix_l4 = zeros(1, numel(testfnlist));
total_pix_l6 = zeros(1, numel(testfnlist));

parfor recovery_count = 1 : numel(testfnlist)
    
    base_path = 'test\';
    
    gt_path = fullfile(base_path, 'shadow_free', [testfnlist{recovery_count}(1:end-4) '.jpg']);
    shadow_path = fullfile(base_path, 'shadow', [testfnlist{recovery_count}(1:end-4) '.jpg']);
    recovered_path = fullfile(base_path, 'SRD256', [testfnlist{recovery_count}(1:end-4) '.jpg']);
    mask_path = fullfile(base_path, 'mask', [testfnlist{recovery_count}(1:end-4) '.jpg']);
    
    if ~exist(gt_path, 'file') || ~exist(shadow_path, 'file') || ~exist(recovered_path, 'file') || ~exist(mask_path, 'file')
        fprintf('File(s) missing for %s, skipping...\n', testfnlist{recovery_count});
        continue;
    end
    
    % Methods by Guo
    gt_recovery = imread(gt_path);
    shadow_recovery = imread(shadow_path);
    recovered_recovery = imread(recovered_path);
    m = imread(mask_path);
    
    if numel(size(m)) == 3
        m = rgb2gray(m);
    end
    
    m(m~=0) = 1;
    m = double(m);
    
    mask_recovery = m;
    mask2_recovery = 1 - m;
    
    % for the overall regions
    [total_dist_l2(1, recovery_count), ...
     total_pix_l2(1, recovery_count), ...
     total_dist_l4(1, recovery_count), ...
     total_pix_l4(1, recovery_count), ...
     total_dist_l6(1, recovery_count), ...
     total_pix_l6(1, recovery_count)] = evaluate_recovery(gt_recovery, ...
                                                          recovered_recovery, ...
                                                          NaN*ones(size(gt_recovery)),...
                                                          mask_recovery, ...
                                                          mask2_recovery);
end

dist_12 = sum(total_dist_l2(:)) / sum(total_pix_l2(:));
dist_14 = sum(total_dist_l4(:)) / sum(total_pix_l4(:));
dist_16 = sum(total_dist_l6(:)) / sum(total_pix_l6(:));

fprintf('%s/%.2f/%s/%.2f/%s/%.2f\n', 'Overall', dist_12, 'S', dist_14, 'NS', dist_16);
fprintf('Evaluation complete! Total %d images in %.2f mins\n', numel(testfnlist), toc / 60);
