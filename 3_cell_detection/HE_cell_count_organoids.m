function HE_cell_count_organoids(pth)
outpth=[pth,'cell_coords_validated\'];
mkdir(outpth);

imlist=dir([pth,'*tif']);
if isempty(imlist);imlist=dir([pth,'*jp2']);end

tic;
xyc=zeros([1 length(imlist)]);
tic;
for kk=1:length(imlist)
    imnm=imlist(kk).name;
    if exist([outpth,imnm(1:end-3),'mat'],'file');continue;end

    % count cells
    imH=imread([pth,imnm]);
    imH=imH(:,:,1);
    ii=imH;ii=ii(ii~=0);imH(imH==0)=mode(ii);
    imH=255-imH;
%   load([outpth,imnm(1:end-3),'mat'],'xy');

    %imB=bpassW(imH,1,3); % size of noise, size of object
    imB=imgaussfilt(imH,1);
    xy=pkfndW(double(imB),60,9); %110,7 minimum brightness, size of object
%         figure(2),clf,imshow(255-imH);axis equal;hold on;plot(xy(:,1),xy(:,2),'ro');
    xyc(kk)=size(xy,1);

    disp(round([kk length(imlist) xyc(kk)]))
    save([outpth,imnm(1:end-3),'mat'],'xy');
end
end



