
%% Finding Partial correlations between residuals,absolute ERP and offset pupil size
%% wrtiten by Shira Baror, April 20th
%subvec= [111,113:117,119:125,127:130,134];  % participants' serial numbers
                                                    %in the fixed dataset

addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawdata_Behavioral') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/Eye tracking analysis') %subfunctions

subvec= [133, 136:138,140:144,146:147,149:157];% Random participants indexes
load('timeDurVecEEG_random.mat')% Load Random durations
load('allSortedResiduals_eeg_rand.mat')% Load Random residuals
for p=1:length(subvec);
    
s= subvec(p)
load(['handles_' num2str(s),'b.mat']);
load(['wholeMat_SP', num2str(s)]);
fileName=  (['SP_',num2str(s),'.vhdr']);
%% Variable 1- residuals
% residuals
timeDurVec= allSortedResiduals(:,p);
timeDurDur= timeDurVecEEG(:,p);
timeDurVec(1,1)=NaN;
timeDurVec(101,1)=NaN;
timeDurVec(201,1)=NaN;
timeDurVec(301,1)=NaN;
% Excluding too short & no-response trials
for i=1:length(timeDurVec)
    if timeDurDur(i,1)<1500;
        timeDurVec(i,1)=NaN;
    end
    if timeDurDur(i,1)>10000
        timeDurVec(i,1)=NaN;
    end
end

%% Variable 2- Absolute ERP at Offset
%%Baseline correcting the trials
%Baseline correction 
cfg=[];
cfg.subject= s;
cfg.dataset     = fileName;
cfg.headerfile=   fileName;
cfg.detrend = 'yes';
cfg.demean = 'yes';
cfg.baselinewindow  = [-0.5 0];
wholeMat_BC = ft_preprocessing(cfg, wholeMat);

% Taking the offset part of the trial 
offsetBinned=[];
samplesPerBin= 50;
offsetDuration= 400;
binNum= offsetDuration/samplesPerBin;

for tr=1:length(wholeMat_BC.trial)
  for e=1:size(wholeMat_BC.trial{1,tr},1);
    
    for b = 1: binNum % offset  
          if length(wholeMat.trial{tr})>2000 ; % 1500ms trial + 500ms baseline
                offsetBinned{1,tr}(e,b)= nanmean(wholeMat_BC.trial{1,tr}(e, (end-offsetDuration + b*samplesPerBin-samplesPerBin+1) :  (end-offsetDuration+ b*samplesPerBin)));
          else
                offsetBinned{1,tr}(e,b)= NaN;
          end              
    end
  end       
end

%% Imlementing an abs transformation to the ERP
for tr=1:size(offsetBinned,2)
  for e=1:size(offsetBinned{1,tr},1)% for every electrode   
    for b = 1: binNum % onsetbins 
                offsetAbs{1,tr}(e,b)= abs(offsetBinned{1,tr}(e,b));                
    end
  end       
end
% extracting the offset ERO magnitude vector
for tr=1:size(offsetAbs,2);
offsetAbsoluteERP(tr,1)= nanmean(nanmean(offsetAbs{1,tr}));
end

%% Variable 3- Pupil size at offset
% creating indexMat with offset eye-tracking data
[trialIndex]=[];
load(['results\data_', num2str(s),'.mat']);    
load(['results\events_', num2str(s),'.mat']); 
[trialIndex]= SP_ET_trialIndex(s,data,events);

preLength= 1000;
[preMat , meanPreVec ]= SP_ET_pupilSizePre(data,trialIndex, preLength);

preBaseVec=meanPreVec;
offsetLength=400;
offsetMat=[];
offsetMat_baseCor =[];
meanOffsetVec=[];
meanOffsetVec_baseCor=[];
[offsetMat , offsetMat_baseCor , meanOffsetPupilSize , meanOffsetPupilSize_baseCor ]= SP_ET_pupilSizeOffset(data,trialIndex, meanPreVec, offsetLength);                                                  

variablesExamined= [timeDurVec, offsetAbsoluteERP, meanOffsetPupilSize_baseCor];

[r,pval] = partialcorr(variablesExamined, 'Rows', 'complete');

eachPar_residuals_partialCorrelations_r{1,p}= r;
eachPar_residuals_partialCorrelations_pval{1,p}= pval;
end


for p=1:size(eachPar_residuals_partialCorrelations_r,2)
    r_AllPar(p,1)= eachPar_residuals_partialCorrelations_r{1,p}(1,2);
    r_AllPar(p,2)= eachPar_residuals_partialCorrelations_r{1,p}(1,3);
    r_AllPar(p,3)= eachPar_residuals_partialCorrelations_r{1,p}(2,3);
    pVal_AllPar(p,1)= eachPar_residuals_partialCorrelations_pval{1,p}(1,2);
    pVal_AllPar(p,2)= eachPar_residuals_partialCorrelations_pval{1,p}(1,3);
    pVal_AllPar(p,3)= eachPar_residuals_partialCorrelations_pval{1,p}(2,3);    
end
 % Fischer Z   
for i=1:size(r_AllPar,1);
    for j= 1:size(r_AllPar,2);
       fiscerZ_r_AllPar(i,j)= atanh(r_AllPar(i,j));
    end
end
for i=1:size(r_AllPar,2);
    [hPartial(i),pPartial(i), ci, stats]= ttest(fiscerZ_r_AllPar(:,i));
    statistic(i)=stats.tstat;
    meanPartialCor(i)=nanmean(fiscerZ_r_AllPar(:,i));
end


partialCorrMat_residuals_random= [hPartial;pPartial;statistic;meanPartialCor;nan(1,size(hPartial,2)); r_AllPar];



table_random = array2table(partialCorrMat_residuals_random);
   table_random.Properties.VariableNames= {'residuals_ERP','residuals_pupilSize','offset_PupilSize_ERP'};
   
pval = array2table(pval, ...
    'VariableNames',{'residuals','offset_AboluteERP','offset_PupilSize'},...
    'RowNames',{'residuals','offset_AboluteERP','offset_PupilSize'});

disp('Partial Correlation Coefficients')


