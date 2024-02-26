
function [offsetMat , offsetMat_baseCor , meanOffsetVec , meanOffsetVec_baseCor ]= SP_ET_pupilSizeOffset(data,trialIndex, preBaseVec ,offsetLength)



%% absolute size, no baseline correction
offsetMat= zeros(length(trialIndex),(offsetLength));
for i=1:length(trialIndex)-1
    if isnan(trialIndex(i,4))
    offsetMat(i,:)=NaN;
    else
        endSegment=(trialIndex(i,4));
    if ~isempty(find(data.Var1==endSegment))
   offsetMat(i,:)= [data.Var4((find(data.Var1==endSegment)-offsetLength+1):(find(data.Var1==endSegment)))]';
    end
    end
end

%% excluding trials with blinks at offset
for i=1:length(trialIndex)
    if length(find(offsetMat(i,:)==0))>1;
        offsetMat(i,:)= NaN;
    end
end

meanOffsetVec= nanmean(offsetMat(:,1:offsetLength),2);


%% baselineCorrection mat

for i=1:size(offsetMat,1);
baseline(i,1)= preBaseVec(i,1);
offsetMat_baseCor(i,:) = offsetMat(i,:)-preBaseVec(i,1);
end

meanOffsetVec_baseCor= nanmean(offsetMat_baseCor(:,1:offsetLength),2);

end

