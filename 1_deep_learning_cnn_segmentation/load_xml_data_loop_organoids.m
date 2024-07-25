function [ctlist,numann0]=load_xml_data_loop_organoids(pth,pthim,WS,umpix,nm,numclass,cmap2)

    
    imlist=dir([pth,'*xml']); 
    numann0=[];ctlist=[];
    outim=[pth,'check_annotations\'];mkdir(outim);
    % for each annotation file
    for kk=1:length(imlist)
        % set up names
        imnm=imlist(kk).name(1:end-4);tic;
    
        disp(['Image ',num2str(kk),' of ',num2str(length(imlist)),': ',imnm])
        outpth=[pth,'data\',imnm,'\'];
        if ~exist(outpth,'dir');mkdir(outpth);end
        matfile=[outpth,'annotations.mat'];
        
        % skip if file hasn't been updated since last load
        dm='';bb=0;date_modified=imlist(kk).date;
        if exist(matfile,'file');load(matfile,'dm','bb');end
        if contains(dm,date_modified) && bb==1
            disp('  annotation data previously loaded')
            load([outpth,'annotations.mat'],'numann','ctlist0');
            numann0=[numann0;numann];ctlist=[ctlist;ctlist0];
            continue;
        end
        
        % 1 read xml annotation files and saves as mat files
        load_xml_file(outpth,[pth,imnm,'.xml'],date_modified);
        
        % 2 fill annotation outlines and delete unwanted pixels
        [I0,TA,pthTA]=calculate_tissue_space_organoids(pthim,imnm);
        
        J0=fill_annotations_file_AP(I0,outpth,WS,umpix,TA,1); 
        
        I=im2double(I0);
        J=double(J0);
        J1=cmap2(J+1,1);J1=reshape(J1,size(J));
        J2=cmap2(J+1,2);J2=reshape(J2,size(J));
        J3=cmap2(J+1,3);J3=reshape(J3,size(J));
        mask=cat(3,J1,J2,J3);
        % I2=(I*0.5)+(mask*0.5);
        I2=(I*0.4)+(mask*0.6);

        I2=I2(1:2:end,1:2:end,:);

        imwrite(im2uint8(I2),[outim,imnm,'.jpg']);
        
        % create annotation bounding boxes
        [numann,ctlist0]=annotation_bounding_boxes([pthim,imnm],outpth,nm,numclass);
        numann0=[numann0;numann];ctlist=[ctlist;ctlist0];
    
        toc;
    end



end