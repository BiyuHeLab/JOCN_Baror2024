
%% Finding Partial correlations between residuals,absolute ERP and offset pupil size
%% wrtiten by Shira Baror, April 20th
subvec= [111,113:117,119:125,127:130,134];  % Fixed dataset' serial numbers

addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/Eye tracking analysis') %subfunctions

subvec= [133, 136:138,140:144,146:147,149:157];% Random participants indexes
load('timeDurVecEEG_random.mat')% Load Random durations
SP_groupingElectrodes; % Load electrode groups

for p=1:length(subvec);
s= subvec(p)
load(['handles_' num2str(s),'b.mat']);
load(['preStimMat_SP', num2str(s)]);
fileName=  (['SP_',num2str(s),'.vhdr']);
%% Variable 1- serial order
%serial order
timeDurVec= (1:size(preStimMat.trial,2))';
timeDurDur= timeDurVecEEG(1:size(preStimMat.trial,2),p);
timeDurVec(1,1)=NaN;
timeDurVec(101,1)=NaN;
timeDurVec(201,1)=NaN;
timeDurVec(301,1)=NaN;
% Excluding too short or no response trials
for i=1:length(timeDurVec)
    if timeDurDur(i,1)<1500;
        timeDurVec(i,1)=NaN;
    end
    if timeDurDur(i,1)>10000
        timeDurVec(i,1)=NaN;
    end
end


%% Variable 2- Baseline Alpha

numOfTrials= size(preStimMat.trial,2);
all_AlphaVec=[];
all_timeDurVec=[];
onsetPspctAllTrials=[];

for tr=1:numOfTrials;
cfg = [];
cfg.channel    =  posteriorElectrodes;
cfg.method     = 'wavelet';
cfg.trials  = tr;
cfg.foi        =0.05:1:35;
cfg.width      = linspace(3,9,length(cfg.foi));
cfg.output     = 'pow';
cfg.toi        = -1:0.05:1; % to start in zero
TFR_onset= ft_freqanalysis(cfg, preStimMat); 

    cfg  = [];
    cfg.baselinetype = 'absolute';
    cfg.baseline     = [-0.7 -0.2];
    abcTFR_onset     = ft_freqbaseline(cfg, TFR_onset);

onsetPspctAllTrials{1,tr} = TFR_onset.powspctrm;
alpha_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials{1,tr}(:,8:13,26:37))));
end


%% Variable 3- Pupil size at offset

%% 3. creating indexMat with onset and offset of trials
[trialIndex]=[];
load(['results\data_', num2str(s),'.mat']);    
load(['results\events_', num2str(s),'.mat']); 
[trialIndex]= SP_ET_trialIndex(s,data,events);

preLength= 1000;
[preMat , meanPreVec ]= SP_ET_pupilSizePre(data,trialIndex, preLength);
onsetLength=1000;
onsetMat=[];
onsetMat_baseCor=[];
meanOnsetVec=[] ;
meanOnsetVec_baseCor=[];
[onsetMat , onsetMat_baseCor , meanOnsetVec , meanOnsetVec_baseCor ]= SP_ET_pupilSizeOnset(data,trialIndex, meanPreVec, onsetLength);


%% COMPUTING PARTIAL CORRELATIONS
variablesExamined= [timeDurVec, alpha_Vec, meanOnsetVec];

[rho,pval] = partialcorr(variablesExamined, 'Type','Spearman','Rows', 'complete');

eachPar_serialOrder_partialCorrelations_rho{1,p}= rho;
eachPar_serialOrder_partialCorrelations_pval{1,p}= pval;
end


for p=1:size(eachPar_serialOrder_partialCorrelations_rho,2)
    rho_AllPar(p,1)= eachPar_serialOrder_partialCorrelations_rho{1,p}(1,2);
    rho_AllPar(p,2)= eachPar_serialOrder_partialCorrelations_rho{1,p}(1,3);
    rho_AllPar(p,3)= eachPar_serialOrder_partialCorrelations_rho{1,p}(2,3);
    pVal_AllPar(p,1)= eachPar_serialOrder_partialCorrelations_pval{1,p}(1,2);
    pVal_AllPar(p,2)= eachPar_serialOrder_partialCorrelations_pval{1,p}(1,3);
    pVal_AllPar(p,3)= eachPar_serialOrder_partialCorrelations_pval{1,p}(2,3);    
end

% Fischer Z transformation
for i=1:size(rho_AllPar,1);
    for j= 1:size(rho_AllPar,2);
       fiscerZ_rho_AllPar(i,j)= atanh(rho_AllPar(i,j));
    end
end
for i=1:size(rho_AllPar,2);
    [hPartial(i),pPartial(i), ci, stats]= ttest(fiscerZ_rho_AllPar(:,i));
    statistic(i)=stats.tstat;
    meanPartialCor(i)=nanmean(rho_AllPar(:,i));
end

partialCorrMat_serialOrder_rand= [hPartial;pPartial;statistic;meanPartialCor;nan(1,size(hPartial,2)); rho_AllPar];


bar(meanPartialCor);
ylabel('Partial Spearman Correlction')
set(gca,'Xticklabel',{'Serial Order- Alpha','Serial Order-Pupil Size','Alpha-Pupil Size'});
title ('Partial Correlctions between Serial Order, Alpha and Pupil Size');

