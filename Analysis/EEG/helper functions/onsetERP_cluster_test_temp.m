%% shuffling the data for cluster analysis
        function [clusters_orig, clusters_shuffle, shuffleMaxStat] = onsetERP_cluster_test_temp(Y_orig, Y_forShuffle, allSortedResiduals, p_thresh, n_sample, n_perms,subvec)%, effectRow, S,F1,F2,FACTNAMES)

                                      

        %% analysis of repeatedly shuffled data set
        clusters_orig= Y_orig;
        dv_orig= Y_forShuffle;
        %dv_orig= Y_Face;
        % shuffle

       
        n_subs = size(dv_orig{1}, 1);
        n_DVs  = size(dv_orig{1}, 2);

        %h = waitbar(0, 'Shuffling...');

 for i_perm = 1:n_perms

    waitbar(i_perm / n_perms);
        % construct shuffle permutation for current iteration
    shuffled_timeDurVecEEG = allSortedResiduals(randperm(size(allSortedResiduals,1)),:);
    shuffleVec= randperm(size(allSortedResiduals,2));
    for par=1:length(subvec) 
        shuffled_times{par}= dv_orig{par}(:,shuffleVec);
    end
     for i_sample = 1:n_sample
      % apply the shuffling to the original data
          for par=1:length(subvec)             
             [r,p] = corr(dv_orig{par}(:,i_sample),shuffled_timeDurVecEEG(:,par),'rows','complete', 'Type', 'Pearson');
             %[r,p] = corr(shuffled_times{par}(:,i_sample),allSortedResiduals(:,par),'rows','complete', 'Type', 'Pearson');
             
             %corrT(p,j)= r;
             %pT(p,j)= p;
             
             rVal(par,i_sample)=r;
             pVal(par,i_sample)=p;
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