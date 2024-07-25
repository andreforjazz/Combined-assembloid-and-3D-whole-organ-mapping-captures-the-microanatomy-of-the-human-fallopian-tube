function check_test_class_imgs(pthtest,pthclassify,umpix)

testlist=dir([pthtest,'*jpg']);
% classlist=dir([pthclassify,'*tif']);
outpth=[pthclassify,'combined_validation\']; 
if ~exist(outpth,'dir');mkdir(outpth);end
for k=1:length(testlist)
    nm=testlist(k).name(1:end-4); disp(nm);
    
    if umpix==1
        imtest=imread([pthtest,nm,'.jpg']);
        imtest=imresize(imtest,2);
    else 
        imtest=imread([pthtest,nm,'.jpg']);
    end

    imclass=imread([pthclassify,nm,'.tif']);
    figure, imshowpair(imclass, imtest);title(nm);
    
    fusedpair = imfuse(imclass, imtest);
    imwrite(fusedpair, [outpth,nm,'.jpg']);
end

end