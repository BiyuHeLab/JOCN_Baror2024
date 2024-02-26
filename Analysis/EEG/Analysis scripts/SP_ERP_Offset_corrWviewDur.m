
%% SCRIPT FOR COMPUTING abs ERPs at offset as a function of image condition


addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %subfunctions


%subvec= [111,113:117,119:125,127:130,134];  % Fixed dataset participants
subvec= [133, 136:138,140:144,146:147,149:157]; % Random dataset participants
load('allSortedResiduals_eeg_rand.mat')% Load Random residuals
binNum= 20; % number of bins per trial
figure
suptitle({['residuals (raw)- & ERP correlations'],['Random Group (raw data)']});
for p=1:length(subvec);
s= subvec(p)
load(['handles_' num2str(s),'b.mat']);
load(['wholeMat_SP', num2str(s)]);
fileName=  (['SP_',num2str(s),'.vhdr']);

%timeDurVec= (1:400)'
timeDurVec= allSortedResiduals(:,p);

  timeDurVec(1,1)=NaN;
timeDurVec(101,1)=NaN;
timeDurVec(201,1)=NaN;
timeDurVec(301,1)=NaN;
 

%Baseline correction 
cfg=[];
cfg.subject= s;
cfg.dataset     = fileName;
cfg.headerfile=   fileName;
cfg.detrend = 'yes';
cfg.demean = 'yes';
cfg.baselinewindow  = [-0.5 0];
wholeMat_BC = ft_preprocessing(cfg, wholeMat);


%% Taking the offset part of the trial 
offsetRaw=[];
samplesPerBin= 50;
offsetDuration= 400;
binNum= offsetDuration/samplesPerBin;

for tr=1:length(wholeMat_BC.trial)
  for e=1:size(wholeMat_BC.trial{1,tr},1);
    
    for b = 1: binNum % offset  
          if length(wholeMat.trial{tr})>1500;
                offsetRaw{1,tr}(e,b)= nanmean(wholeMat_BC.trial{1,tr}(e, (end-400+ b*samplesPerBin-samplesPerBin+1) :  (end-400+ b*samplesPerBin)));
          else
                offsetRaw{1,tr}(e,b)= NaN;
          end              
    end
  end       
end

%% Imlementing an abs transformation to the ERP
for tr=1:size(offsetRaw,2)
  for e=1:size(offsetRaw{1,tr},1)% for every electrode   
    for b = 1: binNum % onsetbins 
                offsetRaw{1,tr}(e,b)= abs(offsetRaw{1,tr}(e,b));                
    end
  end       
end


%% Average activity across electrodes and compute correlation with viewing duration
allElect= [];
 for i=1:size(offsetRaw,2); % number of trials
        for j=1:size(offsetRaw{1,1},2); % number of bins
        allElect(i,j)= nanmean(offsetRaw{1,i}(:,j));
        end       
 end
 for j=1:size(allElect,2);
    [R,P] = corr(allElect(:,j),timeDurVec,'rows','complete', 'Type', 'Pearson');
    corrT(p,j)= R;
    pT(p,j)= P;
 end

%% Computing correlation between viewing duration and activity in every time-bin, in every electrode
eachElect = []; % 
for e=1:size(offsetRaw{1,1},1) % number of electrodes
 for t=1:size(offsetRaw{1,1},2); % number of bins
        for i=1:length(offsetRaw); % number of trials
        eachElect{1,e}(i,t)= offsetRaw{1,i}(e,t); 
        end

    [R,P] = corr(eachElect{1,e}(:,t),timeDurVec,'rows','complete', 'Type', 'Pearson');
    e_corrT(e,t)= R;
    e_pT(e,t)= P;
 end
end
corrSigMat= zeros(size(e_pT,1), size(e_pT,2));
sigMat= zeros(size(e_pT,1), size(e_pT,2));
for i=1:size(sigMat,1);
    for j=1:size(sigMat,2);
        if e_pT(i,j)<0.05;
            sigMat(i,j)=1;
            corrSigMat(i,j)=e_corrT(i,j);
        end
    end
end
    hold on
    subplot (4,5,p)
 imagesc(corrSigMat,'XData', [-400, 0])
 title(['SP', num2str(s)]);
 colormap(jet);
colorbar;
%caxis([-0.02 0.02]);
eachPar_all_Offset{p}=allElect;
eachPar_all_CorrT(p,:)= corrT(p,:);
eachPar_all_pT(p,:)= pT(p,:);
eachPar_e_CorrT{p}= e_corrT;
eachPar_e_pT{p}= e_pT;
eachParSigMat{p}= corrSigMat;
end

