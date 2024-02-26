        %% shuffling the data for cluster analysis
        function [clusters_orig, clusters_shuffle, shuffleMaxStat] = stps_cluster_test_temp(Y_orig, Y_forShuffle, allSortedResiduals, p_thresh, n_sample, n_perms, startingPoint, windowSize,subvec,samplesPerBin)%, effectRow, S,F1,F2,FACTNAMES)

                                      

        %% analysis of repeatedly shuffled data set
        clusters_orig= Y_orig;
        dv_orig= Y_forShuffle;
        %dv_orig= Y_Face;
        % shuffle

       
        n_subs = size(dv_orig, 1);
        n_DVs  = size(dv_orig, 2);

        %h = waitbar(0, 'Shuffling...');

 for i_perm = 1:n_perms

    waitbar(i_perm / n_perms);
        % construct shuffle permutation for current iteration
%         shuffledDataPoints= randperm(n_sample);
%          for i_sub = 1:n_subs
%           ind = shuffle_ind(:,i_sub);
%           shuffle_preReshaphe{i_sample}( :,i_sub) = dv_orig{i_sample}(ind,i_sub);  
%          end
%           dv_shuffle{i_sample} = shuffle_preReshaphe{i_sample};
        
        
       % shuffled_timeDurVecEEG = allSortedResiduals(randperm(size(allSortedResiduals,1)),:);
        timeDurVecEEG=allSortedResiduals;
        for i_sample = 1:n_sample
        % apply the shuffling to the original data
      
                shift= i_sample-1;
                for par=1:length(subvec)
                    inputStruct=[];
                    rdmByLength=[]; 
                       for t=1:size(Y_forShuffle,2);
                           inputStruct (t,1)= t;    
                           inputStruct (t,2)= size(Y_forShuffle{par,t},2);
                       end
                     rdmByLength= sortrows(inputStruct,2);
                     rdmByLength= rdmByLength(find(rdmByLength(:,2)>=48),:);
                     rdmByLengthShuff= rdmByLength(randperm(size(rdmByLength,1)),:);

    %% CORRELATIONS BETWEEN RSA AT X TIMEPOINT AND VIEWING DURATION
    % using a sliding window of 200 ms

         midSimilarity=[];
         for t=1:length(rdmByLength)
             rsmCurrent= triu(Y_forShuffle{par,rdmByLength(t,1)});
             for n=1:size(rsmCurrent,1)
             rsmCurrent(n,n)=NaN;
             rsmCurrent(n,find(rsmCurrent(n,:)==0))=NaN;
             end

        selectedWindow= startingPoint/samplesPerBin+shift+1:(startingPoint+windowSize)/samplesPerBin +shift;
        rsmSelected= rsmCurrent(selectedWindow,selectedWindow);
        midSimilarity(t,2)= nanmean(reshape(rsmSelected,size(rsmSelected,1)*size(rsmSelected,2),1));
        midSimilarity(t,1)= timeDurVecEEG(rdmByLengthShuff(t,1),par);
        end
        [r,p]= corr(midSimilarity(:,2),midSimilarity(:,1),'rows', 'complete','Type','Spearman');
    rVal(par,shift+1)=r;
    pVal(par,shift+1)=p;
    
end
end

for i=1:size(rVal,1);
  for j=1:size(rVal,2);
      z_rVal(i,j)= atanh(rVal(i,j));
  end
end

 for i=1:size(rVal,2);
     [h,p,ci,stats]= ttest(z_rVal(:,i));
     
     zH(i)=h;
     p_timecourse_shuffle(1,i_sample)=p;
     stat_timecourse_shuffle(1,i_sample)= stats.tstat;
 end


            % find clusters in the shuffled data topo and get the max cluster stat
            clusters_shuffle{i_perm} = find_temporal_clusters(stat_timecourse_shuffle, p_timecourse_shuffle, p_thresh);
            shuffleMaxStat(i_perm) = clusters_shuffle{i_perm}.maxStatSumAbs;

end


        %% calculate p-values for each cluster in the original data set 
        %  on the basis of the estimated null distribution from the shuffled data set

        for i = 1:clusters_orig.nClusters
            pval = sum(shuffleMaxStat > abs(clusters_orig.cluster_statSum(i) )) / n_perms;
            clusters_orig.cluster_pval(i) = pval;
        end