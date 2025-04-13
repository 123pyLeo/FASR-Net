# Shadow_Brightness-Chromaticity

## Introduction
The shadow-free chromaticity loss function in DC-Shadownet becomes lesseffective at creating a shadow-free map when angular hardshadows from a point light source blend with the background.We introduce a brightness-chromaticity loss to enhanceshadow region identifcation by utilizing the LAB space toseparate color and luminance components. In the LAB space.shadows appear darker in the L channel and more prominentin the B channel due to their absorption of warm light.

## Technical Principles

### 1. LAB Color Space Transformation
The LAB color space is a perceptually uniform color space that separates the brightness information from the color information:
- **L channel**: Represents the luminance, ranging from 0 (black) to 100 (white).
- **A channel**: Represents the axis from green to red.
- **B channel**: Represents the axis from blue to yellow.

### 2. Local Brightness Equalization Processing
Local brightness equalization is a key step, and the specific implementation is as follows:
- **Sliding window technique**: The algorithm uses a fixed-size window (in the code, r = 1 corresponds to a 3×3 pixel area) to slide over the image, and processes each window position.
- **Local-global equalization**: Calculate the average brightness and chromaticity values of each local window area, and compare them with the global average values of the entire image. The calculation of these means is a basic operation in statistical analysis.
- **Selective adjustment**: Only adjust the L channel (brightness) and the B channel (blue-yellow chromaticity), and keep the A channel (green-red chromaticity) unchanged. This is based on the observation that shadows usually have a more obvious impact on these two channels.
- **Difference correction**: Apply the difference between the local average value and the global average value to each pixel in the window, so that the brightness level of the shadow area is close to that of the non-shadow area. It can be expressed by the formula: pixel_new = pixel_original - local_average + global_average.

### 3. Chromaticity Projection Analysis
Chromaticity projection analysis is the core innovative part of this algorithm:
- **Logarithmic chromaticity transformation**: Convert the RGB values into the logarithmic chromaticity space. This transformation makes the chromaticity proportional relationship more linear, facilitating subsequent processing.
```
a = log(blue/geo_mean - 1)
b = log(green/geo_mean - 1)
c = log(red/geo_mean - 1)
```
where geo_mean is the geometric mean of RGB. After the logarithmic transformation, the distribution characteristics of the data are more in line with the requirements of statistical analysis, which helps to use statistical tools for in-depth processing later.
- **Projection matrix construction**: Construct a special projection matrix U to project the chromaticity space into a two-dimensional space. This matrix contains important characteristics of the chromaticity relationship.
```
U = [[1/√2, -1/√2, 0], [1/√6, 1/√6, -2/√6]]
```
- **Angle scanning technique**: The algorithm scans within the range of 0 - 180 degrees and calculates the chromaticity projection for each angle.
```
e_t = [cos(θ), sin(θ)]
Y = chi · e_t    (chi is the chromaticity value projected through the U matrix)
```

### 4. Entropy Minimization Strategy
Entropy minimization is the key to identifying the optimal projection angle:
- **Normal distribution fitting**: Fit the chromaticity distribution of each projection angle to a normal distribution, and calculate the mean and standard deviation. This is based on the statistical premise of the algorithm that the chromaticity distribution of the area without shadow influence in the image should be approximately normally distributed. Through normal distribution fitting, we can better describe the data characteristics from a statistical perspective.
- **Confidence interval filtering**: Use statistical methods to calculate the 90% confidence interval and remove outliers. Use the t-distribution and chi-square distribution to calculate the confidence intervals of the mean and variance to ensure the reliability of the data. This is an important application of statistics in the algorithm.
- **Adaptive bandwidth calculation**: Use the formula `bw = (3.5 * std) * (n^(-1/3))` to calculate the optimal histogram bandwidth. This involves the selection of the bandwidth in kernel density estimation, which belongs to the category of non-parametric density estimation. By reasonably selecting the bandwidth, we can more accurately estimate the distribution of the data.
- **Entropy calculation**: Calculate the Shannon entropy for the filtered data.
```
entropy = -sum(p * log2(p))   (p is the normalized histogram distribution)
```
- **Minimum entropy angle**: Find the angle with the minimum entropy value. This corresponds to the direction where the chromaticity distribution is the most concentrated, that is, the direction least affected by shadows. Using the Shannon entropy as a measure of the concentration of the chromaticity distribution provides a quantitative standard for determining the optimal projection angle from a statistical sense.

### 5. Image Reconstruction Technology
Based on the optimal projection angle, the algorithm performs the following reconstruction steps:
- **Orthogonal projection construction**: Use the found optimal angle to construct the projection vector.
```
e = [-sin(θ), cos(θ)]
e_t = [cos(θ), sin(θ)]
```
- **Projection matrix calculation**: Calculate the projection matrix `P_theta = (e_t · e_t^T) / ||e||`.
- **Chromaticity reconstruction**: Apply the projection matrix to the original chromaticity data.
```
chi_theta = chi · P_theta
rho_estim = chi_theta · U
```
- **Exponential transformation and normalization**: Restore the RGB color space through exponential transformation and normalization.
```
mean_estim = exp(rho_estim)
estim = mean_estim / sum(mean_estim, axis=2)
``` 