%% Testing for significance in correlation between ERPs across all electrodes and viewing duration at each time bin.
% Fischer Z transforming
corrT_z= nan(size(corrT,1),size(corrT,2));
for i= 1:size(corrT,1);
    for j= 1:size(corrT,2);
        zTrans= atanh(corrT(i,j));
        corrT_z(i,j)= zTrans;
    end
end
hZ= nan(1,size(corrT,2));
pZ= nan(1,size(corrT,2));
for i=1:size(corrT_z,2);
    [hZ(i), pZ(i),ci,stats]= ttest(corrT_z(:,i)); 
    allStats(i)= stats.tstat;
end
figure    
plot((-400:50:-1),allStats);
xlabel('Time in trial');
ylabel('t-statistic');
% colormap(jet)
% colorbar
title({['ERP-correlation between average across electrodes and viewDur'] ['(Random Group)']})

figure    
plot((-400:50:-1),hZ);
xlabel('Time in trial');
ylabel('H');
% colormap(jet)
% colorbar
title({['ERP-correlation between average across electrodes and viewDur'] ['(Random Group)']})

figure    
plot((-400:50:-1),pZ);
%ylim([0 0.1])
xlabel('Time in trial');
ylabel('p-Value');
% colormap(jet)
% colorbar
title({['ERP-significance of correlation between average across electrodes and viewDur'] ['(Random Group)']})
nanmean(corrT)

[h, crit_p, adj_ci_cvrg, adj_p]= fdr_bh(pZ,0.05,'pdep','yes')

%% Testing for significance in correlation between viewing duration and ERPs IN EACH electrode and at each time bin.

%Fischer Z transform- SEPARATE FOR EACH ELECTRODE

eachChan_corrT= cell(1,size(e_corrT,1));
for e= 1:size(e_corrT,1); % each electrode
    for p=1:length(subvec); % each participant
        for t= 1: size(e_corrT,2); %each time bin
eachChan_corrT{1,e}(p,t)= eachPar_e_CorrT{1,p}(e,t);
        end
    end
end

eachChan_corrT_z= cell(1,size(e_corrT,1));
for e= 1:size(e_corrT,1);
    for p=1:length(subvec);
        for t= 1: size(e_corrT,2);
eachChan_corrT_z{1,e}(p,t)= atanh(eachChan_corrT{1,e}(p,t));
        end
    end
end

e_hZ= zeros(length(eachChan_corrT_z), size(corrT,2));
e_pZ= zeros(length(eachChan_corrT_z), size(corrT,2));
e_sigZ= zeros(length(eachChan_corrT_z), size(corrT,2));
 e_Tstat= zeros(length(eachChan_corrT_z), size(corrT,2));
for i=1:size(e_hZ,1); % each electrode
    for j=1:size(e_hZ,2); % each time bin
    [e_hZ(i,j), e_pZ(i,j),ci, stats]= ttest(eachChan_corrT_z{1,i}(:,j));
    

    if e_pZ(i,j)<0.05
    e_sigZ(i,j)= nanmean(eachChan_corrT_z{1,i}(:,j));
    e_Tstat(i,j)= stats.tstat;
   end
    end
end
figure
imagesc(e_sigZ,'XData', [-400, 0])
xlabel('Time before offset');
ylabel('Electrodes');
colormap(parula)
colorbar
caxis([0 0.32]);
title({['ERP (BC)-residuals-correlations (mean r)'] ['(Random Group, sig. correlations)']})

figure
imagesc(e_Tstat,'XData', [-400, 0])
xlabel('Time before offset');
ylabel('Electrodes');
colormap(jet)
colorbar
title({['ERP-viewDur correlations (t-statistic)'] ['(Random Group, all correlations)']})


[l,m]=stdshade(corrT_z(:, 1:8),0.4, [0,0.2,0.8]);
%Bins where mean all were significant
onePartMat= nan(size(e_Tstat,1), 1);
onePartMat(:,1)= nanmean(e_Tstat(:,1:8),2);
%threePartsMat(:,2)= nanmean(e_sigZ(:,13:19),2);

% Plotting topographies of the correlations (OR THE T-STATISTIC?)
cfg=[];
cfg.channel            = 'all';
cfg.trials             = 'all';
[timelock_all] = ft_timelockanalysis(cfg, wholeBCMat);
matToPlot= timelock_all; % timelock all is needed here to later run ft_topoplotER.
matToPlot.avg= onePartMat;
matToPlot.time= [1]; %,

figure
trialPart= [{'-400:0ms'}];
suptitle({['ERP-viewDur-Correlations Topography (mean r)']  ['(Random Group, all correlations)']});

cfg=[];
cfg.xlim         = [(1) (1)];
cfg.layout       = 'EEG1020.lay';
ft_topoplotER(cfg, matToPlot);
caxis([-3.5 3.5]);
colorbar
