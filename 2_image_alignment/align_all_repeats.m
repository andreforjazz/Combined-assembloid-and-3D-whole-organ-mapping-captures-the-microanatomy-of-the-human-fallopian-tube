% path folder with all of your registration codes
path(path,'\\169.254.138.20\Andre\codes\workflow codes\register images\small_d_AF')

pth='\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\';

nms={'5k_2_mg','10k_2_mg','10k_2_mg_norm','10k_2_mg_Str','10k_4_mg','10k_6_mg','10k_6_mg_Str_B','10k_6_mg_Str_B2','standard'}; 

dt='4_4_2023';

% scale between 1.25x images and 10x images, in this case is 8
scale= 8;
% cropim =1 when you want to crop the the images to speed up process and
% reduce memory/storage use
cropim=0;
% when aligning the high resolution images, what's the padding value you
% want to add to the surrounding of the image (in this case label 3 is
% white space)
padnum=3;
% 1 if you want to redo all images, 0 if you dont want to 
redo=1;
%%

for kk=length(nms)

    nm=nms{kk}; disp(nm)
    
    % path images
    pth10x=[pth,nm,'\10x\'];
    repeatlist = dir([pth10x,'*sample*']);

    for ii=1: length(repeatlist)

        repeatnm=repeatlist(ii).name; disp(repeatnm)
        
        % path images
        pth10xrepeat=[pth,nm,'\10x\',repeatnm,'\'];
        pthim=[pth10xrepeat,'classification_',dt,'\'];
        pthdata=[pth10xrepeat,'registered\elastic registration\save_warps\'];
        
        % align low resolution images (we do 1x resolution typically)
        register_images_2023_organoids(pth10xrepeat);
        
        % use aligned transformation matrix to align high resolution
        % segmented images (we typically do 10x resolution images)
        save_images_elastic_smalld(pthim,pthdata,scale,cropim,padnum,redo);
    end
end

