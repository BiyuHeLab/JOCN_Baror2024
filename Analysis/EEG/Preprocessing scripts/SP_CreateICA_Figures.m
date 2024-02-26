function SP_CreateICA_Figures(icaComponentStruct, numComps, samplingFrequency,subject);

%% Parameters
%power spectrum analysis
cfg              = [];
cfg.output       = 'pow'; % output in power
cfg.channel      = 'all';%compute the power spectrum in all ICs
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning'; %window
cfg.foi          = 1:0.5:50;% range
freq = ft_freqanalysis(cfg, icaComponentStruct);

%finding largest trial to plot its timecourse
trialLength= zeros(length(icaComponentStruct.trial),1);
for i=1:length(icaComponentStruct.trial);
    trialLength(i)=length(icaComponentStruct.trial{1,i});
end
trialNumP=find(trialLength(:,1)== max(trialLength));
trialNum= trialNumP(1,1);
maxRowsTimeCourse = 3;
numberSamples = length(icaComponentStruct.trial{1,trialNum});
dataLength =  ceil(numberSamples / maxRowsTimeCourse);

for i_comp =1:numComps
    figure
    subplot(2,2,4)
    plot(freq.freq,log10(freq.powspctrm(i_comp,:)));
    xlabel('Frequency (Hz)');
    ylabel('Power (dB)'); 
    hold on    
    subplot(2,2,3)
    cfg = [];
    cfg.component = i_comp;
    cfg.layout    = 'EEG1020.lay'; % specify the layout file that should be used for plotting
    cfg.viewmode = 'component';
    ft_topoplotIC(cfg,icaComponentStruct);    
    hold on
    subplot(2,1,1)
    topoData = icaComponentStruct.trial{trialNum}(i_comp,:);
    mn = mean(topoData);
    sd = std(topoData);
    for j = 1:maxRowsTimeCourse
        tms = (1 + (j-1)*dataLength:j*dataLength);
        tms = unique(min(tms,numberSamples));
        plot(1/samplingFrequency:1/samplingFrequency:length(tms)/samplingFrequency,topoData(tms) + (-j * sd * 10));
        hold on;
    end
    title(['Sub', num2str(subject),' ', 'Comp', num2str(i_comp)]);    
  
end

path = pwd ;
folderName = ['ICAcomponents_',num2str(subject)] ;   % new folder name 
myfolder=folderName;
folder = mkdir([path,filesep,myfolder]) ;
path  = [path,filesep,myfolder] ;
for c = 1:numComps
    figure(c);
    %plot(rand(1,10));
    temp=[path,filesep,'Comp',num2str(c),'.png'];
    saveas(gca,temp);
end 

end
    
