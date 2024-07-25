# Combined-assembloid-and-3D-whole-organ-mapping-captures-the-microanatomy-of-the-human-fallopian-tube

The method CODA paper can be found here for more detailed explanation methods:

Kiemen, A.L., Braxton, A.M., Grahn, M.P. et al. CODA: quantitative 3D reconstruction of large tissues at cellular resolution. Nat Methods 19, 1490–1499 (2022). 
https://doi.org/10.1038/s41592-022-01650-9
Zenodo: https://zenodo.org/records/11130691

For a detailed protocol explanation, you can access the Kiemen Lab website:

https://labs.pathology.jhu.edu/kiemen/coda-3d/
Protocol: https://labs.pathology.jhu.edu/kiemen/wp-content/uploads/sites/39/2023/12/Instructions-for-applying-CODA.pdf

CODA works by serial sectioning and H&E staining any sample you want to study. To reconstruct the volume back from the serial sections and perform quantifications, we use 3 main computation methods:

Image registration
Allows the align all the images back into a 3D volume. 
To run the image registration, run code align_all_repeats.m. It will loop through all the conditions and repeats and align the images in 1x resolution. Then it will apply those transformation matrices to the high resolution 10x images. 

Inputs: 

- pth: path to folder with all conditions image sections. It should have a folder per condition

- nms: cell list of all name of conditions

-dt: date of the deep learning model
- scale: scale between 1.25x images and 10x images, in this case is 8. 
- cropim: cropim =1 when you want to crop the the images to speed up process and reduce memory/storage usage.
- padnum: when aligning the high resolution images, what's the padding value you want to add to the surrounding of the image (in this case label 3 is white space)
- redo: 1 if you want to redo all images, 0 if you dont want to re-align all images.


Deep learning segmentation
Labels all histological images with their anatomical labels.
To run the deep learning part of the code, run code make_training_deeplab_CODAorganoids.m. It will generate the training and validation datasets, train the deeplab CNN model, and segment the H&E images with the trained model. Note: to learn how to annotate the raw images, please look at the protocol above mentioned for a more detailed description.


Nuclei detection
Separates the Hematoxylin channel from the H&E images, and then proceeds to count the nuclei present in the single image channel.


 Quantifications
In this study, we highlighted specific metrics to compare our fallopian tube organoids to a whole human fallopian tube's ampulla. The metrics used for this comparison were: epithelial cell densities, stromal cell densities, epithelium volume, lumen volume, epithelium thickness, epithelium nucleus, and epithelium cytoplasm. For organoids that aim to replicate different anatomical components of other organs, other metrics can be added for more specific analysis.

Github repository: https://github.com/andreforjazz/Combined-assembloid-and-3D-whole-organ-mapping-captures-the-microanatomy-of-the-human-fallopian-tube

For additional questions, please contact: André Forjaz, aperei13@jhu.edu
