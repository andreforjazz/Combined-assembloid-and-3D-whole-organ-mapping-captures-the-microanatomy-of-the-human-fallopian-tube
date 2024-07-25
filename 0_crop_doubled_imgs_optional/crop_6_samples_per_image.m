pth='\\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\';

nms={'5k_2_mg','10k_2_mg','10k_2_mg_norm','10k_2_mg_Str','10k_4_mg','10k_6_mg','10k_6_mg_Str_B','10k_6_mg_Str_B2'}; 

% CHANGE SAMPLE HERE
nm=nms{5}; disp(nm)

% path images
pth1x=[pth,nm,'\1x\'];
pth10x=[pth,nm,'\10x\'];

% select the condition repeat you want to crop individually
lt=['A','B','C','D','E'];

% output paths
outpth1x=[pth1x,'sample_',lt,'\'];
outpth10x=[pth10x,'sample_',lt,'\'];

% Get a list of all the TIFF images in the input folder
imlist = dir([pth1x,'*.tif']);

disp(outpth1x)

outpthmat1x=[outpth1x,'mat_crop_regions\'];
outpthmat10x=[outpth10x,'mat_crop_regions\'];

% Find the middle index of the image list
middleIndex = ceil(length(imlist)/2); disp(middleIndex)

%% Loop through each TIFF file
for kk = middleIndex+1: length(imlist) % middleIndex+1
    

    % Get the filename and full path of the current TIFF file
    filename = imlist(kk).name; disp(filename)
    
    % Read the image from the file
    img1x = imread([pth1x,filename]);
    img10x = imread([pth10x,filename]);
    
    % Display the image so the user can crop a region manually
    figure(1111);
    imshow(img1x);
    title(['Select region to crop from ', filename]);
    rr1 = round(getrect()); % Let user select the region to crop
    
    % Crop the selected region from the image
    crop1_1x = imcrop(img1x, rr1);
    
%     figure, imshow(crop1_1x)

    rr1_10x=rr1*8;
    crop1_10x = imcrop(img10x, rr1_10x);
    
    if ~exist(outpth1x, 'dir')
    mkdir(outpth1x);
    end
    if ~exist(outpth10x, 'dir')
        mkdir(outpth10x);
    end
    % Save the two cropped regions under different names
    imwrite(crop1_1x,[outpth1x,filename(1:end-4),'.tif']);
    imwrite(crop1_10x,[outpth10x,filename(1:end-4),'.tif']);
    
    if ~exist(outpthmat1x, 'dir')
    mkdir(outpthmat1x);
    end
    if ~exist(outpthmat10x, 'dir')
        mkdir(outpthmat10x);
    end

    % save mat files with rr
    save([outpthmat1x,filename(1:end-4),'.mat'],"rr1");
    save([outpthmat10x,filename(1:end-4),'.mat'],"rr1_10x");
end
