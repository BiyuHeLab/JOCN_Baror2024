%% Preprocessing Main Protocol- SPONTANEOUS PERCEPTION
%Code written by Shira Baror, February, 2022.


addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20180725') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20190314') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/toolboxes/fieldtrip-20210212') %subfunctions
addpath('/isilon/LFMI/VMdrive/Shira/Shira_SP/rawData_Participants/randomOrder') %subfunctions
subject= [];% load subject index
%% 1.  Loading EEG data and Behavioral data
cfg = [];
fileName=  'SP_134.vhdr'; % de-identified participant's ID
cfg.dataset  = fileName;
cfg.headerfile=   fileName;
data = ft_preprocessing(cfg);
%% 2. setting parameters
EEGdata = struct ;
EEGdata.fsample = 1000;
EEGdata.sampleinfo = [1 length(data.trial{1})];
EEGdata.nchans = size(data.trial{1},1);

%% 3. FIRST PREPROCESSING STAGES AT THE BLOCK LEVEL:filtering, rereferencing, demeaning & detrending
pBeforeFilter = pwelch(data.trial{1}(1,:),hamming(2^12),[],2^12,data.fsample);
cfg = [];
cfg.subject= subject;
cfg.dataset     = fileName;
cfg.headerfile=   fileName;
cfg.continuous  = 'yes'
cfg.hpfilter       = 'yes';        % enable high-pass filtering
cfg.lpfilter       = 'yes';        % enable low-pass filtering
cfg.hpfiltord  = 3;
cfg.lpfiltord  = 3;
cfg.hpfilttype = 'but';
cfg.lpfilttype = 'but';
cfg.hpfreq         = 0.05;            % set up the frequency for high-pass filter
cfg.lpfreq         = 150;          % set up the frequency for low-pass filter
cfg.bsfilter = 'yes';    
cfg.bsfilttype = 'but'; %Bandstop filter for line noise
cfg.bsfreq = [59 61 119 121];
cfg.channel = {'all', '-HEOG_L','-HEOG_R', '-VEOG_Inf','-VEOG_Sup', '-ECG_Inf','-ECG_Sup'}; 
cfg.detrend = 'yes';
cfg.demean = 'yes';
cfg.reref      = 'yes';
cfg.refchannel = 'all';
cfg.refmethod  = 'avg';
cfg.trialfun = 'SP_trialfun_definetrials';
cfg = ft_definetrial(cfg);
EEGdata2= ft_preprocessing(cfg); 


[pAfterFilter,freqs] = pwelch(EEGdata2.trial{1}(1,:),hamming(2^12),[],2^12,EEGdata2.fsample);
% figure
% loglog(freqs,pBeforeFilter,'b','linewidth',2);
% hold on
% loglog(freqs,pAfterFilter,'r','linewidth',2);
% xlabel('Frequency')
% ylabel('Power (dB/Hz');

% plotting channels for manua inspection
SP_plotElectrodePowerSpectrums(EEGdata2.trial{1}, EEGdata2.label, 1:EEGdata.nchans, EEGdata2.fsample,subject);

%% Repair bad channels
%preparing layout
load 'acticap128.mat'   
elec = struct;
for i = 3:length(acticap128.chanlocs)% ecluding the ground and reference (1+2)
elec.pnt(i-2,1) = acticap128.chanlocs(i).X;
elec.pnt(i-2,2) = acticap128.chanlocs(i).Y;
elec.pnt(i-2,3) = acticap128.chanlocs(i).Z;
elec.label{i-2} = acticap128.chanlocs(i).labels;
end
cfg = [];
cfg.elec = elec;
cfg.rotate = 90; 
cfg.layout     =ft_prepare_layout(cfg);
cfg.template      = 'easycap128.mat'
cfg.method        = 'triangulation'
cfg.neighbours = ft_prepare_neighbours(cfg);   
neighbours= cfg.neighbours;
%% Repairing channels
cfg.badchannel     = {''};
cfg.missingchannel = {'P9' , 'P10', 'PPO6h'}; % these channels were missing for all participants
cfg.method         = 'average';
cfg.neighbours     = neighbours;
cfg.trials         = 'all'
%cfg.lambda         = regularisation parameter (default = 1e-5, not for method 'distance')
%cfg.order          = 4; %Why?
preprocessedData_ChannelRepaired = ft_channelrepair(cfg, EEGdata2);


%% 4. Apply basic preprocessing and re-referencing to EOG data (EEG and EOG synchronized)
%ProcessEOG data 
%Read in and re-reference data    
    cfg = [];
    cfg.subject= subject;
    cfg.dataset = fileName;
    cfg.reref = 'yes';
    cfg.detrend = 'yes';
    cfg.demean = 'yes';    
    %Horizontal EOG (for lateral ey movements)
    cfg.channel = {'HEOG_L','HEOG_R'};
    cfg.trialfun = 'SP_trialfun_definetrials';
    cfg = ft_definetrial(cfg);
    cfg.refchannel = {'HEOG_L'};    
    rerefHEOGStruct = ft_preprocessing(cfg);   
    %Vertical EOG (for blinks)
    cfg.dataset = fileName;
    cfg.channel = {'VEOG_Inf','VEOG_Sup'};
    cfg.refchannel = {'VEOG_Inf'};  
    cfg.trialfun = 'SP_trialfun_definetrials';
    cfg = ft_definetrial(cfg);
    rerefVEOGStruct = ft_preprocessing(cfg);
    %to compute bipolar derivation
    rerefHEOGStruct.label{2} = 'HEOG';
    cfg = [];
    cfg.subject= subject;
    cfg.dataset = fileName;
    cfg.channel = {'HEOG'};
    cfg.trialfun = 'SP_trialfun_definetrials';
    cfg = ft_definetrial(cfg);
    dataHEOG = ft_preprocessing(cfg,rerefHEOGStruct);

    rerefVEOGStruct.label{2} = 'VEOG';
    cfg = [];
    cfg.subject= subject;
    cfg.dataset = fileName;
    cfg.channel = {'VEOG'};
    cfg.trialfun = 'SP_trialfun_definetrials';
    cfg = ft_definetrial(cfg);
    dataVEOG = ft_preprocessing(cfg,rerefVEOGStruct);
            
