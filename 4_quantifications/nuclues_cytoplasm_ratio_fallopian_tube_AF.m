
pthfall='\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\nucleus to cytoplasm\fallopian tube\';
% fallopian tube mosaic image
% imfall=imread([pthfall,'fallopian_tube_mosaic_image.tif']);
pth0='\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\validation cell detection\mat files\nucleus to cytoplasm\';

pth='\\10.162.80.16\Andre\data\Ashleigh fallopian tube\fallopian tubes\files\Annotations_combined\';
% um/pixel of images used % 1=10x, 2=5x, 4=16x, % 100=do not scale
umpix=1; 

% scale from registration images to classified images (if classify 10x register 2.5x, scale=4)
scaleDLreg=1; 

% date of model trained
nm='1_19_2023';
pthDL=[pth,nm,'\'];

% define actions to take per annotation class
%      1          2       3         4       5            6         7            8                  9              10 
% [epithelium  stroma  whitespace  noise  vasculature  nerve  steroidnest  reti_ovarii  adenofibromatous growth  fat]
% define actions to take per annotation class
WS{1}=[0 0 2 2 0 0 0 0 0 2];      % remove whitespace if 0, keep only whitespace if 1, keep both if 2
WS{2}=3;                    % add removed whitespace to this class
WS{3}=[1 2 3 3 4 5 6 7 8 9];      % rename classes accoring to this order 
WS{4}=[2 5 6 7 8 9 10 1 3 4];  % reverse priority of classes (bottom to top)
WS{5}= [];                                   % delete classes
numclass=length(unique(WS{3}));
sxy=1000;
nblack=numclass+1;
nwhite=WS{3};nwhite=nwhite(WS{2});

cmap=[247 184 067;... % 1  epithelium  (orange)
      244 222 245;... % 2  stroma  (pink)
      255 255 255;... % 3  whitespace  (white)
      140 013 013;... % 4  blood vessels  (red)
      150 215 150;... % 5  nerve  (green)
      157 136 206;... % 6  steroidnest  (purple)
      254 119 001;... % 7  reti_ovarii  (orange)
      177 207 232;... % 8  adenofibromatous_growth  (light blue)
      245 245 151];   % 9  fat  (yellow)

titles = ["epithelium" "stroma" "white" "vasculature" "nerve" "steroidnest"  "reti_ovarii"  "adenofibromatous_growth"  "fat"];
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

% deeplab_classification(pthfall,pthDL,sxy,nm,cmap,nblack,nwhite);

%% Analysis

imlist=dir([pthfall,'*.tif']);

for kk=1:length(imlist)
    
    nm0=imlist(kk).name; disp(nm0)
    
    outpth=[pthfall,'mat files\'];
    if ~exist(outpth,'dir');mkdir(outpth);end
    
    % output vol name
    outnm=[nm0(1:end-4),'.mat']; datafile=[outpth,outnm];

    pthclass=[pthfall,'classification_',nm,'\'];
    
    imhe=imread([pthfall,nm0]);
    imclass=imread([pthclass,nm0]);
    
    % blue = [0.6443 0.7166 0.2668];
    CVS=[0.644 0.717 0.267;0.093 0.954 0.283;0.636 0.001 0.771];

    % get blue pixels image channel
    [imout,imH,imE]=colordeconv2pw4_log10(imhe,"he",CVS);
    
    thresh=170;  
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
xlswrite([matpth,'results_fallopian_tube_CODA.xlsx'], output);
% Open the Excel file and get the active sheet
excel = actxserver('Excel.Application');
workbook = excel.Workbooks.Open([matpth,'results_fallopian_tube_CODA.xlsx']);
sheet = workbook.ActiveSheet;
% Auto-fit the columns to make the cells fully visible
sheet.Columns.AutoFit;
% Save and close the workbook
workbook.Save;
workbook.Close;
excel.Quit;



