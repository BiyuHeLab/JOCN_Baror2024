%% Script for regressing out order from viewing duration.

trialNum=400;
%subvecRand= [133, 136:138,140:144,146:147,149:157]; % Random dataset participants
subvecFix= [111,113:117,119:125,127:130,134]; % Fixed dataset participants
allPar_order= [];
allPar_participants= [];
allPar_viewDur= [];

load('timeDurVecEEG_random.mat') % loading viwing duration by order of random dataset
for p=1:length(subvecRand)

% excluding no-response trials
eegInputVec= timeDurVecEEG(:,p);
for i=1:size(timeDurVecEEG,1);
    if eegInputVec(i,1)>=9999; % maximum window for response
        eegInputVec(i,1)= NaN;
    end
end
inputAll = [(1:400)',eegInputVec];

inputAllTbl= array2table(inputAll,'VariableNames',{'Order','ViewingDuration'});
% regression model
md_All= fitlm(inputAllTbl, 'ViewingDuration ~Order');
% model output
redisualsAll= table2array(md_All.Residuals(:,1));
slopeAll= table2array(md_All.Coefficients(2,1));
seAll= table2array(md_All.Coefficients(2,2));
pvalAll= table2array(md_All.Coefficients(2,4));
rSqaureAdjustedAll= (md_All.Rsquared.Adjusted(:,1));
fittedAll= (md_All.Fitted(:,1));


%% Reconstructing Residuals as the vector of correlations 

unsortedResidualsAll= [unsortedResidualsFaces;unsortedResidualsScenes];
sortedResidualsAll= sortrows (unsortedResidualsAll,1);
unsortedFittedAll= [unsortedFittedFaces;unsortedFittedScenes];
sortedReFittedAll= sortrows (unsortedFittedAll,1);


%% saving the data
allOriginals(:,p)= handles.mainResults(:,5);
allSortedResiduals(:,p)=sortedResidualsAll(:,2);
allSortedFitted(:,p)=sortedReFittedAll(:,2);
allResidualsCombined(:,p)=redisualsAll;
allFittedCombined(:,p)=fittedAll;
allSlopes(:,p)= [slopeAll];
allPvalues(:,p)= [pvalAll];
allSEs(:,p)= [seAll];
allRsquareAdjusted(:,p)= [rSqaureAdjustedAll];


allPar_order= [allPar_order; (1:trialNum)'];
allPar_participants= [allPar_participants ; ones(trialNum,1)*p];
allPar_viewDur= [allPar_viewDur; eegInputVec];
end

% Mixed modelling across all participants in the dataset
dsTable_order=table(allPar_order,allPar_participants,allPar_viewDur);
modelspec_order = 'allPar_viewDur ~ 1+  allPar_order+ (1|allPar_participants)'; 
md_order = fitglme(dsTable_order,modelspec_order);

 
 
        
        