%% 5. Append data (after data-set-wise re-referencing has been done
%The benefit of appending early is to then share the one-the-way altered trialinfo
dataAll_preproc1 = ft_appenddata([], preprocessedData_ChannelRepaired, dataHEOG, dataVEOG);   
 

%% 6. Muscle and Jump artifact removal (important to do before ICA)
   %6.1Jumps
    cfg = [];
    cfg.artfctdef.reject = 'partial';
    cfg.continuous = 'no'; %because we have block-wise data now   
    cfg.artfctdef.jump.channel = {'all','-HEOG','-VEOG', '-ECG'}; 
    cfg.artfctdef.jump.cutoff = 20;
    cfg.artfctdef.jump.trlpadding = 0;
    cfg.artfctdef.jump.artpadding = 0;
    cfg.artfctdef.jump.fltpadding = 0;
    cfg.artfctdef.jump.cumulative = 'yes';
    cfg.artfctdef.jump.medianfilter = 'yes';
    cfg.artfctdef.jump.medianfilterord = 9;
    cfg.artfctdef.jump.absdiff = 'yes';
    cfg.artfctdef.jump.interactive = 'yes';
    [cfg, artifcat_jump] = ft_artifact_jump(cfg, dataAll_preproc1);
    
%6.2Muscle
    cfg.artfctdef.muscle.channel = {'all', '-HEOG','-VEOG', '-ECG'}; 
    cfg.artfctdef.muscle.cutoff = 4;
    cfg.artfctdef.muscle.trlpadding = 0;
    cfg.artfctdef.muscle.artpadding = 0;
    cfg.artfctdef.muscle.fltpadding = 0.1;
    cfg.artfctdef.muscle.bpfilter = 'yes';
    cfg.artfctdef.muscle.bpfreq = [110 140];
    cfg.artfctdef.muscle.bpfiltord = 9;
    cfg.artfctdef.muscle.bpfilttype = 'but';
    cfg.artfctdef.muscle.hilbert = 'yes';
    cfg.artfctdef.muscle.boxcar = 0.2;
    cfg.artfctdef.muscle.interactive = 'yes';
    [cfg, artifcat_muscle] = ft_artifact_muscle(cfg, dataAll_preproc1);
 
%6.3 Remove semi-automatically determined artifacts
    cfg.artfctdef.reject = 'partial';
    cfg.artfctdef.minaccepttim = 1; %Minimum length in s of remaining trial
    % cfg.artfctdef.feedback        = 'yes';
    dataAll_EEGcleanedSemiauto = ft_rejectartifact(cfg,dataAll_preproc1);

%% 7.1 Running ICA
rng('default'); %resetting random numbers so that ICA will always produce same result on same data.
cfg = [];
cfg.method = 'runica'; 
cfg.runica.pca = rank(dataAll_EEGcleanedSemiauto.trial{1}) % rank is lower than number of channels as removing bad channels by interpolation decreases rank
icaComponentStruct = ft_componentanalysis(cfg, dataAll_EEGcleanedSemiauto);


%7.2 manually inspecting components to decide which components to remove
%explained variance
[~,~,~,~,explained] = pca(icaComponentStruct.trial{1});
figure
plot(cumsum(explained));
xlabel('component')
ylabel('cumulative % variance explained')

numComp=1;
while sum(explained(1:numComp))< 90
    numComp=numComp+1;
end
varExplained= sum(explained(1:numComp));
EEGdata.explainedVarVec= explained;
EEGdata.numCompsExplaining= numComp;
EEGdata.varExplained= varExplained;
samplingFrequency= EEGdata2.fsample;
SP_CreateICA_Figures(icaComponentStruct, numComp,samplingFrequency, subject);

 figure
 cfg = [];
 cfg.component = 1:20;
 cfg.layout    = 'EEG1020.lay'; % specify the layout file that should be used for plotting
 cfg.viewmode = 'component';
 ft_topoplotIC(cfg,icaComponentStruct);
 
 cfg = [];
 cfg.layout    = 'EEG1020.lay'; % specify the layout file that should be used for plotting
 cfg.viewmode = 'component';
 cfg.component = [1:40];
 ft_databrowser(cfg, icaComponentStruct)

%7.3 rejecting ICA components 
cfg = [];
cfg.component = [] ;%components to reject (Through manual inspection of powerpoint EEG/Data/Subject1/Preprocessing/ICA/ppt/
EEGdata_ICARemoved = ft_rejectcomponent(cfg, icaComponentStruct);


