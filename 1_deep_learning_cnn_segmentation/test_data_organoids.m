function test_data_organoids(pthdata,pthclassify,nwhite,nblack,titles)
numclass=nblack-1;

plist=dir(pthdata);
pDL=[];
ptrue=[];
for k=1:length(plist)
    tic;
    pth=[pthdata,plist(k).name,'\'];
    if exist([pth,'view_annotations.tif'],'file') || exist([pth,'view_annotations_raw.tif'],'file')
        try
            J0=double(imread([pth,'view_annotations.tif']));
        catch
            J0=double(imread([pth,'view_annotations_raw.tif']));
        end
        %im=imread([pthim,plist(k).name,'.tif']);
        imDL=imread([pthclassify,plist(k).name,'.tif']);
        
        % remove small pixels
        for b=1:max(J0)
            tmp=J0==b;
            J0(J0==b)=0;
            tmp=bwareaopen(tmp,25);
            J0(tmp==1)=b;
        end
        
        % get true and predicted class at testing annotation locations
        L=find(J0>0);
        ptrue=cat(1,ptrue,J0(L));
        pDL=cat(1,pDL,imDL(L));

    end
    disp([k length(plist) round(toc)])
end
pDL(pDL==nblack)=nwhite;
% fx=ptrue==numclass | pDL==numclass;
% ptrue(fx)=[];pDL(fx)=[];

% normalize to the minimum number of pixels, rounded to neartest 1000
km=min(histcounts(ptrue,numclass));
km=floor(km/1000)*1000;
ptrue2=[];
pDL2=[];
for k=unique(ptrue)'
    a=find(ptrue==k);
    b=randperm(length(a),km);
    ptrue2=[ptrue2;ptrue(a(b))];
    pDL2=[pDL2;pDL(a(b))];
end

% confusion matrix with equal number of pixels of each class
Dn=zeros([max(ptrue) max(pDL)]);
for a=1:max(ptrue2)
    for b=1:max(pDL2)
        tmp1=ptrue2==a;
        tmp2=pDL2==b;
        Dn(a,b)=sum(tmp1 & tmp2);
    end
end
make_confusion_matrix(Dn,titles)
return;

