function train_deeplab(pth,classes,sz,classNames)

disp(' starting training')
nmim='im\'; % nmim='im_blank\';
nmlabel='label\';

pthTrain=[pth,'training\'];
pthVal=[pth,'validation\'];
% pthTest=[pth,'testing\'];

% 1 make training data
TrainHE=[pthTrain,nmim];
Trainlabel=[pthTrain,nmlabel];
imdsTrain = imageDatastore(TrainHE);
pxdsTrain = pixelLabelDatastore(Trainlabel,classNames,classes);
pximdsTrain = pixelLabelImageDatastore(imdsTrain,pxdsTrain); %'DataAugmentation',augmenter);
tbl = countEachLabel(pxdsTrain);

% make validation data
ValHE=[pthVal,nmim];
Vallabel=[pthVal,nmlabel];
imdsVal = imageDatastore(ValHE);
pxdsVal = pixelLabelDatastore(Vallabel,classNames,classes);
pximdsVal = pixelLabelImageDatastore(imdsVal,pxdsVal); %'DataAugmentation',augmenter);


options = trainingOptions('adam',...  % stochastic gradient descent solver
    'MaxEpochs',10,...
    'MiniBatchSize',4,... % datapoints per 'mini-batch' - ideally a small power of 2 (32, 64, 128, or 256)
    'Shuffle','every-epoch',...  % reallocate mini-batches each epoch (so min-batches are new mixtures of data)
    'ValidationData',pximdsVal,...
    'ValidationPatience',6,... % stop training when validation data doesn't improve for __ iterations 5
    'InitialLearnRate',0.0005,...  %     'InitialLearnRate',0.0005,...
    'LearnRateSchedule','piecewise',... % drop learning rate during training to prevent overfitting
    'LearnRateDropPeriod',1,... % drop learning rate every _ epochs
    'LearnRateDropFactor',0.75,... % multiply learning rate by this factor to drop it
    'ValidationFrequency',128,... % initial loss should be -ln( 1 / # classes )
    'ExecutionEnvironment','gpu',... % train on gpu
    'Plots','training-progress');%,... % view progress while training
%     'OutputFcn', @(info)savetrainingplot(info,outpth)); % save training progress as image

% Design network 
numclass = numel(classes);
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

lgraph = deeplabv3plusLayers([sz sz 3],numclass,"resnet50");
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);
% lgraph=make_CNN_layers_deeplab(sz,numclass,tbl,classWeights);

% train
[net, info] = trainNetwork(pximdsTrain,lgraph,options);
save([pth,'net.mat'],'net','info');

end

function stop=savetrainingplot(info,pthSave)
    stop=false;  %prevents this function from ending trainNetwork prematurely
    if info.State=='done'   %check if all iterations have completed
        saveas(findall(groot, 'Type', 'Figure'),[pthSave,'training_process.png'])
    end


end
