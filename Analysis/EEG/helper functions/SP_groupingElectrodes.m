
%% GROUPING ELECTRODES

r_Ant_lat= {'FC6','FT8','FT10','FFC6h','FFT8h','FFT10h','F6','F8','F10','AF8'};
r_Ant_med=  {'FFC2h','FFC4h','F2','F4','AFF2h','AFF6h','AF4','AFp2','Fp2'};
r_Cent_lat= {'TP8','CP6','TTP8h','CCP6h','T8','C6','FTT10h','FTT8h','FCC6h'};
r_Cent_med= {'CPP2h', 'CPP4h','CP2','CP4','CCP2h','CCP4h','FCC2h','FCC4h', 'FC2','FC4'};
r_Post_lat= {'P010','P10','PP010h','PO8','TPP10h','P8','P6','TPP8h', 'TP10','CPP6h'};
r_Post_med= {'P2','P4','PP02h','PPO6h','PO4','P002','O2','OI2h','I2','POO10h'};

l_Ant_lat= {'FC5','FT7','FT9','FFC5h','FFT7h','FFT9h','F5','F7','F9','AF7'};
l_Ant_med= {'FFC1h','FFC3h','F1','F3','AFF1h','AFF5h','AF3','AFp1','Fp1'};
l_Cent_lat= {'TP7','CP5','TTP7h','CCP5h','T7','C5','FTT9h','FTT7h','FCC5h'};
l_Cent_med= {'CPP1h', 'CPP3h','CP1','CP3','CCP1h','CCP3h','FCC1h','FCC3h', 'FC1','FC3'};
l_Post_lat= {'P09','P9','PP09h','PO7','TPP9h','P7','P5','TPP7h', 'TP9','CPP5h'};
l_Post_med= {'P1','P3','PP01h','PPO5h','PO3','P001','O1','OI1h','I1', 'POO9h'};

elecGroup= {l_Ant_lat,l_Ant_med, l_Cent_lat,l_Cent_med, l_Post_lat,l_Post_med,...
             r_Ant_lat,r_Ant_med, r_Cent_lat,r_Cent_med, r_Post_lat,r_Post_med};
         
elecGroupTitle= { 'l_Ant_lat','l_Ant_med', 'l_Cent_lat','l_Cent_med', 'l_Post_lat','l_Post_med',...
             'r_Ant_lat','r_Ant_med', 'r_Cent_lat','r_Cent_med', 'r_Post_lat','r_Post_med' } ;  
         
         
 elec_posterior=  {'PO10','PPO10h','PO8','TPP10h','P8','P6','TPP8h', 'TP10','CPP6h'...
                    'P2','P4','POO2','PO4','O2','POO10h'...
                    'PO9','PPO9h','PO7','TPP9h','P7','P5','TPP7h', 'TP9','CPP5h'...
                    'P1','P3','PPO1h','PPO5h','PO3','POO1','O1', 'POO9h'...
                    'Pz','POz','Oz'};
 for i=1:length(elec_posterior)           
 posteriorElectrodes(i)= find(strcmp(wholeMat_BC.label(:,1),elec_posterior{i}));
 end                

 
 
 elec_middle=  { 'TP8','CP6','TTP8h','CCP6h','T8','C6','FTT10h','FTT8h','FCC6h'...
                'CPP2h', 'CPP4h','CP2','CP4','CCP2h','CCP4h','FCC2h','FCC4h', 'FC2','FC4', 'C4','C2'...
                'TP7','CP5','TTP7h','CCP5h','T7','C5','FTT9h','FTT7h','FCC5h'...
                'CPP1h', 'CPP3h','CP1','CP3','CCP1h','CCP3h','FCC1h','FCC3h', 'FC1','FC3', 'C1','C3'...
                'Cz','CPz'};
 for i=1:length(elec_middle)           
 middleElectrodes(i)= find(strcmp(wholeMat_BC.label(:,1),elec_middle{i}));
 end
                
 elec_anterior={'FC6','FT8','FT10','FFC6h','FFT8h','FFT10h','F6','F8','F10','AF8'...
                'FFC2h','FFC4h','F2','F4','AFF2h','AFF6h','AF4','AFp2','Fp2'...
                'FC5','FT7','FT9','FFC5h','FFT7h','FFT9h','F5','F7','F9','AF7'...
                'FFC1h','FFC3h','F1','F3','AFF1h','AFF5h','AF3','AFp1','Fp1'...
                'Fpz','Fz'};
   for i=1:length(elec_anterior)           
 anteriorElectrodes(i)= find(strcmp(wholeMat_BC.label(:,1),elec_anterior{i}));
 end
                  
         
   
         