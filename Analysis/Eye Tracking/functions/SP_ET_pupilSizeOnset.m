
function [onsetMat , onsetMat_baseCor , meanOnsetVec , meanOnsetVec_baseCor ]= SP_ET_pupilSizeOnset(data,trialIndex, meanPreVec,onsetLength)



%% absolute size, no baseline correction
onsetMat= zeros(length(trialIndex),(onsetLength));
for i=1:length(trialIndex)
    if isnan(trialIndex(i,3))
    onsetMat(i,:)=NaN;
    elseif trialIndex(i,5)<onsetLength
             onsetMat(i,:)=NaN;
    else
           startSegment=(trialIndex(i,3)-200);
          if ~isempty(find(data.Var1==startSegment))
          onsetMat(i,:)= [data.Var4((find(data.Var1==startSegment)+1):(find(data.Var1==startSegment)+onsetLength))]';
          end
    end
end

%% excluding trials with blinks at onset
for i=1:length(trialIndex)
    if length(find(onsetMat(i,:)==0))>1;
        onsetMat(i,:)= NaN;
    end
end

meanOnsetVec= nanmean(onsetMat(:,700:900),2);


%% baselineCorrection mat

for i=1:size(onsetMat,1);
baseline(i,1)= meanPreVec(i,1);
onsetMat_baseCor(i,:) = onsetMat(i,:)-baseline(i,1);
end

meanOnsetVec_baseCor=   meanOnsetVec-meanPreVec;  %  nanmean(onsetMat_baseCor(:,700:900),2);

end


