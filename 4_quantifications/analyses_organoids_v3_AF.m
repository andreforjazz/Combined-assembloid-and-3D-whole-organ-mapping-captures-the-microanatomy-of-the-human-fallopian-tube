% cmap=[067 023 150;...     % 1  epithelium   (purple)  
%       242 167 227;...     % 2  collagen     (light pink)
%       255 255 255];...     % 3  whitespace  (white)

%% inputs
path(path,'\\10.162.80.16\andre\codes\workflow codes\cnn_training_classification')
path(path,'\\10.162.80.16\Andre\codes\workflow codes\plots_3D');
path(path,'\\10.162.80.16\andre\codes\Bart Bi-specific');
path(path,'\\10.162.80.16\Andre\codes\workflow codes\analyses');

nms={'5k_2_mg','10k_2_mg','10k_2_mg_norm','10k_2_mg_Str','10k_4_mg','10k_6_mg','10k_6_mg_Str_B','10k_6_mg_Str_B2','standard'}; 
d= 150; % distance from met in micron

% downsampling the volume to 4 micron xy (4x4x4 micron to do bwdist)
sk=4; 

% date for matfile names
dd=datetime("today");

pth0='\\169.254.138.20\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\';

% date of DL model
dtm='4_4_2023'; % dtm='09_13_2022'; old plots of fallopian 1

% Define the titles as a cell array
titles = {'Condition','Repeat','Epithelium cell density','Stromal cell density','Volume Epithelium (mm3)','Volume Lumen (mm3)','ratio Epithelium/Lumen','Thickness Epithelium (um)'};

% Initialize an empty cell array for the output
output = {};

% redo quantifications if redo=1 
redo=1;

