
pth0='\\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\nucleus to cytoplasm\';

% organoid mosaic image
pthorg='\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\nucleus to cytoplasm\organoids\';
% fallopian tube mosaic image
% imorg=imread([pthfall,'fallopian_tube_mosaic_image.tif']);

pth='\\tugaserverdw\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\Annotations\';
% um/pixel of images used % 1=10x, 2=5x, 4=16x, % 100=do not scale
umpix=1; 
% path to tif images for model training
pthim='\\tugaserverdw\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\Annotations\10x_python\';

% scale from registration images to classified images (if classify 10x register 2.5x, scale=4)
scaleDLreg=1; 

timepoints={'5k_2_mg','10k_2_mg','10k_2_mg_norm','10k_2_mg_Str','10k_4_mg','10k_6_mg','10k_6_mg_Str_B','10k_6_mg_Str_B2','standard'};
% date of model trained
nm='4_4_2023';
pthDL=[pth,nm,'\'];

% define actions to take per annotation class
%   1           2       3    
%[epithelium  stroma  noise];
% define actions to take per annotation class
WS{1}=[0 2 2];      % remove whitespace if 0, keep only whitespace if 1, keep both if 2
WS{2}=3;                          % add removed whitespace to this class
WS{3}=[1 2 3];   % rename classes accoring to this order 
WS{4}=[2 1 3];  % reverse priority of classes
WS{5}=[];                         % delete classes
numclass=length(unique(WS{3}));
sxy=1000;
nblack=numclass+1;
nwhite=WS{3};nwhite=nwhite(WS{2});

% re-ordered class numbers (WS3 names)
     % r   g   b 
cmap=[067 023 150;...     % 1  epithelium   (purple)  
      242 167 227;...     % 2  whitespace   (white)
      255 255 255];...     % 3  collagen     (light pink)

titles = ["epithelium" "stroma" "whitespace"];
make_cmap_legend(cmap,titles);pause(0.05)

classNames = [titles "black"];
cmap2=cat(1,[0 0 0],cmap)/255;

% Initialize an empty cell array for the output
output = {};

% date for matfile names
dd=datetime("today");

% Define the titles as a cell array
titles = {'Condition','Total blue nuclei pixels','Total segmented epithelium pixels','Ratio nucleus/cytoplasm'};

%% Segment images

% deeplab_classification(pthorg,pthDL,sxy,nm,cmap,nblack,nwhite);

%% Analysis

imlist=dir([pthorg,'*.tif']);

for kk=1:length(imlist)
    
    nm0=imlist(kk).name; disp(nm0)
    
    outpth=[pthorg,'mat files\'];
    if ~exist(outpth,'dir');mkdir(outpth);end
    
    % output vol name
    outnm=[nm0(1:end-4),'.mat']; datafile=[outpth,outnm];

    pthclass=[pthorg,'classification_',nm,'\'];
    
    imhe=imread([pthorg,nm0]);
    imclass=imread([pthclass,nm0]);
    
    % blue = [0.6443 0.7166 0.2668];
    CVS=[0.644 0.717 0.267;0.093 0.954 0.283;0.636 0.001 0.771];

    % get blue pixels image channel
    [imout,imH,imE]=colordeconv2pw4_log10(imhe,"he",CVS);
    
    thresh=160;  
    imH_thresh = imH < thresh;
    % figure, imshow(imH_thresh);
    % figure, imshowpair(imclass==1, imH<160)
    
    % only consider locations with epithelium
    epi_segm=imclass==1;
    imH_epi= imH_thresh .* epi_segm;
   
    figure, imshowpair(imclass==1, imH_epi)

    % get blue pixels 
    total_blue_nucl=sum(imH_epi(:))

    % get sum of segmented epithelium 
    total_epi=sum(imclass(:)==1)

    % nucleus cytoplasm ratio
    ratio=total_blue_nucl/total_epi
    
    % Store the results in a cell array
    results = {total_blue_nucl,total_epi,ratio};

    % Convert the results to scientific notation using sprintf
    results = cellfun(@(x) sprintf('%0.3e', x), results, 'UniformOutput', false);

    % Append the results to the output cell array
    output = [output; {nm0},results];
    
    % prints values before saving them
    for i = 1:numel(results)
        fprintf('%s: %s \n', titles{i+1}, results{i})
    end
    
    save([datafile(1:end-4),'_results_FINAL.mat'],'thresh','imH_thresh','total_blue_nucl','total_epi','ratio','results');
    % close all;
end


%% Concatenate data and put into excel sheet


% Add the titles as the first row of the output cell array
output = [titles; output];

% mat files pth
matpth=[pth0,'mat files\'];if~exist(matpth,'dir');mkdir(matpth);end

% Write the output to a new Excel file called results_organoids_CODA.xlsx
xlswrite([matpth,'results_organoids_CODA.xlsx'], output);
% Open the Excel file and get the active sheet
excel = actxserver('Excel.Application');
workbook = excel.Workbooks.Open([matpth,'results_organoids_CODA.xlsx']);
sheet = workbook.ActiveSheet;
% Auto-fit the columns to make the cells fully visible
sheet.Columns.AutoFit;
% Save and close the workbook
workbook.Save;
workbook.Close;
excel.Quit;



