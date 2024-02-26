%% Distiribution between image context and viewing duration

totalNumOfImages= 560;
faceNums= [1:280]; % Face image indexes
sceneNums= [281:560]; % Scene image indexes

%% ANALYSIS 1. CHECKING CHANGES IN RANDOM GROUP RT SORTED BY FIXED-GROUP ORDER
subvecFixed= [111,113:117,119:125,127:130,134]; % Fixed participants
subvecRand= [133,136:138,140:144,146:147,149:157]; % Random participants

load(['handles_111b.mat']);  % An example of fixed order participant
fixedImagesByOrder= (handles.mainResults(:,4));

all_fixedPar_byOrder= nan(length(fixedImagesByOrder), length(subvecFixed)+2);
all_fixedPar_byOrder(:,1)= fixedImagesByOrder;
all_fixedPar_byOrder(:,2)= handles.mainResults(:,3);

%% FIXED DATASET
for s= 1:length(subvecFixed);  
load(['handles_', num2str(subvecFixed(s)),'b.mat']);    
    all_fixedPar_byOrder(:, s+2)= handles.mainResults(:,5);
end

mean_fixedPar_byOrder= [ (1:length(all_fixedPar_byOrder))',all_fixedPar_byOrder(:,1),  all_fixedPar_byOrder(:,2) , nanmean(all_fixedPar_byOrder(:,3:end),2)];
mean_fixedPar_byViewDur= sortrows(mean_fixedPar_byOrder, 4);
all_fixedPar_byOrder_wMean= [all_fixedPar_byOrder,nanmean(all_fixedPar_byOrder(:,3:20),2)];
all_fixedPar_byViewDure_wMean= sortrows(all_fixedPar_byOrder_wMean,21); 

all_fixedPar_byViewDure_wMean_faces= all_fixedPar_byViewDure_wMean(all_fixedPar_byViewDure_wMean(:,2)==1,:); 
all_fixedPar_byViewDure_wMean_scenes= all_fixedPar_byViewDure_wMean(all_fixedPar_byViewDure_wMean(:,2)==2,:); 

mean_fixedPar_byFixedViewDur_Faces= mean_fixedPar_byViewDur(find (mean_fixedPar_byViewDur(:,3)==1),:);
mean_fixedPar_byFixedViewDur_Scenes= mean_fixedPar_byViewDur(find (mean_fixedPar_byViewDur(:,3)==2),:);

%% RANDOM GROUP

all_RandomPar_byContent= nan(totalNumOfImages, length(subvecRand));
all_RandomPar_ImageID= nan(totalNumOfImages, length(subvecRand));
for s= 1:length(subvecRand);  
load(['handles_', num2str(subvecRand(s)),'b.mat']);  

for t= 1:length(handles.mainResults(:,4) )   
    all_RandomPar_byContent(handles.mainResults(t,4),s)= handles.mainResults(t,5);
end
for t= 1:length(handles.mainResults(:,4))  
    all_RandomPar_ImageID(t,s)= handles.mainResults(t,4);
end
end


mean_RandPar_byContent= [ (1:length(all_RandomPar_byContent))',[ones(280,1); ones(280,1)*2],  nanmean(all_RandomPar_byContent,2), nanstd(all_RandomPar_byContent,0,2)];



for i= 1:length(mean_fixedPar_byViewDur)
mean_RandPar_byFixedViewDur(i,1)= mean_RandPar_byContent (find(mean_RandPar_byContent(:,1)==  mean_fixedPar_byViewDur(i,2)) , 1);
mean_RandPar_byFixedViewDur(i,2)= mean_RandPar_byContent (find(mean_RandPar_byContent(:,1)==  mean_fixedPar_byViewDur(i,2)) , 2);
mean_RandPar_byFixedViewDur(i,3)= mean_RandPar_byContent (find(mean_RandPar_byContent(:,1)==  mean_fixedPar_byViewDur(i,2)) , 3);
mean_RandPar_byFixedViewDur(i,4)= mean_RandPar_byContent (find(mean_RandPar_byContent(:,1)==  mean_fixedPar_byViewDur(i,2)) , 4);
end

for i=1:length(mean_fixedPar_byViewDur);
all_RandomPar_byFixedViewDur(i,:)= all_RandomPar_byContent(mean_fixedPar_byViewDur(i,2),:);
end
all_RandomPar_byFixedViewDur_faces= all_RandomPar_byContent(mean_fixedPar_byFixedViewDur_Faces(:,2),:);
all_RandomPar_byFixedViewDur_scenes= all_RandomPar_byContent(mean_fixedPar_byFixedViewDur_Scenes(:,2),:);
plot(nanmean(all_RandomPar_byFixedViewDur_faces,2));
hold on
plot(nanmean(all_RandomPar_byFixedViewDur_scenes,2));
hold on
plot(mean_fixedPar_byFixedViewDur_Faces(:,4));
hold on
plot(mean_fixedPar_byFixedViewDur_Scenes(:,4));

% Checking sig. view dur diff. in Random set arranged by Fixed view dur.
 
%Binning Faces
binNum=4;
imagesPerBin= size(all_RandomPar_byFixedViewDur_faces,1)/binNum;
for i=1:binNum
    binned_RandPar_byFixViewDur_Faces(:,i)=nanmean(all_RandomPar_byFixedViewDur_faces(imagesPerBin*i-imagesPerBin+1: imagesPerBin*i ,:))';
end
[p,tbl,stats] = anova1(binned_RandPar_byFixViewDur_Faces); 
title({['Random Viewing duration binned by Fixed viewing duration'],['Face Images']});
xlabel('bins');
ylabel('viewing duration (ms)');

%Binning Scenes
binNum=4;
imagesPerBin= size(all_RandomPar_byFixedViewDur_scenes,1)/binNum;
for i=1:binNum
    binned_RandPar_byFixViewDur_Scenes(:,i)=nanmean(all_RandomPar_byFixedViewDur_scenes(imagesPerBin*i-imagesPerBin+1: imagesPerBin*i ,:))';
end
[p,tbl,stats] = anova1(binned_RandPar_byFixViewDur_Scenes); 
title({['Random Viewing duration binned by Fixed viewing duration'],['Scene Images']});
xlabel('bins');
ylabel('viewing duration (ms)')



% Chacking correlation between viewdur in fixed and view dur in random
[r,p]= corr(mean_RandPar_byFixedViewDur_Faces (:,4), mean_fixedPar_byFixedViewDur_Faces (:,4))
[r,p]= corr(mean_RandPar_byFixedViewDur_Scenes (:,4), mean_fixedPar_byFixedViewDur_Scenes (:,4))

scatter(mean_RandPar_byFixedViewDur_Faces (:,4), mean_fixedPar_byFixedViewDur_Faces (:,4))
hold on
scatter(mean_RandPar_byFixedViewDur_Scenes (:,4), mean_fixedPar_byFixedViewDur_Scenes (:,4))

mean_RandPar_byFixedViewDur_Faces= mean_RandPar_byFixedViewDur(find (mean_RandPar_byFixedViewDur(:,2)==1),:);

mean_RandPar_byFixedViewDur_Scenes= mean_RandPar_byFixedViewDur(find (mean_RandPar_byFixedViewDur(:,2)==2),:);

%% comparing  fixed viewing duration sorted by fixed viewing duration (short to long) with random viewing duration sorted by fixed viewing duration
figure
x= 1:400;
plot(x, mean_RandPar_byFixedViewDur(:,3), 'g', 'LineWidth', 2)
hold on
plot(x, mean_fixedPar_byViewDur(:,4),'b', 'LineWidth', 2)
ylim([1500 5500]);
xlabel('images');
ylabel('viewing duration (ms)');
legend ({'Random Group', 'Fixed Group'});
title ('Images sorted by mean viewing duration in the Fixed Group');



figure
x= 1:196;
plot(x, mean_RandPar_byFixedViewDur_Faces(:,3), 'g', 'LineWidth', 2)
hold on
plot(x, mean_fixedPar_byFixedViewDur_Faces(:,4),'b', 'LineWidth', 2)
ylim([1500 5500]);
xlabel('images');
ylabel('viewing duration (ms)');
legend ({'Random Group', 'Fixed Group'});
title ('Face Images sorted by mean viewing duration in the Fixed Group');


figure
x= 1:204;
plot(x, mean_RandPar_byFixedViewDur_Scenes(:,3), 'g', 'LineWidth', 2)
hold on
plot(x, mean_fixedPar_byFixedViewDur_Scenes(:,4),'b', 'LineWidth', 2)
ylim([1500 5500]);
xlim([1 205]);
xlabel('images');
ylabel('viewing duration (ms)');
legend ({'Random Group', 'Fixed Group'});
title ('Scene images sorted by mean viewing duration in the Fixed Group');



%% binning the analysis
binned_fixedPar_byViewDur=[];
binned_RandPar_byFixedViewDur=[];
binSize= 100;
numOfBins= length(mean_RandPar_byFixedViewDur(:,3))/binSize;
for i=1:numOfBins;
  binned_fixedPar_byViewDur(i)   =  nanmean(mean_fixedPar_byViewDur( (i*binSize - binSize+1:i*binSize) ,4));
  binned_RandPar_byFixedViewDur(i)   =  nanmean(mean_RandPar_byFixedViewDur( (i*binSize - binSize+1:i*binSize) ,3));
end

figure
bar(binned_fixedPar_byViewDur)
hold on
bar(binned_RandPar_byFixedViewDur)
ylim([1500 5500]);

%% SEPARATING THE ANALYSIS TO FACES AND SCENES
%Fave/Scene fixed par
mean_fixedPar_byFixedViewDur_Faces= mean_fixedPar_byViewDur(find(mean_fixedPar_byViewDur(:,3)==1),:);
mean_fixedPar_byFixedViewDur_Scenes= mean_fixedPar_byViewDur(find(mean_fixedPar_byViewDur(:,3)==2),:);
%Face/Scene rand par
mean_RandPar_byFixedViewDur_Faces= mean_RandPar_byFixedViewDur(find(mean_RandPar_byFixedViewDur(:,2)==1),:);
mean_RandPar_byFixedViewDur_Scenes= mean_RandPar_byFixedViewDur(find(mean_RandPar_byFixedViewDur(:,2)==2),:);

figure
plot(mean_fixedPar_byFixedViewDur_Faces(:,4))
hold on
plot(mean_RandPar_byFixedViewDur_Faces(:,3))


figure
plot(mean_fixedPar_byFixedViewDur_Scenes(:,4))
hold on
plot(mean_RandPar_byFixedViewDur_Scenes(:,3))

% Binning

binned_fixedPar_byViewDur_Faces=[];
binned_fixedPar_byViewDur_Scenes=[];
binned_RandPar_byFixedViewDur_Faces=[];
binned_RandPar_byFixedViewDur_Scenes=[];

binSizeAll=100;
binSizeFaces= 49;
binSizeScenes= 51;

numOfBinsAll= length(mean_RandPar_byFixedViewDur(:,3))/binSizeAll;
numOfBinsFaces= length(mean_RandPar_byFixedViewDur_Faces(:,3))/binSizeFaces;
numOfBinsScenes= length(mean_RandPar_byFixedViewDur_Scenes(:,3))/binSizeScenes;


for i=1:numOfBinsAll;
  binned_fixedPar_byViewDur_All(i)   =  nanmean(mean_fixedPar_byViewDur((i*binSizeAll - binSizeAll+1:i*binSizeAll)  ,4));
  binned_RandPar_byFixedViewDur_All(i)   =  nanmean(mean_RandPar_byFixedViewDur((i*binSizeAll - binSizeAll+1:i*binSizeAll) ,3));
end

for i=1:numOfBinsFaces;
  binned_fixedPar_byViewDur_Faces(i)   =  nanmean(mean_fixedPar_byFixedViewDur_Faces( (i*binSizeFaces - binSizeFaces+1:i*binSizeFaces) ,4));
  binned_RandPar_byFixedViewDur_Faces(i)   =  nanmean(mean_RandPar_byFixedViewDur_Faces( (i*binSizeFaces - binSizeFaces+1:i*binSizeFaces) ,3));
end
for i=1:numOfBinsScenes;
  binned_fixedPar_byViewDur_Scenes(i)   =  nanmean(mean_fixedPar_byFixedViewDur_Scenes((i*binSizeScenes - binSizeScenes+1:i*binSizeScenes)  ,4));
  binned_RandPar_byFixedViewDur_Scenes(i)   =  nanmean(mean_RandPar_byFixedViewDur_Scenes((i*binSizeScenes - binSizeScenes+1:i*binSizeScenes) ,3));
end


            
 %% Taking variance across participants into account
 % All images
 numOfBins= 4;
 binSizeAll= length(mean_RandPar_byFixedViewDur)/numOfBins;
 imageNumbers_ByFixViewDur_all=[];
 for i=1:numOfBins
 imageNumbers_ByFixViewDur_all(:,i)= mean_RandPar_byFixedViewDur(binSizeAll*i-binSizeAll+1:binSizeAll*i,1);
 end
mean_binned_RandPar_byFixViewDur= nan(length(subvecRand), size( imageNumbers_ByFixViewDur_all,2));         
for p=1:length(subvecRand)
    for b= 1:size( mean_binned_RandPar_byFixViewDur, 2)
        meanVec=[];
    for t= 1:size(imageNumbers_ByFixViewDur_all , 1)
        meanVec= [meanVec; all_RandomPar_byContent(imageNumbers_ByFixViewDur_all(t,b),p )];
    end
        mean_binned_RandPar_byFixViewDur(p,b)= nanmean(meanVec);
    end
end
 
[p,tbl,stats] = anova1(mean_binned_RandPar_byFixViewDur); 
title('Random Viewing duration binned by Fixed viewing duration');
xlabel('bins');
ylabel('viewing duration (ms)');

 % Face images
binSizeFaces = length(mean_RandPar_byFixedViewDur_Faces)/numOfBins;
imageNumbers_ByFixViewDur_Face=[];
for i=1:numOfBins
 imageNumbers_ByFixViewDur_Face(:,i)= mean_RandPar_byFixedViewDur_Faces(binSizeFaces*i-binSizeFaces+1:binSizeFaces*i,1);
 end 
 
mean_binned_RandPar_byFixViewDur_Faces= nan(length(subvecRand), size(imageNumbers_ByFixViewDur_Face,2));         
for p=1:length(subvecRand)
    for b= 1:size( mean_binned_RandPar_byFixViewDur_Faces, 2)
        meanVec=[];
    for t= 1:size(imageNumbers_ByFixViewDur_Face , 1)
        meanVec= [meanVec; all_RandomPar_byContent(imageNumbers_ByFixViewDur_Face(t,b),p )];
    end
        mean_binned_RandPar_byFixViewDur_Faces(p,b)= nanmean(meanVec);
    end
end
 
[p,tbl,stats] = anova1(mean_binned_RandPar_byFixViewDur_Faces); 
title({['Random Viewing duration binned by Fixed viewing duration'],['Face Images']});
xlabel('bins');
ylabel('viewing duration (ms)');

 % Scene images
binSizeScenes = length(mean_RandPar_byFixedViewDur_Scenes)/numOfBins;
imageNumbers_ByFixViewDur_Scene=[];
for i=1:numOfBins
 imageNumbers_ByFixViewDur_Scene(:,i)= mean_RandPar_byFixedViewDur_Scenes(binSizeScenes*i-binSizeScenes+1:binSizeScenes*i,1);
 end         
        
mean_binned_RandPar_byFixViewDur_Scenes= nan(length(subvecRand), size(imageNumbers_ByFixViewDur_Scene,2));         
for p=1:length(subvecRand)
    for b= 1:size( mean_binned_RandPar_byFixViewDur_Scenes, 2)
        meanVec=[];
    for t= 1:size(imageNumbers_ByFixViewDur_Scene , 1)
        meanVec= [meanVec; all_RandomPar_byContent(imageNumbers_ByFixViewDur_Scene(t,b),p )];
    end
        mean_binned_RandPar_byFixViewDur_Scenes(p,b)= nanmean(meanVec);
    end
end
 
[p,tbl,stats] = anova1(mean_binned_RandPar_byFixViewDur_Scenes); 
title({['Random Viewing duration binned by Fixed viewing duration'],['Scene Images']});
xlabel('bins');
ylabel('viewing duration (ms)');




