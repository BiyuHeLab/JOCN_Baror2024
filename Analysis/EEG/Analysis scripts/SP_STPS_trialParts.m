%% All-Times ISPC
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %subfunctions
subvec= [133, 136:138,140:144,146:147,149:157]; % Random participants index
%subvec= [111,113:117,119:125,127:130,134];

numOfTrials= 400;
allPar_onsetMatBinned_anterior=[];
allPar_onsetMatBinned_middle=[];
allPar_onsetMatBinned_posterior=[];

allPar_fullMatBinned=[];

samplesPerBin= 50;
onsetDuration= 800;
onsetBinNum= onsetDuration/samplesPerBin;
trialLengthMin=2500;
offsetDuration= 800;
offsetBinNum= offsetDuration/samplesPerBin;
middleDuration= 800;
middleBinNum= offsetDuration/samplesPerBin;
spontaneousTime=[];
for par=1:length(subvec);
s= subvec(par);
 load(['handles_' num2str(s),'b.mat']);
load(['wholeMat_SP', num2str(s)]);
load('allSortedResiduals_eeg_rand.mat')% Load Random residuals
spontaneousTime= allSortedResiduals(:,par);
%% Baseline correction

cfg=[];
cfg.subject= s;
cfg.dataset     = fileName;
cfg.headerfile=   fileName;
cfg.detrend = 'yes';
cfg.demean = 'yes';
cfg.baselinewindow  = [-0.5 0];
wholeMat_BC = ft_preprocessing(cfg, wholeMat);

fullBinned=[];
for tr=1:length(wholeMat_BC.trial)    
   for e=1:size(wholeMat_BC.trial{1,tr},1)% for every electrode 
    % onset bins  
    for b = 1: onsetBinNum % onsetbins 
          if length(wholeMat_BC.trial{tr})>trialLengthMin;
                fullBinned{1,tr}(e,b)= nanmean(wholeMat_BC.trial{1,tr}(e, (b*samplesPerBin-samplesPerBin+501):( b*samplesPerBin+501)));
          else
                fullBinned{1,tr}(e,b)= NaN;
          end              
    end
    % middle bins
        for b = 1: middleBinNum;  
      if size(wholeMat_BC.trial{1,tr},2)>= (trialLengthMin)
        middlePoint=  round((size(wholeMat_BC.trial{1,tr},2)-500)/2);
        startMiddle= 500+middlePoint-(middleBinNum/2)*samplesPerBin;
        endMiddle=  499+middlePoint+(middleBinNum/2)*samplesPerBin;
        middleSegment= wholeMat_BC.trial{1,tr}(:,  startMiddle:endMiddle);
      
         fullBinned{1,tr}(e,b+onsetBinNum)= nanmean(middleSegment(e, b*samplesPerBin-samplesPerBin+1: b*samplesPerBin));
      else
         fullBinned{1,tr}(e,b+onsetBinNum)=NaN;  
         spontaneousTime(tr,1)=NaN;
      end
     end

    % offset bins
     if length(wholeMat_BC.trial{tr})>trialLengthMin;
         tLength= length(wholeMat_BC.trial{tr});
     for b = 1: offsetBinNum ;
         fullBinned{1,tr}(e,b + onsetBinNum+middleBinNum)= nanmean(wholeMat_BC.trial{1,tr}(e, ((tLength)-offsetDuration +b*samplesPerBin-samplesPerBin+1):((tLength)- offsetDuration+ b*samplesPerBin)));
     end
         else
         fullBinned{1,tr}(e,onsetBinNum+middleBinNum+1: onsetBinNum+ middleBinNum + offsetBinNum)= NaN;
     end  
     end       
end


%% Rearranging mat for upcoming ELECTRODE PATTERN SIMILARITY  analysis
indFullBinned=[];
for tr=1:length(fullBinned)
    
for b=1:size(fullBinned{tr},2)
    for elec=1:size(fullBinned{tr},1)
        indFullBinned{b}(elec,tr)= fullBinned{1,tr}(elec,b);
    end
end
end

 allPar_fullMatBinned =[allPar_fullMatBinned; indFullBinned]; 

 meanTimeDurVec(par,1)=nanmean(spontaneousTime);
end

eachParElecPattern=[];
for par=1: size(allPar_fullMatBinned,1);
 for bin=1: size(allPar_fullMatBinned,2);
  for elec= 1:size(allPar_fullMatBinned{par,bin},1);
eachParElecPattern{1,bin}(elec,par)= nanmean(allPar_fullMatBinned{par,bin}(elec,:));
  end
 end
