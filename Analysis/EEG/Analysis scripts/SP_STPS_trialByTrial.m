%% TRIAL BY TRIAL RDM
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %subfunctions
subvec= [133, 136:138,140:144,146:147,149:157]; % participants index in the random data set
%subvec= [111,113:117,119:125,127:130,134]; % participants index in the fixed data set
load('allSortedResiduals_eeg_rand.mat')% Load Random residuals
load('timeDurVecEEG_random.mat') % Load Random viewing durations
numOfTrials= 400;
allPar_fullMatBinned=[]; 
 
timeDurVecEEG= allSortedResiduals
samplesPerBin= 50;


for par=1:length(subvec);
s= subvec(par);
 load(['handles_' num2str(s),'b.mat']);
load(['wholeMat_SP', num2str(s)]);
fileName=  (['SP_',num2str(s),'.vhdr']);

%% Baseline correction

cfg=[];
cfg.subject= s;
cfg.dataset     = fileName;
cfg.headerfile=   fileName;
cfg.detrend = 'yes';
cfg.demean = 'yes';
cfg.baselinewindow  = [-0.5 0];
wholeMat_BC = ft_preprocessing(cfg, wholeMat);


for tr=1:length(wholeMat_BC.trial)   
    numOfBins= floor(wholeMat_BC.time{1,tr}(1,end)*1000/samplesPerBin);
    fullBinned=[];
        % matForstps
     for e=1:size(wholeMat_BC.trial{1,tr},1)% for every electrode 
     for b = 1: numOfBins-1 % onsetbins 
                fullBinned(e,b)= nanmean(wholeMat_BC.trial{1,tr}(e, (b*samplesPerBin-samplesPerBin+501):( b*samplesPerBin+501)));
     end
        fullBinned(e,b+1)= nanmean(wholeMat_BC.trial{1,tr}(e, ((b+1)*samplesPerBin-samplesPerBin+501):end));
     end
     
     eachPar_fullBinned{par,tr}=fullBinned;
    
    rdmMat=[];
    for n=1:size(fullBinned,2)
        for m=1:size(fullBinned,2);
            [r,p]= corr(fullBinned(:,n),fullBinned(:,m),'rows','complete','Type', 'Spearman');
            rdmMat(n,m)= r;
        end
    end
    
    eachPar_rdm{par,tr}=rdmMat;
     
end

end

eachPar_rdmByLenght=[];
    startingPoint=0; % where do we start to look for correlations
    windowSize= 200; % length of the sliding windw
for shift=0:44; 
for par=1:length(subvec)
    inputStruct=[];
    rdmByLength=[]; 
    for t=1:size(eachPar_rdm,2);
    inputStruct (t,1)= t;    
    inputStruct (t,2)= size(eachPar_rdm{par,t},2);
    end
    rdmByLength= sortrows(inputStruct,2);
    rdmByLength= rdmByLength(find(rdmByLength(:,2)>=48),:); % only trials longer than 2500 ms
    
    %% EXPLORING CORRELATIONS BETWEEN stps AT X TIMEPOINT AND VIEWING DURATION
    % using a sliding window of 200 ms
    midSimilarity=[];
    for t=1:length(rdmByLength)
        rsmCurrent= triu(eachPar_rdm{par,rdmByLength(t,1)});
        for n=1:size(rsmCurrent,1)
            rsmCurrent(n,n)=NaN;
            rsmCurrent(n,find(rsmCurrent(n,:)==0))=NaN;
        end

        selectedWindow= startingPoint/samplesPerBin+shift+1:(startingPoint+windowSize)/samplesPerBin +shift;
        rsmSelected= rsmCurrent(selectedWindow,selectedWindow);
        midSimilarity(t,2)= nanmean(reshape(rsmSelected,size(rsmSelected,1)*size(rsmSelected,2),1));
        midSimilarity(t,1)= allSortedResiduals(rdmByLength(t,1),par);
        if midSimilarity(t,1)>10000; % excluding no-response trials
           midSimilarity(t,1)=NaN;
        end
    end
% 

    
    [r,p]= corrcoef(midSimilarity(:,2),midSimilarity(:,1),'rows', 'complete');
    rVal(par,shift+1)=r(1,2);
    pVal(par,shift+1)=p(1,2);
     
end
end

% Fischer Z transformation
for i=1:size(rVal,1);
  for j=1:size(rVal,2);
      z_rVal(i,j)= atanh(rVal(i,j));
  end
end

 for i=1:size(rVal,2);
     [h,p,ci,stats]= ttest(z_rVal(:,i));
     
     zH(i)=h;
     zP(i)=p;
     zT(i)= stats.tstat;
 end
 
 
%% Cluster permutation test for STPS significance
%defining the parameters
p_thresh=0.05;
n_perms=100;
n_sample=length(zH);%length of the sampling we're interested in
 
orig_clusters= find_temporal_clusters(zT, zP, p_thresh); 
forShuffle_AllElec= eachPar_rdm; 
[orig_clusters, clusters_shuffle, shuffleMaxStat] = stps_cluster_test_temp(orig_clusters, forShuffle_AllElec, allSortedResiduals, p_thresh, n_sample, n_perms,startingPoint, windowSize,subvec,samplesPerBin);
 
zH=zH';
zP=zP';
zT=zT';
rVal= nanmean(rVal)';
z_rVal= nanmean(z_rVal)';
corrWithResiduals= table(zH,zP,zT,rVal,z_rVal);

% FDR test for significance
[h, crit_p, adj_ci_cvrg, adj_p]= fdr_bh(zP,0.05,'pdep','yes')

  
% Plot
  plot(0:50:2200, (corrWithResiduals.zT))
  ylabel('t')
  figure
  imagesc(zT');
    
    

  
  
   for par=1:20 
    eachPar_rdmByLenght{par,1}= eachPar_rdm{par,rdmByLength(1)};
    ind=1;
    while  sum(sum(isnan(eachPar_rdmByLenght{par,1})))>0
        eachPar_rdmByLenght{par,1}= eachPar_rdm{par,rdmByLength(1+ind)};
        ind=ind+1;
    end
    
    eachPar_rdmByLenght{par,2}= eachPar_rdm{par,rdmByLength(floor(length(rdmByLength)/2))};
    ind=1;
    while  sum(sum(isnan(eachPar_rdmByLenght{par,2})))>0
    eachPar_rdmByLenght{par,2}= eachPar_rdm{par,rdmByLength(floor(length(rdmByLength)/2)+ind)};
    ind=ind+1;
    end
    
    eachPar_rdmByLenght{par,3}= eachPar_rdm{par,rdmByLength(length(rdmByLength))};
    ind=1;
    while  sum(sum(isnan(eachPar_rdmByLenght{par,3})))>0
    eachPar_rdmByLenght{par,3}= eachPar_rdm{par,rdmByLength(length(rdmByLength)-ind)};
    ind=ind+1;
    end
    
end
 

    
    







    
    

