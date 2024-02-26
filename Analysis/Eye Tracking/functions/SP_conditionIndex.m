
function [ind_f_con0exp0 ,ind_f_con1exp0 , ind_f_con1exp1 ,ind_f_con0exp1,...
          ind_s_con0exp0 , ind_s_con1exp0 , ind_s_con1exp1 , ind_s_con0exp1 ] = SP_conditionIndex(subjectNumber);

load(['handles_', num2str(subjectNumber),'b.mat']);   
arrange = [handles.mainResults,[(1:length(handles.mainResults))']];
arrangeF= arrange(find(arrange(:,3)==1),:);
arrangeS= arrange(find(arrange(:,3)==2),:);

ind_f_con0exp0= arrangeF(find(arrangeF(:,1)+ arrangeF(:,2)== 0),6);
ind_f_con1exp0= arrangeF(find(arrangeF(:,1)- arrangeF(:,2)== 1),6);
ind_f_con1exp1= arrangeF(find(arrangeF(:,1)+ arrangeF(:,2)== 2 ),6);
ind_f_con0exp1= arrangeF(find(arrangeF(:,1)- arrangeF(:,2)== -1 ),6);

ind_s_con0exp0= arrangeS(find(arrangeS(:,1)+ arrangeS(:,2)== 0),6);
ind_s_con1exp0= arrangeS(find(arrangeS(:,1)- arrangeS(:,2)== 1),6);
ind_s_con1exp1= arrangeS(find(arrangeS(:,1)+ arrangeS(:,2)== 2 ),6);
ind_s_con0exp1= arrangeS(find(arrangeS(:,1)- arrangeS(:,2)== -1 ),6);

end