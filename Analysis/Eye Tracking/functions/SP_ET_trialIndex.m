
function [trialIndex]= SP_ET_trialIndex(s,data,events)


tOnset= startsWith(cellstr(events.value),'Ton');
tOffset= startsWith(cellstr(events.value),'Toff');

indOn=1;
indOff=1;

for i= 1:length(tOnset);
    if tOnset(i)==1;
        trialCell{indOn,1}= events.value{i,1};
        timeCell{indOn,1}= events.type{i,1};
        indOn=indOn+1;
    end
    if tOffset(i)==1;
        trialCell{indOff,2}= events.value{i,1};
        timeCell{indOff,2}= events.type{i,1};
        indOff=indOff+1;
    end
end
timeMat= zeros(size(timeCell,1), size(timeCell,2));
for i=1:length(timeCell)
     for j=1:2;
         if ~isempty(timeCell{i,j})
            index= timeCell{i,j};
            timeMat(i,j)= str2num(index(5:end));
         end
     end
end
trialMat= zeros(size(trialCell,1), size(trialCell,2));
for i=1:length(trialCell)
            indexOn= trialCell{i,1};
            indexOff= trialCell{i,2};
            if ~isempty(indexOn)
            trialMat(i,1)= str2num(indexOn(5:end));
            else trialMat(i,1)=NaN;
            end
            if ~isempty(indexOff)
            trialMat(i,2)= str2num(indexOff(6:end)); 
            else trialMat(i,2)=NaN;
            end
end

finalTrial= zeros(400,4);
ind=1;
indO=1;
for i=1:length(trialMat)
     % Arranging the on trials and timings 
    if trialMat(i,1)==ind;
        finalTrial(ind,1)= trialMat(i,1);
        finalTrial(ind,3)= timeMat(i,1);
        ind=ind+1;
    else finalTrial(ind,1)=NaN;
        finalTrial(ind,3)=NaN;
        ind=ind+1;
        while trialMat(i,1)>ind;
            finalTrial(ind,1)=NaN;
            finalTrial(ind,3)=NaN;
            ind=ind+1;
        end
        if trialMat(i,1)==ind;
            finalTrial(ind,1)= trialMat(i,1);
            finalTrial(ind,3)= timeMat(i,1);
            ind=ind+1;
        end
    end
    
     
end
     % Arranging the off trials and timings 
for i=1:length(trialMat)     
 if trialMat(i,2)==indO;
        finalTrial(indO,2)= trialMat(i,2);
        finalTrial(indO,4)= timeMat(i,2);
        indO=indO+1;
    else finalTrial(indO,2)=NaN;
        finalTrial(indO,4)=NaN;
        indO=indO+1;
        while trialMat(i,2)>indO;
            finalTrial(indO,2)=NaN;
            finalTrial(indO,4)=NaN;
            indO=indO+1;
        end
        if trialMat(i,2)==indO;
            finalTrial(indO,2)= trialMat(i,2);
            finalTrial(indO,4)= timeMat(i,2);
            indO=indO+1;
        end
     end 
     end 

trialIndex= [finalTrial(1:400,:),zeros(400,1)];
trialIndex(:,5)= trialIndex(:,4)-trialIndex(:,3);

trialMean= nanmean(trialIndex(:,5));

end
            