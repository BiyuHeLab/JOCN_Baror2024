
%% %% Script for LUMINANCE ANALYSIS

subvec= [133,136:138,140:144,146:147,149:157]; % Subject numbers in Random dataset
load 'imgLumSorted.mat' % imgLumSorted is the image's luminance table.
lumcor_R=[];
lumcor_p=[];
imageBySub=[];
numOfImages=560;

% Face stimuli numbers are 1:280
% Scene stimuli numbers are 281:560

face_luminance= nanmean(imgLumSorted{1:280,:})
scene_luminance= nanmean(imgLumSorted{281:end,:})
[h,p,tstat,ci]=ttest2(imgLumSorted{1:280,4},imgLumSorted{281:end,4})


for s= 1:length(subvec);

load(['handles_', num2str(subvec(s)),'b.mat']);    
numT=400;%number of trials 
numP= 10; %number of precentiles
%excluding no response trials
arrange= [handles.mainResults,(1:numT)'];
for i=1:numT
    if handles.mainResults(i,5)>9999.9999 % max response window
        arrange (i,5)= NaN;
    end
    if find(imgLumSorted.Img==arrange(i,4))
    arrange(i,7)= imgLumSorted{find(imgLumSorted.Img==arrange(i,4)),4};
    else
    arrange(i,7)=NaN;
    end
end

[r,p]=corr(arrange(:,5),arrange(:,7),'rows','complete'); % luminance-duration correlation

lumcor_R(s,1)=r ;
lumcor_p(s,1)= p;

for im= 1: numOfImages
    if find(arrange(:,4)==im)
    imageBySub(im,s)=  arrange(find(arrange(:,4)==im),5);
    else
     imageBySub(im,s)= NaN;
    end
end
end



% Across subject correlations- Faces
for i=1:size(subvec,2);
    for j=1:size(subvec,2);
        face_crossSubjectLuminanceCorrelation(i,j)=corr(imageBySub(1:280,i),imageBySub(1:280,j),'rows','complete','type','Spearman');
    end
end

lowerCorr= tril(face_crossSubjectLuminanceCorrelation);
corForMean=[];
for i=1:size(lowerCorr,1)
    for j=1:size(lowerCorr,1);
        if lowerCorr(i,j)<1 && abs(lowerCorr(i,j))>0;
            corForMean= [corForMean;lowerCorr(i,j)];
        end
    end
end

nanmean(corForMean)

% Across subject correlations- Scenes
for i=1:size(subvec,2);
    for j=1:size(subvec,2);
        scene_crossSubjectLuminanceCorrelation(i,j)=corr(imageBySub(281:end,i),imageBySub(281:end,j),'rows','complete','type','Spearman');
    end
end

lowerCorr= tril(scene_crossSubjectLuminanceCorrelation);
corForMean=[];
for i=1:size(lowerCorr,1)
    for j=1:size(lowerCorr,1);
        if lowerCorr(i,j)<1 && abs(lowerCorr(i,j))>0;
            corForMean= [corForMean;lowerCorr(i,j)];
        end
    end
end

nanmean(corForMean)

lowerCorr= tril(crossSubjectLuminanceCorrelation);
corForMean=[];
for i=1:size(lowerCorr,1)
    for j=1:size(lowerCorr,1);
        if lowerCorr(i,j)<1 && abs(lowerCorr(i,j))>0;
            corForMean= [corForMean;lowerCorr(i,j)];
        end
    end
end

nanmean(corForMean)

image_ViewDur= nanmean(imageBySub,2); % Mean viewing duration of each image

% Correlation- Faces
[allR, allP]= corr(image_ViewDur(281:end),imgLumSorted{281:end,4},'rows','complete','type','Spearman')
% Correlation- Scenes
[allR, allP]= corr(image_ViewDur(1:280),imgLumSorted{1:280,4},'rows','complete','type','Spearman')



