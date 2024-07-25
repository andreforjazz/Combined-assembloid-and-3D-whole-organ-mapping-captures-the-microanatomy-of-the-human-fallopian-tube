function numann=combine_tiles_density(numann0,numann,imlist,nblack,pthDL,outpth,sxy,stile,nbg)
if ~exist('nbg','var');nbg=0;end
if ~exist('stile','var');stile=10000;end
stile=stile+200;
kpall=1;

% define folder locations
outpthim=[pthDL,outpth,'im\'];
outpthlabel=[pthDL,outpth,'label\'];
outpthbg=[pthDL,outpth,'big_tiles\'];
mkdir(outpthim);mkdir(outpthlabel);mkdir(outpthbg);
imlistck=dir([outpthim,'*tif']);
nm0=length(imlistck)+1;

% create very large blank images
imH=ones([stile stile 3])*nbg;
imT=zeros([stile stile]);
nL=numel(imT);
ct=zeros([1 size(numann,2)]);
sf=sum(ct)/nL;

count=1;
cutoff=0.45;
tcount=1;
h=zeros(51);h(26,26)=1;h=double(bwdist(h)<26);
rsf=5;
while sf<cutoff
    % randomly choose tile to load
    if rem(count,6)==0
        type=tcount;tcount=rem(tcount,length(ct))+1;
    else
        type=find(sum(ct,1)==min(sum(ct,1)),1,'first');
    end
    num=find(numann(:,type)>0);

    if isempty(num)
        numann(:,type)=numann0(:,type);
        disp(['RELOAD TYPE: ',num2str(type)])
        num=find(numann(:,type)>0);
    end

    try
        num=num(randperm(length(num),1))';
    catch
        disp('deu raia');
    end

    % load annotation and mask
    try
        imnm=imlist(num).name;
    catch
        disp('not working')
    end
    
    pthim=[imlist(num).folder,'\'];
    pf=strfind(pthim,'\');
    pthlabel=[pthim(1:pf(end-1)),'label\'];
    TA=double(imread([pthlabel,imnm]));
    im=double(imread([pthim,imnm]));
    
%     if sum(TA(:)==type)>180000
%         numann(num,:)=0;
%         continue;
%     end
    
%     imshow(TA,[0 7])
%     disp([type unique(TA)'])

    % keep only needed annotation classes
    if rem(count,3)==1;doaug=1;else;doaug=0;end
    [im,TA,kp]=edit_annotation_tiles(im,TA,doaug,type,ct,size(imT,1),kpall);
    numann(num,kp)=0;
    fx=TA~=0;
    if sum(fx(:))<30;continue;end
    
    % find low density location in large tile to add annotation
    tmp=double(imT>0);
    tmp2=tmp(1:rsf:end,1:rsf:end);
    tmp2=imfilter(tmp2,h);
    tmp=bwdist(tmp2>0);
    tmp([1:20 end-19:end],:)=0;
    tmp(:,[1:20 end-19:end])=0;
    xii=find(tmp==max(tmp(:)));
    xii=xii(randperm(length(xii),1));
    [x,y]=ind2sub(size(tmp),xii);
    x=x*rsf;y=y*rsf;
    szz=size(TA)-1;
    szzA=floor(szz/2);
    szzB=szz-szzA;
    

    if x+szzA(1)>size(imT,2);x=x-szzA(1);end
    if y+szzA(2)>size(imT,1);y=y-szzA(2);end
    if x-szzB(1)<1;x=x+szzB(1);end
    if y-szzB(2)<1;y=y+szzB(2);end
    tmpT=imT(x-szzB(1):x+szzA(1),y-szzB(2):y+szzA(2));

    tmpT(fx)=TA(fx);
    tmpH=imH(x-szzB(1):x+szzA(1),y-szzB(2):y+szzA(2),:);
    tmpH(cat(3,fx,fx,fx))=im(cat(3,fx,fx,fx));
    imT(x-szzB(1):x+szzA(1),y-szzB(2):y+szzA(2))=tmpT;
    imH(x-szzB(1):x+szzA(1),y-szzB(2):y+szzA(2),:)=tmpH;

     
    % update total count
    if  mod(count,5)==0;sf=sum(imT(:)>0)/numel(imT);end
    for p=1:size(numann,2);ct(p)=ct(p)+sum(tmpT(:)==p);end
    
    if  mod(count,150)==0 || sf>cutoff
        %figure(42);imagesc(imT);axis equal;axis off;hold on;scatter(y,x,'r*')
        tmp=histcounts(imT(:),0:size(numann,2)+1);
        ct=tmp(2:end);ct(ct==0)=1;
        disp([round(sf*100) ct/min(ct)])
    end
    
%     figure(50);imagesc(uint8(imH));axis equal;axis off;hold on;scatter(y,x,'r*')
    count=count+1;
end

% cut edges off tile
imH=uint8(imH(101:end-100,101:end-100,:));
imT=uint8(imT(101:end-100,101:end-100,:));
for p=1:nblack;ct(p)=sum(imT(:)==p);end
sf=sum(ct)/numel(imT);
ct(ct==0)=Inf;
%disp([round(sf*100) ct/min(ct)])
imT(imT==0)=nblack;

% save cutouts to outpth
sz=size(imH);
for s1=1:sxy:sz(1)
    for s2=1:sxy:sz(2)
        try
            imHtmp=imH(s1:s1+sxy-1,s2:s2+sxy-1,:);
            imTtmp=imT(s1:s1+sxy-1,s2:s2+sxy-1,:);
        catch
            continue
        end
        imwrite(imHtmp,[outpthim,num2str(nm0),'.tif']);
        imwrite(imTtmp,[outpthlabel,num2str(nm0),'.tif']);
        
        nm0=nm0+1;
    end
end
nm1=dir([outpthbg,'*tif']);nm1=length(nm1)/2+1;

% save large tiles
imwrite(imH,[outpthbg,'HE_tile_',num2str(nm1),'.tif']);
imwrite(imT,[outpthbg,'label_tile_',num2str(nm1),'.tif']);

end

function [im,TA,kpout]=edit_annotation_tiles(im,TA,doaug,type,ct,sT,kpall)
% makes sure annotation distribution doesn't vary by more than 1%
	if doaug
        [im,TA]=random_augmentation(im,TA,1,1,1,1,0);
    else
        [im,TA]=random_augmentation(im,TA,1,1,0,0,0);
    end
    
    if kpall==0
        maxn=ct(type);
        kp=ct<=maxn*1.05;
    else
        kp=ct>=0;
    end
    % classes to always keep in the annotation tiles
    %kp(12)=1;kp(14)=1; % collagen, whitespace - whole monkey
    %kp(3)=1;kp(4)=1; % alveoli, whitespace - monkey lungs
    
    kp=[0 kp];
    tmp=kp(TA+1);

    dil=randi(15)+15;
    tmp=imdilate(tmp,strel('disk',dil));
    TA=TA.*double(tmp);
    im=im.*double(tmp);
    kpout=unique(TA);kpout=kpout(2:end);
    
    p1=min([sT size(TA,1)]);
    p2=min([sT size(TA,2)]);
    im=im(1:p1,1:p2,:);TA=TA(1:p1,1:p2);

    im=uint8(im);
    TA=uint8(TA);
end
