
%% lONG AND SHORT OFFSET STRUCTURE 

subvec= [133,136:138,140:144,146:147,149:157]; % Random partcipants index
%subvec= [111,113:117,119:125,127:130,134];% Fixed partcipants index
% Upper and lower trial percents
upperCutoff= 25;
lowerCutoff= 25;

for par=1:length(subvec);
s= subvec(par)
%load(['handles_' num2str(s),'b.mat']);
load(['wholeMat_SP', num2str(s)]);
fileName=  (['SP_',num2str(s),'.vhdr']);

timeDurVec=[];
for i=1:size(wholeMat.trial,2);
    timeDurVec(i,1)= wholeMat.time{1,i}(1,end);
end
timeDurVec=[timeDurVec,(1:400)'];
sortedTrials= sortrows(timeDurVec,1);
aboveMin= sortedTrials(find(sortedTrials(1:end,1)> 1),:);

shortTrials = aboveMin(1:length(aboveMin)/4,:);
longTrials =aboveMin(((length(aboveMin)/4)*3)+1:end,:);

shortTrialsMean(par,1)= nanmean(shortTrials(:,1),1);
longTrialsMean(par,1)= nanmean(longTrials(:,1),1);
%% Baseline correction

cfg=[];
cfg.subject= s;
cfg.dataset     = fileName;
cfg.headerfile=   fileName;
cfg.detrend = 'yes';
cfg.demean = 'yes';
cfg.baselinewindow  = [-0.5 0];
wholeMat_BC = ft_preprocessing(cfg, wholeMat);

matToBin= wholeMat_BC;

%% Binning the trials without standardizing, to either short or long trials,
wholeBinned_lower=[];
for tr=1:length(shortTrials)
 for e=1:size(matToBin.trial{1,tr},1);
     if (size(matToBin.trial{1,shortTrials(tr,2)},2)>1500); % 1000 ms minimum trial length 
         for b = 1: 800 % last 800 ms  
         wholeBinned_lower{1,e}(tr,b)= matToBin.trial{1,shortTrials(tr,2)}(e,end-800+b);
         end
     else
         for b = 1: 800 % last 800 ms
         wholeBinned_lower{1,e}(tr,b)= NaN;
         end
     end
end
end
% Computing trial structure of the raw activity across all trial
trialStruct_lower=[];
 for elec=1:size(wholeBinned_lower,2);
        for bin=1:size(wholeBinned_lower{1,elec},2);
        trialStruct_lower(elec,bin)= nanmean(wholeBinned_lower{1,elec}(:,bin));
        end       
 end

eachPar_trialStruct_lower{par}= trialStruct_lower;

wholeBinned_upper=[];
for tr=1:length(longTrials)
 for e=1:size(matToBin.trial{1,tr},1);
     if (size(matToBin.trial{1,longTrials(tr,2)},2)>1500);
         for b = 1: 800 % last 800 ms  
         wholeBinned_upper{1,e}(tr,b)= matToBin.trial{1,longTrials(tr,2)}(e,end-800+b);
         end
     else
         for b = 1: 800 % last 800 ms
         wholeBinned_upper{1,e}(tr,b)= NaN;
         end
     end
end
end

% Computing trial structure of the raw activity across all trial
trialStruct_upper=[];
 for elec=1:size(wholeBinned_upper,2);
        for bin=1:size(wholeBinned_upper{1,elec},2);
        trialStruct_upper(elec,bin)= nanmean(wholeBinned_upper{1,elec}(:,bin));
        end       
 end

eachPar_trialStruct_upper{par}= trialStruct_upper;
end 
% 
%% Averaging trial structure across all participants
for elec=1:size(trialStruct_lower,1) % for each electrode
for bin= 1:size(trialStruct_lower,2)  % for each time bin
   input=[]; % raw
   for par=1:size(eachPar_trialStruct_lower,2)
        input= [input, eachPar_trialStruct_lower{par}(elec,bin)]; 
   end
   allPar_trialStruct_lower(elec,bin)= nanmean(input); 
 
end
end
       
figure
imagesc(allPar_trialStruct_lower(:,401:end), 'XData', [-400, 0]);
colorbar
caxis([-3 3]);
title({['Short trials']});
xlabel('time before offset')
ylabel('electrodes')
colormap(parula)
saveas(gcf,'amp_offset_short.pdf')

for elec=1:size(trialStruct_upper,1) % for each electrode
for bin= 1:size(trialStruct_upper,2)  % for each time bin
   input=[]; % raw
   for par=1:size(eachPar_trialStruct_upper,2)
        input= [input, eachPar_trialStruct_upper{par}(elec,bin)]; 
   end
   allPar_trialStruct_upper(elec,bin)= nanmean(input); 
end
end
       
figure
imagesc(allPar_trialStruct_upper(:,401:end), 'XData', [-400, 0]);
colorbar
caxis([-3 3]);
title({['Long trials']});
xlabel('time before offset')
ylabel('electrodes')
colormap(parula)
saveas(gcf,'amp_offset_long.pdf')

% Plot electrode groups
SP_groupingElectrodes

figure
plot((-400:-1),(nanmean(allPar_trialStruct_lower([middleElectrodes],401:end))),'linewidth',2.5,'color',[0.70 0.50 0.90])
hold on
plot((-400:-1),(nanmean(allPar_trialStruct_upper([middleElectrodes],401:end))),'linewidth',2.5,'color',[0.4940 0.1840 0.5560])
hold on 
plot((-400:-1),zeros(1,400),'color','black')
legend( 'Short','Long', 'Location','Northeast')
title({['middleElectrodes']});
 ylim([-1.5, 1.5])
 xlabel('time before offset')
ylabel('amplitude')
saveas(gcf,'off_middleElectrodes.pdf')

%% topography
[timelock_all] = ft_timelockanalysis(cfg, wholeBCMat)
grouped= nan(size(allPar_trialStruct_lower,1),2);
grouped(:,1)= nanmean(allPar_trialStruct_lower(:,601:650),2);
grouped(:,2)= nanmean(allPar_trialStruct_upper(:,601:650),2);

matToPlot= timelock_all;
matToPlot.avg= grouped;
matToPlot.time= [1,2];

figure
trialPart= [{'lower'},{'upper'} ];
suptitle({['601:650']});
for t=1:2
    cfg=[];
 cfg.time= t;  
cfg.xlim         = [(t) (t)];
cfg.layout       = 'EEG1020.lay';
subplot(1,2,t)
ft_topoplotER(cfg, matToPlot);
colormap(parula)
caxis([-2  2]);
title(trialPart{t},'Position', [-1, 0, 0]);
hold on
end
colorbar


