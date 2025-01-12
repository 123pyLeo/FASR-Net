# FASR-Net 

## The code will be released after the paper is accepted.

### Datasets

1. SRD 
2. AISTD|ISTD+ 

### Evaluation

#### Table 1: PSNR and RMSE Results on AISTD Dataset
| Learning paradigm | Method | Shadow Region (S) PSNR↑ | Shadow Region (S) RMSE↓ | Shadow-Free Region (NS) PSNR↑ | Shadow-Free Region (NS) RMSE↓ | All Image (ALL) PSNR↑ | All Image (ALL) RMSE↓ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Supervised | G2R-ShadowNet | 26.24 | 15.31 | 32.46 | 3.43 | 22.58 | 5.30 |
| Supervised | Param+M+D-Net | 30.99 | 10.50 | 34.70 | 3.74 | 26.58 | 4.81 |
| Supervised | Auto | 31.00 | 9.44 | 29.32 | 4.37 | 24.14 | 5.17 |
| Unsupervised | Mask-ShadowGAN | 29.37 | 12.50 | 31.65 | 4.00 | 24.57 | 5.30 |
| Unsupervised | S3R-Net | - | 12.16 | - | 6.38 | - | 7.12 |
| Unsupervised | DC-ShadowNet | 31.06 | 10.30 | 27.03 | 3.50 | 25.03 | 4.60 |
| Unsupervised | LG-ShadowNet | 30.32 | 10.35 | 32.53 | 4.03 | 25.53 | 5.03 |
| Unsupervised | FASR-Net(ours) | 31.89 | 8.61 | 34.57 | 2.84 | 27.58 | 3.75 |

#### Table 2: RMSE Results on SRD Dataset
| Learning | Method | S | NS | All |
| --- | --- | --- | --- | --- |
| SL | G2R-ShadowNet | 11.78 | 4.84 | 6.64 |
| SL | DSC | 8.62 | 4.41 | 5.71 |
| SL | BMNet | 6.61 | 3.61 | 4.46 |
| SL | Inpaint4Shadow | 6.09 | 2.97 | 3.83 |
| UL | Mask-ShadowGAN | 11.46 | 4.29 | 6.40 |
| UL | DC-ShadowNet | 7.73 | 3.60 | 4.77 |
| UL | FASR-Net(ours) | 7.45 | 3.49 | 4.62 |

#### Table 3: Ablation Study Results on AISTD Dataset
| Method | S | NS | All |
| --- | --- | --- | --- |
| FASR-Net | 31.89 | 34.57 | 27.58 |
| w/o $\mathcal{L}_{Align}$ | 30.82 | 34.36 | 26.76 |
| w/o $\mathcal{L}_{brightness-ch}$ | 30.21 | 34.00 | 26.19 |
| w/o $\mathcal{L}_{frequency}$ | 29.74 | 31.14 | 24.52 |