%%
for kk=1:length(nms)
    nm0=nms{kk};disp(nm0)
     
    pthrepeats=[pth0,nm0,'\10x\'];
    repeatlist=dir([pthrepeats,'*sample*']);

    for lol=1:length(repeatlist)
        
        nm=[nm0,'_',repeatlist(lol).name,'_',dtm];disp(nm)
        
        outpth=[pth0,'mat files\',nm0,'\'];
        if ~exist(outpth,'dir');mkdir(outpth);end
        
        % output vol name
        outnm=[nm,'.mat']; datafile=[outpth,outnm];

%         load([outpth,nm,'.mat'],'vol','volcell','cmap','mask','mask_ampulla');
%         load(datafile,'vol');
        load(datafile,'volFINAL');
        vol=volFINAL;

        %% SMOOTH AND DOWNSAMPLE 
        if exist([datafile(1:end-4),'_stats_epi_str.mat'],'file') && redo==0
            load([datafile(1:end-4),'_stats_epi_str.mat'],'stats_str','stats_epi','volsmooth','sxysz_smooth','vol1','sxysz','sk');
        else
            % epithelium 
            vol1=vol==1;
            vol1=bwareaopen(vol1,100);
            vol1=imclose(vol1,strel('sphere',1));
            vol1=bwareaopen(vol1,2000);
%             % STOP HERE IF NEEDED TO FIX EPI CLASSIFICATION
%             tmp=sum(vol1,3);tmp=tmp/max(tmp(:));
%             figure(100), imagesc(tmp);
%             mask_epi=freeform_annotation_AP(tmp); % annotate tube region
%             vol1=double(vol1).*mask_epi;
            vol1=vol1(1:sk:end,1:sk:end,:);  % 4 x 4 x 4 micron
        
            % add stroma
            vol2=vol==2;
            vol2=vol2(1:sk:end,1:sk:end,:);  % 4 x 4 x 4 micron
        
            % downsampled volume containing epithelium and stroma
            vol1=double(vol1);
            vol1(vol2==1)=2;   % 4 x 4 x 4 micron (stroma)
        
            sxysz=[1*sk,1*sk,4];
        %     clearvars vol2 
        
        %% CROP OUT WHITESPACE AND VOLSHOW
        
            % 1 - epithelium
            % 2 - stroma
            % remove noise with manual mask
            volEPall=vol1==1; % epithelium
            tmp=sum(volEPall==1,3);tmp=tmp/max(tmp(:));figure, imagesc(tmp)
        %     mask=freeform_annotation_AP(tmp); % annotate tube region
    %         volEPall=volEPall.*mask;
            
        %     save(datafile,'mask','-append'); %'vol','cmap','rr','sxz','titles','sk');
        
            volStrall=vol1==2; % Stroma
            % remove small noise stroma
            volStrall=bwareaopen(volStrall,2000);
            
            volsmooth=double(volEPall); % epithelium
            volsmooth(volStrall==1)=2; % stroma
        
            A=eye(4);A=A.*[1*sk;1*sk;15;1];A=affinetform3d(A);
            viewer = viewer3d(BackgroundColor="white",GradientColor=[0.5 0.5 0.5]);
            volshow(volsmooth==1, Colormap=[067 023 150]/255,Transformation=A,Parent=viewer);
            volshow(volsmooth==2, Colormap=[242 167 227]/255,Transformation=A,Parent=viewer);
            
            sxysz_smooth=[1*sk,1*sk,4];    
        %% 1 -CALCULATE THICKNESS AND SURFACE AREA OF EPITHELIUM
        
        
            % stats epithelium
            stats_epi = regionprops3(volsmooth==1,'all');
            
            % stats stroma
            stats_str = regionprops3(volsmooth==2,'all');

            % save stats
            save([datafile(1:end-4),'_stats_epi_str.mat'],'stats_str','stats_epi','volsmooth','sxysz_smooth','vol1','sxysz','sk');
        end
    
        [val,idE]=max(stats_epi.Volume);
        [val,idBV]=max(stats_str.Volume);
        % get surface areas
        surf_epi = stats_epi.SurfaceArea(idE);
        surf_str = stats_str.SurfaceArea(idBV);
        vol_epi = stats_epi.Volume(idE);
        vol_str = stats_str.Volume(idBV);
        % get solidity
        solidity_epi = stats_epi.Solidity(idE);
        solidity_str = stats_str.Solidity(idBV);
        
        % get thickness - CHECK THIS
        thick_epi=vol_epi/surf_epi*4  % change unit of voxel distance to micron
        thick_str=vol_str/surf_str*4;
        
        %% Ratio epithelium walls vs Volume lumen - MASK OUT JUST THE EPITHELIUM OF THE AMPULLA
        %% get fill of lumen of tube side of fallopian tube
        if exist([datafile(1:end-4),'_volEP_lumen.mat'],'file') && redo==0
            load([datafile(1:end-4),'_volEP_lumen.mat'],'volEP','volEPlumen'); 
        else
            % get filled lumen of tube region of fallopian tube
            % volEP=vol1==2;
            volEP=volsmooth==1;
            tmp=sum(volEP==1,3);tmp=tmp/max(tmp(:)); figure, imagesc(sum(tmp,3))
            
            volEPlumen=imclose(volEP,strel('sphere',3));
            for z=1:size(volEPlumen,3)
                tmp=volEPlumen(:,:,z);
                tmp=imdilate(tmp,strel('disk',2));
                tmp=imfill(tmp,'holes');
                volEPlumen(:,:,z)=tmp;
%                 disp([z size(volEPlumen,3)]);
            end
            volEPlumen=volEPlumen.*(vol1~=1).*(vol1~=2);
            figure;imshowpair(volEP(:,:,round(size(volEP,3)/2)),volEPlumen(:,:,round(size(volEP,3)/2)))
    
            save([datafile(1:end-4),'_volEP_lumen.mat'],'volEP','volEPlumen'); 
        end
    
        % get ratio between volume epithelium and volume lumen 
        ratio_EP_lumen= sum(volEP(:))/ sum(volEPlumen(:))
            
        volEPlumenMM=sum(volEPlumen(:))*4*4*4/1000000000
        volEPMM=sum(volEP(:))*4*4*4/1000000000
    
        %% Cell density stroma and epithelium (at distance of 100 um)
        if exist([datafile(1:end-4),'_volepi_bwdist.mat'],'file') && redo==0
            load([datafile(1:end-4),'_volepi_bwdist.mat'],'volepi','colvol','d','sk'); 
        else
            % get volcell (DO NOT DOWNSAMPLE)
            load([outpth,nm,'.mat'],'volcellFINAL');
            volcell=volcellFINAL;

        %     volbv=double(vol1==1);  % GET THE BIGGEST EPITHELIUM ONLY
            volepi=double(volsmooth==1);  % GET THE BIGGEST EPITHELIUM ONLY
            volepi=bwdist(volepi); % distance metric around epithelium
            
            % get collagen pixels within 60 micron of the epithelium
            dpixels=d/4/sk;
            colvol=volepi<=dpixels & volepi>0; % area in 60 micron surrounding epithelium (5*12um)
            colvol=colvol.*(double(vol1==2)); % gets stroma
                     
            save([datafile(1:end-4),'_volepi_bwdist.mat'],'volepi','colvol','d','sk');
        end
        % get volcell (DO NOT DOWNSAMPLE)
        load([outpth,nm,'.mat'],'volcellFINAL');

        volcell=volcellFINAL;

        volumecollagen=sum(colvol(:))*4*4*4/1000000000; % volume of collagen in mm3
         
        % get cell count in the collagen subvolume
        cells=0;
        for b=1:size(volcell,3)
            tmpcell=volcell(:,:,b);
            tmpcoll=colvol(:,:,b);
            tmpcoll=imresize(tmpcoll,size(tmpcell),'nearest');
            tmpcell=double(tmpcell).*tmpcoll;
            cells=cells+sum(tmpcell(:));
        end
        collcelldensity=cells/volumecollagen % cell density of stroma around epithelium (cells / mm3) - usually 10,000s
    %     clearvars colvol volbv
    
        % get volume & cells of epithelium
        epivol=volsmooth==1; % GET THE BIGGEST EPITHELIUM ONLY
        volumeepithelium=sum(epivol(:))*4*4*4/1000000000; % volume of collagen in mm3
        cells=0;
        for b=1:size(volcell,3)
            tmpcell=volcell(:,:,b);
            tmpepi=epivol(:,:,b);
            tmpepi=imresize(tmpepi,size(tmpcell),'nearest');
            tmpcell=double(tmpcell).*tmpepi;
            cells=cells+sum(tmpcell(:));
        end
        epicelldensity=cells/volumeepithelium % cell density of stroma around epithelium (cells / mm3) - usually 10,000s
    %     clearvars epivol
        
        %% Concatenate data and put into excel sheet
        % Store the results in a cell array
        results = {epicelldensity,collcelldensity,volEPMM,volEPlumenMM,ratio_EP_lumen,thick_epi};
        % Convert the results to scientific notation using sprintf
        results = cellfun(@(x) sprintf('%0.3e', x), results, 'UniformOutput', false);
        % Append the results to the output cell array
        output = [output; {nm0, repeatlist(lol).name},results];
        
        % prints values before saving them
        for i = 1:numel(results)
            fprintf('%s: %s \n', titles{i+2}, results{i})
        end

        save([datafile(1:end-4),'_results_FINAL.mat'],'epicelldensity','collcelldensity','volEPMM','volEPlumenMM','ratio_EP_lumen','thick_epi','results');
        close all;
    end

end

% Add the titles as the first row of the output cell array
output = [titles; output];

% mat files pth
matpth=[pth0,'mat files\'];
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

%% Combine data from excel sheets
% Read the data from the two Excel sheets using readtable
data_organoids = readtable([matpth,'results_organoids_CODA.xlsx']);
data_ft376 = readtable("\\169.254.138.20\Andre\data\Ashleigh fallopian tube\fallopian tubes\files\mat files\results_fallopian_tube_376.xlsx");

% Save the column headers of the first sheet
headers = data_organoids.Properties.VariableNames;
data_ft376 = renamevars(data_ft376, data_ft376.Properties.VariableNames, data_organoids.Properties.VariableNames);

% Merge the data using vertcat, excluding the first row of the second sheet
mergedData = [data_ft376;data_organoids];

% Add the column headers to the merged data
mergedData.Properties.VariableNames = headers;
% mergedData2={};
% mergedData2 = [titles; mergedData];

% Save the merged data as a .mat file
writetable(mergedData, [matpth,'results_CODA_organoids_ft376_combined.xlsx']);
save([matpth,'results_CODA_organoids_ft376_combined.mat'], 'mergedData');

%% PCA analysis
% Read the Excel file
data = readtable([matpth,'results_CODA_organoids_ft376_combined.xlsx']);

% Extract the results variables
condition=data.Condition;
repeat=data.Repeat;
epicelldensity = data.EpitheliumCellDensity;
collcelldensity = data.StromalCellDensity;
volEPMM = data.VolumeEpithelium_mm3_;
volEPlumenMM = data.VolumeLumen_mm3_;
ratio_EP_lumen = data.ratioEpithelium_Lumen;
thick_epi = data.ThicknessEpithelium_um_;

% Combine the results into a matrix
resultsMatrix = [epicelldensity, collcelldensity, ratio_EP_lumen, thick_epi];

% Perform PCA on the results matrix
[coeff,score,latent] = pca(resultsMatrix);

% D = pdist2(loc,loc);
% idx = dbscan(D,2,50,'Distance','precomputed');

numGroups = length(unique(condition));
clr = hsv(numGroups);

% Set the size and shape for each dot
sz = 30;
marker = {'*', '.', '.', '.', '.', '.', '.', '.', '.','.'};

% Plot the scores of the first two principal components with different size and shape for each condition
figure;
gscatter(score(:,1), score(:,2), condition, clr, marker, sz);
xlabel('PC1');
ylabel('PC2');
title('PCA Plot');
% legend(unique(condition));

%%

