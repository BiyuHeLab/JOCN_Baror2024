%% Script for finding order-viewing duration correlations

load('timeDurVecEEG_random.mat')
subvec= [133,136:138,140:144,146:147,149:157] % random participants subject numbers
%subvec= [111,113:117,119:125,127:130,134]; % Fixed participants subejcts
allPar=[];
viewDurByOrder=[];
e_corr=[];
for s= 1:length(subvec);
 
timeDurVec= timeDurVecEEG(:,s);

 [R,P] = corr(timeDurVec,(1:length(timeDurVec))','Type','Spearman','rows','complete');
               e_corr(s)= R;
               e_p(s)= P;

allPar= [allPar,timeDurVec];
end

sumCor= [e_corr;e_p];

viewDurByOrder_mean= nanmean(allPar,2);
viewDurByOrder_std= nanstd(allPar,0,2);


[R,P] = corrcoef(viewDurByOrder_mean,(1:length(viewDurByOrder_mean))','rows','complete')

%grouping into 10 bins of 40 trials each
viewDurByOrder_mean_binned=[];
viewDurByOrder_std_binned=[];
binSize=40;
for p=1:20
    for b=1:size(allPar,1)/binSize
viewDurByOrder_mean_binned(b,p)= nanmean(allPar((b*binSize-binSize+1:b*binSize),p ));
end
end

options.handle=figure;
options.error = 'sem';

options.color_area = [0 100 0]./255;
options.color_line = [ 0 0 0]./255;
options.alpha = 0.5;
options.line_width = 3; 
options.x_axis = 10:10:100;
plot_areaerrorbar(viewDurByOrder_mean_binned', options)
xlabel('trial in the experiment (in precentiles)');
ylabel('viewing duration (ms)');


