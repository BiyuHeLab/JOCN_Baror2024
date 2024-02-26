
function [preMat , meanPreVec ]= SP_ET_pupilSizePre(data,trialIndex, preLength)

%% absolute size, no baseline correction
preMat= zeros(length(trialIndex),(preLength));
for i=1:length(trialIndex)
    if isnan(trialIndex(i,3))
    preMat(i,:)=NaN;
    else
    startSegment=(trialIndex(i,3)-preLength);
    if ~isempty(find(data.Var1==startSegment))
   preMat(i,:)= [data.Var4((find(data.Var1==startSegment)+1):(find(data.Var1==startSegment)+preLength))]';
    end
    end
end

%% excluding trials with blinks at onset
for i=1:length(trialIndex)
    if length(find(preMat(i,:)==0))>1;
        preMat(i,:)= NaN;
    end
end

meanPreVec= nanmean(preMat,2);


%% baselineCorrection mat

% for i=1:size(preMat,1);
% baseline(i,1)= nanmean(preMat(i,1:preLength),2);
% preMat_baseCor(i,:) = preMat(i,:)-baseline(i,1);
% end
% 
% meanPreVec_baseCor= nanmean(preMat_baseCor(:,preLength+1:end),2);

% end


% 
% 
% figure
% plot(onsetDynamic_f_con0exp0,'--r','LineWidth',3)
% hold on
% plot(onsetDynamic_f_con1exp0,'-r','LineWidth',3)
% hold on
% plot(onsetDynamic_f_con1exp1,'--b','LineWidth',3)
% hold on
% plot (onsetDynamic_f_con0exp1,'-b','LineWidth',3)
% 
% hold on
% plot(onsetDynamic_s_con0exp0,'--c','LineWidth',3)
% hold on
% plot(onsetDynamic_s_con1exp0,'-c','LineWidth',3)
% hold on
% plot(onsetDynamic_s_con1exp1,'--g','LineWidth',3)
% hold on
% plot (onsetDynamic_s_con0exp1,'-g','LineWidth',3)
% 
% legend({'unexpected changeF', 'unexpected repetitionF','expected changeF','expected repetitionF',...
%          'unexpected changeS', 'unexpected repetitionS','expected changeS','expected repetitionS' },'Location','northeast')
% 

% 











% meanPupilSizeVec= zeros(size(timeMat,1),1);
% for i=1:length(finalTrial)
%          if (finalTrial(i,3)>0 && finalTrial(i,4)>0 )
%             trialMat= data{(find(data.time== finalTrial(i,3)):find(data.time== finalTrial(i,4))),: };
%             for t=1:size(trialMat);
%                 if trialMat(t,4)== 0;
%                     trialMat(t,4)=NaN;
%                 end
%             end
%             meanPupilSizeVec(i)=nanmean(trialMat(:,4));
%          end
% end
% meanPupilSizeVec=meanPupilSizeVec(1:400);
            