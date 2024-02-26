function [preConditions] = SP_EY_preMeanConditions(meanPreVec,...
                                                      ind_f_con0exp0 ,ind_f_con1exp0 , ind_f_con1exp1 ,ind_f_con0exp1,...
                                                      ind_s_con0exp0 , ind_s_con1exp0 , ind_s_con1exp1 , ind_s_con0exp1 );

preMean_f_con0exp0= nanmean(meanPreVec(ind_f_con0exp0));
preMean_f_con1exp0= nanmean(meanPreVec(ind_f_con1exp0));
preMean_f_con1exp1= nanmean(meanPreVec(ind_f_con1exp1));
preMean_f_con0exp1= nanmean(meanPreVec(ind_f_con0exp1));

preMean_s_con0exp0= nanmean(meanPreVec(ind_s_con0exp0));
preMean_s_con1exp0= nanmean(meanPreVec(ind_s_con1exp0));
preMean_s_con1exp1= nanmean(meanPreVec(ind_s_con1exp1));
preMean_s_con0exp1= nanmean(meanPreVec(ind_s_con0exp1));

preConditions= [preMean_f_con0exp0,preMean_f_con1exp0 ,preMean_f_con1exp1 ,preMean_f_con0exp1,...
           preMean_s_con0exp0,preMean_s_con1exp0 ,preMean_s_con1exp1 ,preMean_s_con0exp1];
       

end