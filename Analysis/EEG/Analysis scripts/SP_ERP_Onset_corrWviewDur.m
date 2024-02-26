
%% SCRIPT FOR COMPUTING CORRELATION BETWEEN ONSET ERPs AND VIEWING DURATION 

%subvec= [111,113:117,119:125,127:130,134]; % Fixed participants'  numbers
subvec= [133, 136:138,140:144,146:147,149:157];% Random participants'  numbers
load('allSortedResiduals_eeg_rand.mat')% Load Random residuals

figure

for p=1:length(subvec);
s= subvec(p)
load(['handles_' num2str(s),'b.mat']);
load(['wholeMat_SP', num2str(s)]);
fileName=  (['SP_',num2str(s),'.vhdr']);
%timeDurVec= (1:400)';
timeDurVec= allSortedResiduals(:,p);

% Excluding first trial in each block
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
 
 %% Taking the onset part of the trial 
onsetRaw=[];
samplesPerBin= 50;
onsetDuration= 600;
binNum= onsetDuration/samplesPerBin;
for tr=1:length(wholeMat_BC.trial)
  for e=1:size(wholeMat_BC.trial{1,tr},1)% for every electrode
    
    for b = 1: binNum % onsetbins 
          if length(wholeMat_BC.trial{tr})>1500;
                onsetRaw{1,tr}(e,b)= nanmean(wholeMat_BC.trial{1,tr}(e, (b*samplesPerBin-samplesPerBin+501):( b*samplesPerBin+501)));
          else
                onsetRaw{1,tr}(e,b)= NaN;
          end              
    end
  end       
end

%% Imlementing an abs transformation to the ERP
for tr=1:size(onsetRaw,2)
  for e=1:size(onsetRaw{1,tr},1)% for every electrode   
    for b = 1: binNum % onsetbins 
                onsetRaw{1,tr}(e,b)= abs(onsetRaw{1,tr}(e,b));                
    end
  end       
end



%% Average activity across electrodes and compute correlation with viewing duration
allElect= [];
 for i=1:size(onsetRaw,2); % number of trials
        for j=1:size(onsetRaw{1,1},2); % number of bins
        allElect(i,j)= nanmean(onsetRaw{1,i}(:,j));
        end       
 end
 for j=1:size(allElect,2);
    [R,P] = corr(allElect(:,j),timeDurVec,'rows','complete', 'Type', 'Pearson');
    corrT(p,j)= R;
    pT(p,j)= P;
 end

%% Computing correlation between viewing duration and activity in every time-bin, in every electrode
eachElect = []; % 
for e=1:size(onsetRaw{1,1},1) % number of electrodes
 for t=1:size(onsetRaw{1,1},2); % number of bins
        for i=1:size(onsetRaw,2); % number of trials
        eachElect{1,e}(i,t)= onsetRaw{1,i}(e,t); 
        end
    [R,P] = corr(eachElect{1,e}(:,t),timeDurVec,'rows','complete', 'Type','Pearson' );
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
 imagesc(corrSigMat,'XData', [0, 600])
 title(['SP', num2str(s)]);
 colormap(jet);
colorbar;
%caxis([-0.02 0.02]);
eachPar_all_Onset{p}=allElect;
eachPar_all_CorrT(p,:)= corrT(p,:);
eachPar_all_pT(p,:)= pT(p,:);
eachPar_e_CorrT{p}= e_corrT;
eachPar_e_pT{p}= e_pT;
eachParSigMat{p}= corrSigMat;
s= subvec(p)
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
    [hZ(i), pZ(i),ci,stats]= ttest(corrT_z(:,i)); % 
    allStats(i)= stats.tstat;
    allCorr(i)= nanmean(corrT(:,i));
end
figure    
plot((1:50:600),allStats);
xlabel('Time in trial(ms)');
ylabel('t-statistic');
% colormap(jet)
% colorbar
title({['ERP-correlation between average across electrodes and residuals'] ['(Random Group)']})

figure    
plot((1:50:600),allCorr);
xlabel('Time in trial(ms)');
ylabel('R Pearson');
% colormap(jet)
% colorbar
title({['ERP- Residuals correlation'] ['average across electrodes']})

figure    
plot((1:50:600),hZ,'black', 'Linewidth', 1 );
xlabel('Time in trial (ms)');
ylabel('H');
% colormap(jet)
% colorbar
title({['ERP-significance of correlation between average across electrodes and residuals'] ['(Random Group)']})



[h, crit_p, adj_ci_cvrg, adj_p]= fdr_bh(pZ,0.05,'pdep','yes')

%% Cluster analysis for Onset ERPs
%defining the parameters
p_thresh=0.05;
n_perms=10000;
n_sample=length(pZ);%length of the sampling we're interested in
 
orig_clusters= find_temporal_clusters(allStats, pZ, p_thresh); 
forShuffle_AllElec= eachPar_all_Onset; 
[orig_clusters, clusters_shuffle, shuffleMaxStat] = onsetERP_cluster_test_temp(orig_clusters, forShuffle_AllElec, allSortedResiduals, p_thresh, n_sample, n_perms,subvec);
 



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
imagesc(e_sigZ,'XData', [0, 600])
xlabel('Time in trial');
ylabel('Electrodes');
colormap(parula)
colorbar
caxis([0 .32]);
title({['ERP (BC)- viewing duration correlations (mean r)'] ['(Random Group, all correlations)']})

figure
imagesc(e_Tstat,'XData', [1, 600])

xlabel('Time in trial');
ylabel('Electrodes');
colormap(jet)
colorbar
title({['ERP-redisuals correlations (t-statistic)'] ['(Random Group, all correlations)']})


%% Corr. for each participant
figure
for i=1:20
    hold on
plot((1:50:600),corrT(i,:)', 'linewidth',2);
end
plot((1:50:600),nanmean(corrT,1)', 'linewidth',2.5,'color','black');
hold on
plot((1:600),zeros(1,600),'color','black','linewidth',1.5)
ylim([-0.6  0.6])
xlabel('Time in trial(ms)');
ylabel('Pearson R');
title({['abs ERP-viewing duration correlations'] ['(average accross electrodes)']})
figure
[l,m]=stdshade(corrT(:, 1:12),0.4, [0,0.2,0.8]);


