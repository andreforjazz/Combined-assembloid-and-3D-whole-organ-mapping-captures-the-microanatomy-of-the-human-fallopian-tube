function [im0,TA,outpth]=calculate_tissue_space_organoids(pth,imnm)
% creates logical image with tissue area

outpth=[pth,'TA\'];
if ~isfolder(outpth);mkdir(outpth);end

try im0=imread([pth,imnm,'.tif']);
catch
    try im0=imread([pth,imnm,'.jp2']);
    catch
        im0=imread([pth,imnm,'.jpg']);
    end
end
if exist([outpth,imnm,'.tif'],'file')
    TA=imread([outpth,imnm,'.tif']);
    return;
end

% im=double(imgaussfilt(im0,1));
% TA=std(im,[],3);
% TA=TA>8;
% TA=bwareaopen(TA,9);
im=double(im0);

im1xg=imgaussfilt(double(im),2);

% get dark objects
ima=im(:,:,2);
% TA=ima<230;
TA=ima<215;

% remove black objects
imb=std(im1xg,[],3);
imc=abs(double(im(:,:,1))-double(im(:,:,2)));
TA=TA & imc>7;
TA=imclose(TA,strel('disk',4));
TA=bwareaopen(TA,500);
TA=imclose(TA,strel('disk',2));
% TA=imclose(TA,strel('disk',10));
TA=imdilate(TA,strel('disk',1));
TA=imfill(TA,'holes');
% figure(12),imshowpair(im0,TA);axis equal;axis off
imwrite(TA,[outpth,imnm,'.tif']);