end


 allIntraSub=[];
 for par=1:size(eachParElecPattern{1},2)       
            intraSub=[];
            for binN=1:size(eachParElecPattern,2); 
                for binM= 1:size(eachParElecPattern,2);
            parInputM= eachParElecPattern{binM}(:,par);
            parInputN= eachParElecPattern{binN}(:,par);
            [r,p]= corrcoef(parInputM,parInputN,'rows','complete');
            intraSub (binN, binM)= [r(1,2)];
                end
            end
               allIntraSub{1,par}= intraSub;
  end 
  
 % Fischer z transforming before computing mean and ANOVA 
 for i=1:size(allIntraSub,2) 
      for m= 1: size(allIntraSub{1,i},1);
          for n= 1: size(allIntraSub{1,i},2)
          allIntraSub_z{1,i}(m,n)=atanh(allIntraSub{1,i}(m,n));
      end
  end 
 end
  
 %%eliminating the diagonal   
for i=1:1:size(allIntraSub,2)   
      for m= 1: size(allIntraSub{1,i},1);          
          allIntraSub{1,i}(m,m)=1;
      end
  end
%% EXTRACTING MENAS- FISCHER Z TRANSFORMED      
  for i=1:size(allIntraSub_z,2)   
      midmidvox= triu(allIntraSub_z{1,i}(17:32,17:32));
      midmidVec=reshape(midmidvox,256,1);
      midmidVec(find(midmidVec(:,1)==0))= NaN;
      midmid(i,1)= nanmean (midmidVec);
      
      onsetonsetvox= triu(allIntraSub_z{1,i}(1:16,1:16));
      onsetonsetVec=reshape(onsetonsetvox,256,1);
      onsetonsetVec(find(onsetonsetVec(:,1)==0))= NaN;
      onsetonset(i,1)= nanmean (onsetonsetVec);
      
      offsetonsetvox= triu(allIntraSub_z{1,i}(33:48,33:48));
      offsetonsetVec=reshape(offsetonsetvox,256,1);
      offsetonsetVec(find(offsetonsetVec(:,1)==0))= NaN;
      offsetoffset(i,1)= nanmean (offsetonsetVec);     
      
      midonsetvox= allIntraSub_z{1,i}(1:16,17:32); 
      midonset(i,1)= nanmean (reshape(midonsetvox,256,1));
      midoffsetvox= allIntraSub_z{1,i}(33:48,17:32); 
      midoffset(i,1)= nanmean (reshape(midoffsetvox,256,1));
      onsetoffsetvox= allIntraSub_z{1,i}(33:48,1:16); 
      onsetoffset(i,1)= nanmean (reshape(onsetoffsetvox,256,1));
  end
  
  trialPartMat= table(onsetonset,midmid,offsetoffset,midonset,onsetoffset, midoffset);


  
%% EXTRACTING MENAS- ORIGINAL     
  for i=1:size(allIntraSub,2)   
      midmidvox= triu(allIntraSub{1,i}(17:32,17:32));
      midmidVec=reshape(midmidvox,256,1);
      midmidVec(find(midmidVec(:,1)==0))= NaN;
      midmid(i,1)= nanmean (midmidVec);
      
      onsetonsetvox= triu(allIntraSub{1,i}(1:16,1:16));
      onsetonsetVec=reshape(onsetonsetvox,256,1);
      onsetonsetVec(find(onsetonsetVec(:,1)==0))= NaN;
      onsetonset(i,1)= nanmean (onsetonsetVec);
      
      offsetonsetvox= triu(allIntraSub{1,i}(33:48,33:48));
      offsetonsetVec=reshape(offsetonsetvox,256,1);
      offsetonsetVec(find(offsetonsetVec(:,1)==0))= NaN;
      offsetoffset(i,1)= nanmean (offsetonsetVec);     
      
      midonsetvox= allIntraSub{1,i}(1:16,17:32); 
      midonset(i,1)= nanmean (reshape(midonsetvox,256,1));
      midoffsetvox= allIntraSub{1,i}(33:48,17:32); 
      midoffset(i,1)= nanmean (reshape(midoffsetvox,256,1));
      onsetoffsetvox= allIntraSub{1,i}(33:48,1:16); 
      onsetoffset(i,1)= nanmean (reshape(onsetoffsetvox,256,1));
  end
  
trialPartMatOrig= table(onsetonset,midmid,offsetoffset,midonset,onsetoffset, midoffset);

[r,p]= corr(meanTimeDurVec,trialPartMatOrig.midmid,'Type','Spearman','row','complete')
