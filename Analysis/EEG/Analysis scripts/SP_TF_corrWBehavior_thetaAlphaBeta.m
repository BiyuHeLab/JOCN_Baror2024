%% EXPLORING THE CORRELATION BETWEEN onset TRIAL-FREQUENCY AND VIEWING DURATION
%reviewed by Shira Baror, Feb. 25,2022.
% SP- onset trial Time-frequency analysis, and its correlation with viewing
% duration, devided into frequency bands

addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %subfunctions

 load('timeDurVecEEG_random.mat')% viewing duration Random
subvec= [133, 136:138,140:144,146:147,149:157];% participants index RANDOM
%subvec= [111,113:117,119:125,127:130,134]; % participants index FIXED


numOfTrials= 400;

all_ThetaBCVec=[];
all_AlphaBCVec=[];
all_BetaBCVec=[];
all_ThetaVec=[];
all_AlphaVec=[];
all_BetaVec=[];
all_timeDurVec=[];


for p=1:length(subvec);
s= subvec(p)
load(['handles_' num2str(s),'b.mat']);
load(['preStimMat_SP', num2str(s)]); % prestimulus time frame
load(['wholeMat_SP', num2str(s)]); % whole trial

SP_groupingElectrodes;

fileName=  (['SP_',num2str(s),'.vhdr']);


%timeDurVec= allSortedResiduals(:,p); % CORR WITH RESIDUALS
timeDurVec= (1:400)'; % CORR WITH SERIAL ORDER
  timeDurVec(1,1)=NaN;
timeDurVec(101,1)=NaN;
timeDurVec(201,1)=NaN;
timeDurVec(301,1)=NaN;

%% EXCLUDING TRIALS THAT ARE SHORTER THAN 1500MS
timeDurDur= timeDurVecEEG(:,p);
for i=1:length(timeDurVec)
    if timeDurDur(i,1)<1500;
        timeDurVec(i,1)=NaN;
    end
    if timeDurDur(i,1)>10000
        timeDurVec(i,1)=NaN;
    end
end

all_timeDurVec= [all_timeDurVec;timeDurVec];
%% time frequency

onsetPspct    = [];
onsetPspctAllTrials=[];

for tr=1:numOfTrials;
cfg = [];
cfg.channel    =  posteriorElectrodes;
cfg.method     = 'wavelet';
cfg.trials  = tr;
cfg.foi        =0.05:1:35;
cfg.width      = linspace(3,9,length(cfg.foi));
cfg.output     = 'pow';
cfg.toi        = -1:0.05:1; % 
TFR_onset= ft_freqanalysis(cfg, preStimMat); 

    cfg  = [];
    cfg.baselinetype = 'absolute';
    cfg.baseline     = [-0.7 -0.2];
    abcTFR_onset     = ft_freqbaseline(cfg, TFR_onset);


onsetPspctAllTrials{1,tr} = TFR_onset.powspctrm;
onsetPspctAllTrials_bc{1,tr} = abcTFR_onset.powspctrm;


theta_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials{1,tr}(:,4:8,21:25))));
thetaBC_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials_bc{1,tr}(:,4:8,21:25))));

alpha_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials{1,tr}(:,8:13,26:37))));
alphaBC_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials_bc{1,tr}(:,8:13,26:37))));

beta_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials{1,tr}(:,15:25,26:37))));
betaBC_Vec(tr,1)= nanmean(nanmean(nanmean(onsetPspctAllTrials_bc{1,tr}(:,15:25,26:37))));

end
%% Baseline corrected
% theta
   [R,P] = corr(thetaBC_Vec,timeDurVec,'rows','complete', 'Type','Spearman');
   thetaBCCorr(p,1)= R;
    thetaBCCorr_p(p,1)= P;
    all_ThetaBCVec=[all_ThetaBCVec;thetaBC_Vec];
% alpha
   [R,P] = corr(alphaBC_Vec,timeDurVec,'rows','complete', 'Type','Spearman');
   alphaBCCorr(p,1)= R;
    alphaBCCorr_p(p,1)= P;
    all_AlphaBCVec=[all_AlphaBCVec;alphaBC_Vec];
% beta
   [R,P] = corr(betaBC_Vec,timeDurVec,'rows','complete', 'Type','Spearman');
   betaBCCorr(p,1)= R;
    betaBCCorr_p(p,1)= P;
    all_BetaBCVec=[all_BetaBCVec;betaBC_Vec];

%% Uncorrected
% theta
   [R,P] = corr(theta_Vec,timeDurVec,'rows','complete', 'Type','Spearman');
   thetaCorr(p,1)= R;
    thetaCorr_p(p,1)= P;
    all_ThetaVec=[all_ThetaVec;theta_Vec];
% alpha
   [R,P] = corr(alpha_Vec,timeDurVec,'rows','complete', 'Type','Spearman');
   alphaCorr(p,1)= R;
    alphaCorr_p(p,1)= P;
    all_AlphaVec=[all_AlphaVec;alpha_Vec];
% beta
   [R,P] = corr(beta_Vec,timeDurVec,'rows','complete', 'Type','Spearman');
   betaCorr(p,1)= R;
    betaCorr_p(p,1)= P;
    all_BetaVec=[all_BetaVec;beta_Vec];
%     
end

allCorrMat= [thetaCorr,alphaCorr,betaCorr,thetaBCCorr,alphaBCCorr,betaBCCorr];
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

corrStats_TFonset_order_random = array2table([hZ;allStats; pZ;meanCorr;nan(1,6);allCorrMat]);
corrStats_TFonset_order_random.Properties.VariableNames= {'Theta' 'Alpha' 'Beta' 'ThetaChange' 'AlphaChange' 'BetaChange'};
