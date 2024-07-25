function normalize_HE(pth,pthl,outpth)
warning ('off','all');

if ~exist('pthl','var');pthl=pth;end
if ~exist('outpth','var');outpth=[pth,'fix stain\'];end
outpthC=[outpth,'CVS\'];
outpthH=[outpth,'Hchannel\'];
% outpthE=[outpth,'Echannel\'];
mkdir(outpth);
mkdir(outpthC);
mkdir(outpthH);
% mkdir(outpthE);

tic;
imlist=dir([pth,'*tif']);if size(imlist,1)<1;imlist=dir([pth,'*jpg']);end
knum=150000;

% H&E
CVS=[0.644 0.717 0.267;0.093 0.954 0.283;0.636 0.001 0.771];

for kk=1:length(imlist)
        imnm=imlist(kk).name; %disp([num2str(kk),'  ',num2str(length(imlist)),'  ',imnm])
        if exist([outpthH,imnm],'file');disp(['skip ',num2str(kk)]);disp('skip');continue;end
        disp([num2str(kk), ' ', num2str(length(imlist)), ' ', imnm(1:end-4)]);
        
        im0=imread([pth,imnm]);
        save([outpthC,imnm(1:end-3),'mat'],'CVS');
        
        [imout,imH,imE]=colordeconv2pw4_log10(im0,"he",CVS);
        
%         figure(3),imshow(imH)
        imwrite(uint8(imH),[outpthH,imnm]);
        % imwrite(uint8(imE),[outpthE,imnm]);       
end
warning ('off','all');
end

