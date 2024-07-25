path(path,'\\169.254.138.20\Andre\codes\workflow codes\cell detection')
path(path,'\\169.254.138.20\Andre\codes\PDAC purity\Pre_and_post_analysis\auxiliary_functions')
path(path,'\\169.254.138.20\Andre\codes\PDAC purity\validate images')

impth='\\169.254.138.20\Andre\data\PDAC Purity Project\PDAC PURITY Final Analysis\LCM_technical_assessment\';

outpth=[impth,'mat files\'];
if ~exist(outpth,'dir');mkdir(outpth);end

imlist=dir([impth,'*tif']);

sz=250;

%% get locations on each image

for kk=1:length(imlist)

    nm=imlist(kk).name; disp(nm)

    % load image
    im=imread([impth,nm]);

    % select cropping location of image
%     figure,[~,rr]=imcrop(im);
    figure(100),imshow(im),[xcrop,ycrop] = ginput(1);

    % cropping location of image
    cropped_im = imcrop(im, [xcrop-sz ycrop-sz sz*2-1 sz*2-1]);
    
    % Display cropped image with selected point in the middle
    figure(111), imshow(cropped_im);
    hold on;
    marker = insertMarker(cropped_im, [sz, sz], 'x', 'color', 'red', 'size', 10);
    imshow(marker);
    hold off;

    % save mat file with cropping location 'rr' and respective image name
    save([outpth,nm(1:end-4),'.mat'], "xcrop","ycrop","cropped_im","sz");
    
end


%% Load 10 image tiles and combined them into one tiled image

% Define the number of rows and columns for the montage
num_rows = 2;
num_cols = 5;

% Initialize an empty cell array to store the images
% image_stack = [];
% images = cell(1, length(imlist));
images=[];
for kk=1:length(imlist)

    nm=imlist(kk).name; disp(nm)

    im=load([outpth,nm(1:end-4),'.mat'], "cropped_im");
%     images=[images; cropped_im(:)];
    images = cat(4, images, im.cropped_im); % Append the image to the end of the array along the fourth dimension

end

figure, mosaic=montage(images, 'Size', [num_rows, num_cols]);

imwrite(mosaic.CData,[outpth,'mosaic_cell_validation.tif'], 'Compression', 'none');

%% Do cell count on tiled image

% mosaicim=imread([outpth,'mosaic_cell_validation.tif']);

% normalize
normalize_HE(outpth)
% save x and y coordinates of detected cells in tiled image
HE_cell_count([outpth,'fix stain\Hchannel\']);





