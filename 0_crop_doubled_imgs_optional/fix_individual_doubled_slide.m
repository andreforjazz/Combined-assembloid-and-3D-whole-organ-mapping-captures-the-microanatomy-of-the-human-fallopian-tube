
% inputs
path(path,'\\tugaserverdw\Andre\codes\workflow codes\analyses')


pth='\\tugaserverdw\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\';

nms={'5k_2_mg','10k_2_mg','10k_2_mg_norm','10k_2_mg_Str','10k_4_mg','10k_6_mg','10k_6_mg_Str_B','10k_6_mg_Str_B2'}; 

% CHANGE SAMPLE HERE
nm=nms{8}; disp(nm)

pth1x=[pth,nm,'\1x\'];
pth10x=[pth,nm,'\10x\'];

% change slide here
numb='_083';

file=[nm,numb,'.tif'];

disp(file)

outpth1x=[pth1x,'backup\'];
outpth10x=[pth10x,'backup\'];

outpthmat1x=[outpth1x,'mat_crop_regions\'];
outpthmat10x=[outpth10x,'mat_crop_regions\'];

%%
% Load the image
img1x = imread([pth1x,file]);
img10x = imread([pth10x,file]);

% Display the image and let the user select the regions of interest
imshow(img1x);
title('Select region 1');
rr1 = round(getrect());
title('Select region 2');
rr2 = round(getrect());
title('Select region 3');
rr3 = round(getrect());

close 
% Crop the two regions from the image
crop1_1x = imcrop(img1x, rr1);
crop2_1x = imcrop(img1x, rr2);
crop3_1x = imcrop(img1x, rr3);

rr1_10x=rr1*8;
rr2_10x=rr2*8;
rr3_10x=rr3*8;

% Crop the two regions from the image
crop1_10x = imcrop(img10x, rr1_10x);
crop2_10x = imcrop(img10x, rr2_10x);
crop3_10x = imcrop(img10x, rr3_10x);

% Save the two cropped regions under different names
imwrite(crop1_1x,[pth1x,file(1:end-4),'_a.tif']);
imwrite(crop2_1x, [pth1x,file(1:end-4),'_b.tif']);
imwrite(crop3_1x, [pth1x,file(1:end-4),'_c.tif']);

imwrite(crop1_10x,[pth10x,file(1:end-4),'_a.tif']);
imwrite(crop2_10x, [pth10x,file(1:end-4),'_b.tif']);
imwrite(crop3_10x, [pth10x,file(1:end-4),'_c.tif']);

% Create the destination folder (if it doesn't exist)
if ~exist(outpth1x, 'dir')
    mkdir(outpth1x);
end
% Create the destination folder (if it doesn't exist)
if ~exist(outpth10x, 'dir')
    mkdir(outpth10x);
end

% Move the loaded image to the destination folder
movefile([pth1x,file], [outpth1x,file]);
movefile([pth10x,file], [outpth10x,file]);

if ~exist(outpthmat1x, 'dir')
    mkdir(outpthmat1x);
end
if ~exist(outpthmat10x, 'dir')
    mkdir(outpthmat10x);
end
%save mat files with rr
% save([outpthmat1x,file(1:end-4),'.mat'],"rr1","rr2")
save([outpthmat1x,file(1:end-4),'.mat'],"rr1","rr2","rr3")

% save([outpthmat10x,file(1:end-4),'.mat'],"rr1_10x","rr2_10x")
save([outpthmat10x,file(1:end-4),'.mat'],"rr1_10x","rr2_10x","rr3_10x")

