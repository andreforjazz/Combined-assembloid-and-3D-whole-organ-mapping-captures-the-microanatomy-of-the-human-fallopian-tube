% Add necessary paths for functions and scripts folders
path(path,'CODA organoids science advances submission\cell detection')

% Define the path to folder containing all the conditions
pth='\\Andre\data\Ashleigh fallopian tube\organoids\organoidsforCODA\';

% Define condition folders for the cell detection
nms={'5k_2_mg','10k_2_mg','10k_2_mg_norm','10k_2_mg_Str','10k_4_mg','10k_6_mg','10k_6_mg_Str_B','10k_6_mg_Str_B2','standard'}; 

%%

for kk=1:length(nms)

    nm=nms{kk}; disp(nm)
    
    % path images
    pth10x=[pth,nm,'\10x\'];
    repeatlist = dir([pth10x,'*sample*']);

    for ii=1: length(repeatlist)

        repeatnm=repeatlist(ii).name; disp(repeatnm)
        
        % path images
        pth10xrepeat=[pth,nm,'\10x\',repeatnm,'\'];
        pth10xrepeatHchannel=[pth10xrepeat,'fix stain\Hchannel\'];

        % deconvolve Hematoxylin channel from H&E images
        normalize_HE(pth10xrepeat);

        % count cells on H channel
        HE_cell_count_organoids(pth10xrepeatHchannel);
    end

end