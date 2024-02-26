
%% SCRIPT FOR PUPIL SIZE CORRELATION WITH RESIDUALS

addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') % paths to eyetracking  data
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %paths to behavioral  data

subvec= [133, 136:138,140:144, 146:147,149:157]; % Random participants dataset
load('allSortedResiduals_eeg_rand.mat'); % loading Random dataset residuals 
%subvec= [111,113:117,119:125,127:130,134]; Fixed participants dataset

all_timeDurVec=[];
all_PreVec=[];
all_OnsetVec=[];
all_OnsetBCVec=[];
all_OffsetVec=[];
all_OffsetBCVec=[];
all_OffsetBCVec=[];

for s=1:length(subvec)
subjectNumber=subvec(s);
load(['results\data_', num2str(subjectNumber),'.mat']);    
load(['results\events_', num2str(subjectNumber),'.mat']);   
load(['handles_', num2str(subjectNumber),'b.mat']); 

[trialIndex]=[];
[trialIndex]= SP_ET_trialIndex(subjectNumber,data,events);
%% pre-trial pupil size 
preLength= 1000;
[preMat , meanPreVec ]= SP_ET_pupilSizePre(data,trialIndex, preLength);


%% ONSET ANALYSIS
% calculating pupil-size onset matrixes and mean vectors
preBase=200;
onsetLength=1000;
onsetMat=[];
onsetMat_baseCor=[];
meanOnsetVec=[] ;
meanOnsetVec_baseCor=[];
[onsetMat , onsetMat_baseCor , meanOnsetVec , meanOnsetVec_baseCor ]= SP_ET_pupilSizeOnset(data,trialIndex, meanPreVec, onsetLength);

all_onsetMat(s,:)= nanmean(onsetMat_baseCor); % For charaterizing Onset dynamics

%% Calculating pupil-size offset matrixes and mean vectors 
preBaseVec=meanPreVec;
offsetLength=400;
offsetMat=[];
offsetMat_baseCor =[];
meanOffsetVec=[];
meanOffsetVec_baseCor=[];
[offsetMat , offsetMat_baseCor , meanOffsetVec , meanOffsetVec_baseCor ]= SP_ET_pupilSizeOffset(data,trialIndex, preBaseVec, offsetLength);                                                  


%% Calculating correlations with residuals

timeDurVec= allSortedResiduals(:,s);
%timeDurDur= timeDurVecEEG(:,s);
%timeDurVec= (1:400)';
%% excluding trials that are shorter than 1500ms
for i=1:length(timeDurVec)
    if timeDurDur(i,1)<1500;
        timeDurVec(i,1)=NaN;
    end
    if timeDurDur(i,1)>10000
        timeDurVec(i,1)=NaN;
    end
end

all_timeDurVec=[all_timeDurVec;timeDurVec];

% pre
   [R,P] = corrcoef(meanPreVec,timeDurVec,'rows','complete');
   preCorr(s,1)= R(1,2);
    preCorr_p(s,1)= P(1,2);
%     [R,P] = corr(meanPreVec,timeDurVec,'rows','complete', 'Type','Spearman');
%    preCorr(s,1)= R;
%     preCorr_p(s,1)= P;
    all_PreVec=[all_PreVec;meanPreVec];
% onset
   [R,P] = corrcoef(meanOnsetVec,timeDurVec,'rows','complete');
   onsetCorr(s,1)= R(1,2);
    onsetCorr_p(s,1)= P(1,2);
%     [R,P] = corr(meanOnsetVec,timeDurVec,'rows','complete', 'Type','Spearman');
%    onsetCorr(s,1)= R;
%     onsetCorr_p(s,1)= P;
    all_OnsetVec=[all_OnsetVec;meanOnsetVec];
% onset bc
   [R,P] = corrcoef(meanOnsetVec_baseCor,timeDurVec,'rows','complete');
   onsetCorrBC(s,1)= R(1,2);
    onsetCorrBC_p(s,1)= P(1,2);
%    [R,P] = corr(meanOnsetVec_baseCor,timeDurVec,'rows','complete','Type','Spearman');
%    onsetCorrBC(s,1)= R;
%     onsetCorrBC_p(s,1)= P;
    all_OnsetBCVec=[all_OnsetBCVec;meanOnsetVec_baseCor];
% offset
   [R,P] = corrcoef(meanOffsetVec,timeDurVec,'rows','complete');
   offsetCorr(s,1)= R(1,2);
    offsetCorr_p(s,1)= P(1,2);
%        [R,P] = corr(meanOffsetVec,timeDurVec,'rows','complete','Type','Spearman');
%    offsetCorr(s,1)= R;
%     offsetCorr_p(s,1)= P;
    all_OffsetVec=[all_OffsetVec;meanOffsetVec];
% offset bc
   [R,P] = corrcoef(meanOffsetVec_baseCor,timeDurVec,'rows','complete');
   offsetCorrBC(s,1)= R(1,2);
    offsetCorrBC_p(s,1)= P(1,2);
%     [R,P] = corr(meanOffsetVec_baseCor,timeDurVec,'rows','complete','Type','Spearman');
%    offsetCorrBC(s,1)= R;
%     offsetCorrBC_p(s,1)= P;
    all_OffsetBCVec=[all_OffsetBCVec;meanOffsetVec_baseCor];

end

allCorrMat= [preCorr,onsetCorr,onsetCorrBC,offsetCorr,offsetCorrBC];
for i=1: size(allCorrMat,1)
    for j=1: size(allCorrMat,2)
        allCorrMat_z(i,j)= atanh(allCorrMat(i,j));
    end
end

for j= 1: size(allCorrMat_z,2)
    [hZ(j), pZ(j),ci,stats]= ttest(allCorrMat_z(:,j)); % SHOULD WE REPORT THE T?
    allStats(j)= stats.tstat;
    meanCorr(j)= nanmean(allCorrMat(:,j));
end

corrStats__residuals_random= [hZ;pZ;allStats; meanCorr;nan(1,7);allCorrMat];


%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot((-199:1:1000), nanmean(all_onsetMat), 'black', 'Linewidth', 1.5)
xlabel('Time from onset (ms)');
ylabel('Pupil size change (mm)');


options.handle=figure;
options.error = 'sem';
options.color_line = [ 0 0 0]./255;
options.color_area = [243 169 114]./255;
options.alpha = 0.5;
options.line_width = 4;
options.x_axis= -199:1000
plot_areaerrorbar(all_onsetMat, options)

xlabel('Time from onset (ms)');
ylabel('Pupil size change (mm)');


