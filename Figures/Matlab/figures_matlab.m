
%% Figure 6B
load Fig6B_stps_eachPar_rdm.mat
for par=1:size(eachPar_rdm,1)
    inputStruct=[];
    rdmByLength=[]; 
    for t=1:size(eachPar_rdm,2);
    inputStruct (t,1)= t;    
    inputStruct (t,2)= size(eachPar_rdm{par,t},2);
    end
    rdmByLength= sortrows(inputStruct,2);
    rdmByLength= rdmByLength(find(rdmByLength(:,2)>=50),:);
    eachPar_radmByLnegth{1,par}= rdmByLength;
end

par=6;
figure
imagesc(eachPar_rdm{par, eachPar_radmByLnegth{1,par}(4,1)}(1:45,1:45),'Xdata',[0 2400])
yticks([1 10 20 30 40])
yticklabels({'0', '0.5','1','1.5', '2'})
xlabel('time in trial (ms)','fontsize',30);
colorbar;
colormap("parula");
caxis([-1 1]);
title('A short trial (2521ms)', 'fontsize',35);
figure
imagesc(eachPar_rdm{par, eachPar_radmByLnegth{1,par}(236,1)}(1:45,1:45),'Xdata',[0 2400])
yticks([1 10 20 30 40])
yticklabels({'0', '0.500','1','1.5', '2'})
xlabel('time in trial (ms)','fontsize',30');
colorbar;
colormap(parula);
caxis([-1 1]);
title('A long trial (5600ms)', 'fontsize',35);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure 6D
load Fig6D_stps_corrWithResiduals_table.mat
figure
plot([0:50:2200],corrWithResiduals.zT,'black', 'linewidth',3);
xlabel('Time from onset','fontsize',30);
ylabel('t-statistic','fontsize',30);
title('STPS-Spontaneous Viewing Duration Corr.', 'fontsize',30);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure 7A
load Fig7A_stps_allIntraSub_random.mat
for i=[3,14]
    figure
    imagesc(allIntraSub{1,i});
    colorbar
    colormap(parula);
    caxis([-0.2 1]);
end