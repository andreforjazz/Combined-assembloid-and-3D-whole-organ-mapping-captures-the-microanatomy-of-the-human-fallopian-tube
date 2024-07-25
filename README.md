# Combined Assembloid and 3D Whole Organ Mapping Captures the Microanatomy of the Human Fallopian Tube

## Introduction

This repository contains code and protocols for capturing the microanatomy of the human fallopian tube using combined assembloid and 3D whole organ mapping techniques.

## Method Details

### CODA Paper

For a more detailed explanation of the CODA method, refer to the following paper:

- Kiemen, A.L., Braxton, A.M., Grahn, M.P. et al. CODA: quantitative 3D reconstruction of large tissues at cellular resolution. Nat Methods 19, 1490–1499 (2022).
  - DOI: [10.1038/s41592-022-01650-9](https://doi.org/10.1038/s41592-022-01650-9)
  - Zenodo: [https://zenodo.org/records/11130691](https://zenodo.org/records/11130691)

### Detailed Protocol

For a detailed protocol explanation, you can access the Kiemen Lab website:

- [Kiemen Lab CODA-3D](https://labs.pathology.jhu.edu/kiemen/coda-3d/)
- Protocol PDF: [Instructions for Applying CODA](https://labs.pathology.jhu.edu/kiemen/wp-content/uploads/sites/39/2023/12/Instructions-for-applying-CODA.pdf)

### Overview of CODA

CODA operates by serial sectioning and H&E staining of the sample. The reconstruction of the volume from the serial sections and subsequent quantifications involve three main computational methods:

#### 1. Image Registration

This method aligns all the images back into a 3D volume.

To run the image registration, execute the `align_all_repeats.m` code. It loops through all conditions and repeats, aligning the images at 1x resolution, then applies the transformation matrices to the high-resolution 10x images.

**Inputs:**

- `pth`: Path to the folder with all condition image sections, with a folder per condition.
- `nms`: Cell list of all condition names.
- `dt`: Date of the deep learning model.
- `scale`: Scale between 1.25x images and 10x images (in this case, 8).
- `cropim`: Set to 1 to crop images for faster processing and reduced memory/storage usage.
- `padnum`: Padding value to add to the image's surrounding area (label 3 is white space in this case).
- `redo`: Set to 1 to redo all images, 0 to skip re-aligning all images.

#### 2. Deep Learning Segmentation

This method labels all histological images with their anatomical labels.

To run the deep learning part of the code, execute `make_training_deeplab_CODAorganoids.m`. This script generates training and validation datasets, trains the Deeplab CNN model, and segments the H&E images using the trained model. For raw image annotation details, refer to the protocol mentioned above.

#### 3. Nuclei Detection

This process separates the Hematoxylin channel from the H&E images and counts the nuclei present in the single image channel.

### Quantifications

This study highlights specific metrics to compare fallopian tube organoids to a whole human fallopian tube's ampulla, including:

- Epithelial cell densities
- Stromal cell densities
- Epithelium volume
- Lumen volume
- Epithelium thickness
- Epithelium nucleus
- Epithelium cytoplasm

For organoids replicating different anatomical components, additional metrics can be added for more specific analysis.

### Code Updates for CODA Organoids

The primary code for this study is based on the initial sources provided above. However, for this CODA organoids paper, some codes were updated and fine-tuned to facilitate the 3D mapping of human fallopian tube organoids.

### Zenodo Repository

The GitHub repository for this project can be found here: [https://zenodo.org/records/12820765]

### Contact

For additional questions, please contact: André Forjaz at [aperei13@jhu.edu](mailto:aperei13@jhu.edu).

