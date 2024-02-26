function [onsetConditions, onsetConditions_bc] = SP_EY_onsetMeanConditions(meanOnsetVec , meanOnsetVec_baseCor,...
                                                      ind_f_con0exp0 ,ind_f_con1exp0 , ind_f_con1exp1 ,ind_f_con0exp1,...
                                                      ind_s_con0exp0 , ind_s_con1exp0 , ind_s_con1exp1 , ind_s_con0exp1 );

onsetMean_f_con0exp0= nanmean(meanOnsetVec(ind_f_con0exp0));
onsetMean_f_con1exp0= nanmean(meanOnsetVec(ind_f_con1exp0));
onsetMean_f_con1exp1= nanmean(meanOnsetVec(ind_f_con1exp1));
onsetMean_f_con0exp1= nanmean(meanOnsetVec(ind_f_con0exp1));

onsetMean_s_con0exp0= nanmean(meanOnsetVec(ind_s_con0exp0));
onsetMean_s_con1exp0= nanmean(meanOnsetVec(ind_s_con1exp0));
onsetMean_s_con1exp1= nanmean(meanOnsetVec(ind_s_con1exp1));
onsetMean_s_con0exp1= nanmean(meanOnsetVec(ind_s_con0exp1));

onsetConditions= [onsetMean_f_con0exp0,onsetMean_f_con1exp0 ,onsetMean_f_con1exp1 ,onsetMean_f_con0exp1,...
           onsetMean_s_con0exp0,onsetMean_s_con1exp0 ,onsetMean_s_con1exp1 ,onsetMean_s_con0exp1];
       

onsetMean_f_con0exp0_bc= nanmean(meanOnsetVec_baseCor(ind_f_con0exp0));
onsetMean_f_con1exp0_bc= nanmean(meanOnsetVec_baseCor(ind_f_con1exp0));
onsetMean_f_con1exp1_bc= nanmean(meanOnsetVec_baseCor(ind_f_con1exp1));
onsetMean_f_con0exp1_bc= nanmean(meanOnsetVec_baseCor(ind_f_con0exp1));

onsetMean_s_con0exp0_bc= nanmean(meanOnsetVec_baseCor(ind_s_con0exp0));
onsetMean_s_con1exp0_bc= nanmean(meanOnsetVec_baseCor(ind_s_con1exp0));
onsetMean_s_con1exp1_bc= nanmean(meanOnsetVec_baseCor(ind_s_con1exp1));
onsetMean_s_con0exp1_bc= nanmean(meanOnsetVec_baseCor(ind_s_con0exp1));

onsetConditions_bc= [onsetMean_f_con0exp0_bc,onsetMean_f_con1exp0_bc ,onsetMean_f_con1exp1_bc ,onsetMean_f_con0exp1_bc,...
           onsetMean_s_con0exp0_bc,onsetMean_s_con1exp0_bc ,onsetMean_s_con1exp1_bc ,onsetMean_s_con0exp1_bc];       
       
end