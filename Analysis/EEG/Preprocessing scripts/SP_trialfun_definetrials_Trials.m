function [trl, trl_header] = SP_trialfun_definetrials_Trials(cfg)

%read in header information and events from dataset
hdr = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

numOfBlocks=4;
trialsPerBlock=100;

trl_header = {'trial_startsample', 'trial_endsample','block_number'};
trl = [];
blockCounter = 0;
ind=1;
for i=1: length(event)

    if ~isempty(event(i).value)
    trig= event(i).value;
    if trig(1)== 'S'
        triggers(ind,1)= str2num(trig(4));
        triggers(ind,2)= event(i).sample;
        ind=ind+1;
    end
    end
end
allTrialMat= zeros(numOfBlocks*trialsPerBlock,4);
allTrialMat(:,1:2)= triggers(find(triggers(:,1)==1),1:2);
allTrialMat(:,3:4)= triggers(find(triggers(:,1)==3),1:2);

for i=1:length(allTrialMat);
    trl(i,1)= allTrialMat(i,2)+16-500;
    trl(i,2)= allTrialMat(i,4)+16;
    trl(i,3)= -500;
    trl(i,4)= i;
end

