path(path,'\\169.254.138.20\Andre\codes\workflow codes\cell detection')
path(path,'\\169.254.138.20\Andre\codes\workflow codes\validation\cell detection')
path(path,'\\169.254.138.20\Andre\codes\workflow codes\validation\cell detection')


impth='\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\';

% file='organoids';
file='fallopian tube';

outpth=[impth,'mat files\',file,'\'];

%% automatic cell count
mosaicim=imread([outpth,'mosaic_cell_validation.tif']);

imhpth=[outpth,'fix stain\Hchannel\'];

if contains(file,'fallopian tube')
    HE_cell_count_FALLOPIANTUBE376(imhpth);
else
    HE_cell_count_organoids(imhpth);
end

%% manual cell count

cell_count_annotations_HE(outpth);

%%

if contains(file,'fallopian tube')
    load('\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\fallopian tube\mosaic_cell_validation.mat')
    load('\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\fallopian tube\fix stain\Hchannel\cell_coords\mosaic_cell_validation.mat')

    imhe= imread('\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\fallopian tube\mosaic_cell_validation.tif');
else
    load('\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\organoids\mosaic_cell_validation.mat')
    load('\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\organoids\fix stain\Hchannel\cell_coords\mosaic_cell_validation.mat')

    imhe= imread('\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\organoids\mosaic_cell_validation.tif');
end


xya=xy;
xym=ann;
dist=13;

[xmatch,xautnomatch,xmannomatch,xd]=cell_cell_dist(xya,xym,dist);

% true positive
disp(size(xmatch,1)/size(xym,1))

% falso positive
disp(size(xautnomatch,1)/size(xym,1))

% false negative
disp(size(xmannomatch,1)/size(xym,1))

figure(100),
imshow(imhe), hold on,
% scatter(xmatch(:,1),xmatch(:,2),'g','o'), hold on,
% scatter(xautnomatch(:,1),xautnomatch(:,2),'r','x'), hold on,
scatter(xmannomatch(:,1),xmannomatch(:,2),50,'r','x'), hold on,
scatter(ann(:,1),ann(:,2),'green','.'), hold on,
scatter(xy(:,1),xy(:,2),'blue','square')

