import os
import warnings
import numpy as np
from skimage import io, img_as_float, color
from skimage.metrics import peak_signal_noise_ratio as psnr
from skimage.transform import resize

# Calculate PSNR only within the masked region
def calculate_psnr(img1, img2, mask):
    img1_masked = img1 * mask
    img2_masked = img2 * mask
    psnr_value = psnr(img1_masked, img2_masked, data_range=img2_masked.max() - img2_masked.min())
    return psnr_value

# Process the folders to calculate PSNR values
def process_folders(folder1, folder2, mask_folder):
    results = []
    target_size = (256, 256)

    # Get all file names in the folder and only process image files
    files1 = sorted([f for f in os.listdir(folder1) if f.lower().endswith(('png', 'jpg', 'jpeg', 'bmp', 'tif', 'tiff'))])

    for file1 in files1:
        img1_path = os.path.join(folder1, file1)
        img1 = img_as_float(io.imread(img1_path))

        # Convert to grayscale
        if len(img1.shape) == 3:
            img1 = color.rgb2gray(img1)

        # Resize the image
        img1 = resize(img1, target_size, anti_aliasing=True)

        # Find the corresponding file name in folder2
        file2_name = file1.split('.')[0] + '.png'
        img2_path = os.path.join(folder2, file2_name)

        if not os.path.exists(img2_path):
            warnings.warn(f"{file1} corresponding {file2_name} file not found, skipping.")
            continue

        img2 = img_as_float(io.imread(img2_path))

        # Convert to grayscale
        if len(img2.shape) == 3:
            img2 = color.rgb2gray(img2)

        # Resize the image
        img2 = resize(img2, target_size, anti_aliasing=True)

        # Read the mask image
        mask_name = file1.split('.')[0] + '.png'
        mask_path = os.path.join(mask_folder, mask_name)

        if not os.path.exists(mask_path):
            warnings.warn(f"{file1} corresponding mask file {mask_name} not found, skipping.")
            continue

        mask = img_as_float(io.imread(mask_path))

        # If the mask is in color, convert it to grayscale
        if len(mask.shape) == 3:
            mask = color.rgb2gray(mask)

        # Resize the mask
        mask = resize(mask, target_size, anti_aliasing=True)

        # Binarize the mask
        mask[mask!= 0] = 1

        try:
            psnr_shadow = calculate_psnr(img1, img2, mask)
            psnr_non_shadow = calculate_psnr(img1, img2, 1 - mask)
            psnr_overall = calculate_psnr(img1, img2, np.ones_like(mask))
            results.append((file1, psnr_shadow, psnr_non_shadow, psnr_overall))
        except ValueError as e:
            warnings.warn(f"{file1} and {file2_name} skipped: {e}")

    return results

# Calculate the average PSNR values
def calculate_average_psnr(results):
    psnr_shadow_values = [psnr_shadow for _, psnr_shadow, _, _ in results]
    psnr_non_shadow_values = [psnr_non_shadow for _, _, psnr_non_shadow, _ in results]
    psnr_overall_values = [psnr_overall for _, _, _, psnr_overall in results]

    average_psnr_shadow = np.mean(psnr_shadow_values) if psnr_shadow_values else 0
    average_psnr_non_shadow = np.mean(psnr_non_shadow_values) if psnr_non_shadow_values else 0
    average_psnr_overall = np.mean(psnr_overall_values) if psnr_overall_values else 0

    return average_psnr_shadow, average_psnr_non_shadow, average_psnr_overall

# Example usage
folder1 = ''
folder2 = 'test_C'
mask_folder = 'test_B'

if __name__ == "__main__":
    results = process_folders(folder1, folder2, mask_folder)
    for filename, psnr_shadow, psnr_non_shadow, psnr_overall in results:
        print(f'{filename} - Shadow PSNR: {psnr_shadow}, Non-Shadow PSNR: {psnr_non_shadow}, Overall PSNR: {psnr_overall}')

    average_psnr_shadow, average_psnr_non_shadow, average_psnr_overall = calculate_average_psnr(results)
    print(f'Average Shadow PSNR: {average_psnr_shadow}')
    print(f'Average Non-Shadow PSNR: {average_psnr_non_shadow}')
    print(f'Average Overall PSNR: {average_psnr_overall}')