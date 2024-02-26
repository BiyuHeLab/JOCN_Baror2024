function [clusters_orig, clusters_shuffle, shuffleMaxStat] = cluster_test_temporal(dv_orig, p_thresh, analysis, n_perms)
% [clusters_orig, clusters_shuffle, shuffleMaxStat] = cluster_test_temporal(dv, p_thresh, analysis, n_perms)
% 
% Perform permutation based cluster correction on a within-subject statistical 
% test performed on a time series.
%
%
% INPUTS
% ------
% * dv is the data to be cluster corrected. It should be formatted as a 
%   1 x n_samples cell array, where each cell holds a matrix of size n_subs
%   x n_dvs. n_dvs corresponds to the number of within-subject experimental
%   conditions.
%
% * p_thresh is the p-value threshold used to define membership of a sample
%   to a cluster. For instance, if p_thresh is set to 0.05 and if the 
%   statistical test yields p = 0.02 at a given time sample, then that sample 
%   will be included in a cluster.
%
% * analysis is a string specifying the Matlab commands for conducting the
%   statistical test on dv{i_sample}. The depdendent variable in these commands 
%   must be referred to by the variable name "dv{i_sample}". The resulting
%   p-value must be named "p_val" and the resulting test statistic must be
%   named "test_stat".
%
%   Here is an example of constructing the analysis string for a paired t-test : 
%
%         analysis = [];
%         analysis = [analysis, '[h, p_val, ci, stats] = ttest(dv{i_sample}(:,1), dv{i_sample}(:,2)); '];
%         analysis = [analysis, 'test_stat = stats.tstat;  '];
%
%   Here is an example of constructing the analysis string for repeated 
%   measures ANOVA conducted with the function anova_rm :
%
%         analysis = [];
%         analysis = [analysis, '[p_val, table] = anova_rm(dv{i_sample}, ''off'');  '];
%         analysis = [analysis, 'p_val = p_val(1);  '];
%         analysis = [analysis, 'test_stat = table{2, 5};  '];
%
% * n_perms is the number of permutations to perform for constructing the
%   null distribution of cluster statistics.
%
% OUTPUTS
% -------
% * clusters_orig is a struct containing information on statistical
%   clusters present in the data "dv" when analyzed as specified in
%   "analysis".
%
%   clusters_orig.inputs contains the results of applying "analysis" to
%   "dv". It contains 1 x n_samples vectors containing the test statistic
%   (clusters_orig.inputs.stat_timecourse) and p-value
%   (clusters_orig.inputs.p_timecourse) at each time sample. The p_thresh
%   subfield stores the value of p_thresh defined as input to the function.
%
%   clusters_orig.nClusters is the number of clusters in the data, i.e. the 
%   number of sets of contiguous samples that exhibit p_val < p_thresh. A
%   listing of the sample indeces belonging to these clusters is given in
%   clusters_orig.cluster_samples. clusters_orig.cluster_timecourse labels
%   each sample with the number of the cluster it belongs to (with 0
%   indicating that this sample is not part of a cluster).
%
%   clusters_orig.cluster_size lists the number of samples belonging to
%   each cluster, and clusters_orig.cluster_statSum lists the Cluster
%   Statistic (i.e. the sum of the test statistics for all samples in the
%   cluster) for each cluster. The fields maxSize, maxStatSumPos,
%   maxStatSumNeg, and maxStatSumAbs lists the maxmimum cluster size and
%   the maximum positive, negative, and absolute value Cluster Statistics,
%   respectively.
%
%   clusters_orig.cluster_pval contains the p-value for each cluster. A null 
%   distribution of Cluster Statistics is constructed by repeatedly permuting 
%   the original data set and computing the maximum absolute Cluster Statistic 
%   in each permutation. The p-value for a cluster in the original data is
%   computed as the fraction of samples in the permutation null
%   distribution that exhibit values greater than the absolute value of the
%   cluster's Cluster Statistic.
%
% * clusters_shuffle is a 1 x n_perms cell array, where each element of the
%   array contains results of the cluster analysis applied to a permutation
%   of the original data set. The structure of each clusters_shuffle{i_perm}
%   struct is identical to that of clusters_orig (except there is no
%   p-value computed for these data).
%
% * shuffeMaxStat is the null distribution of Cluster Statistics
%   constructed by extracting the maximum absolute value Cluster Statistic
%   from each random permutation of the original data set.
%
% This function calls the function "contiguous" by David Fass (available 
% for download on the Matlab file exchange), and the function 
% "find_temporal_clusters" by Brian Maniscalco.
%
% reference: 
% Maris E. and Oostenveld R. (2007) Nonparametric statistical testing of EEG- 
% and MEG-data. J Neurosci Methods 164 (1), 177-90. pmid:17517438 
%
% written by Brian Maniscalco


% original data
% -------------
% for each sample,
% - compute timecourse of the statistical effect across subjects
% across all samples,
% - find clusters in the original data timecourse
%
% shuffled data
% -------------
% for each sample,
% - shuffle experimental condition means randomly and independently for each subject
% across all samples,
% - compute timecourse of the statistical effect across subjects for the shuffled data set
% - find and save the max(ClusterStat) for thus shuffled set
% - over many iterations, this gives the null distribution for ClusterStat


%% analysis of original data set

n_samples = length(dv_orig);

% compute timecourse of the statistical effect across subjects
for i_sample = 1:n_samples

    dv = dv_orig;
    eval(analysis);

    p_timecourse(i_sample)    = p_val;
    stat_timecourse(i_sample) = test_stat;

end

% find clusters in the original data timecourse
clusters_orig = find_temporal_clusters(stat_timecourse, p_timecourse, p_thresh);



%% analysis of repeatedly shuffled data set

% shuffle
n_subs = size(dv{1}, 1);
n_DVs  = size(dv{1}, 2);

h = waitbar(0, 'Shuffling...');

for i_perm = 1:n_perms

    waitbar(i_perm / n_perms);

    % construct shuffle permutation for current iteration
    shuffle_ind = [];
    for i_sub = 1:n_subs
        shuffle_ind(i_sub, :) = randperm(n_DVs);
    end


    for i_sample = 1:n_samples

        % apply the shuffling to the original data
        for i_sub = 1:n_subs
            ind = shuffle_ind(i_sub, :);
            dv_shuffle{i_sample}(i_sub, :) = dv_orig{i_sample}(i_sub, ind);
        end

        dv = dv_shuffle;
        eval(analysis);

        p_timecourse_shuffle(i_sample)    = p_val;
        stat_timecourse_shuffle(i_sample) = test_stat;

    end

    % find clusters in the shuffled data topo and get the max cluster stat
    clusters_shuffle{i_perm} = find_temporal_clusters(stat_timecourse_shuffle, p_timecourse_shuffle, p_thresh);
    shuffleMaxStat(i_perm) = clusters_shuffle{i_perm}.maxStatSumAbs;

end


%% calculate p-values for each cluster in the original data set 
%  on the basis of the estimated null distribution from the shuffled data set

for i = 1:clusters_orig.nClusters
    pval = sum(shuffleMaxStat > abs( clusters_orig.cluster_statSum(i) )) / n_perms;
    clusters_orig.cluster_pval(i) = pval;
end