
%% Script for extracting Eye tracking data and events from raw asc. file

%function [data, events, headers] = SP_EY_ParsingASC(subjectNumber);

for s= [] % Inser participants' index numbers as indicated on their raw asc. files

filename= ['SP_', num2str(s),'.asc']; % insert file name
    %% open ASC and parse
    [fid, errmsg] = fopen(filename );
    %[fid, errmsg] = fopen([origindirectory filesep ascflnm], 'r');
    started = false; cnt = 0;
    headers = table();
    events = table();
    data = table();
    while ~feof(fid)
        cnt = cnt+1;
        if mod(cnt,1000)==0; disp(cnt); end
        tline = fgetl(fid);
        splt = strsplit(tline,char(32));
        % Extract interesting headers from first segment of data 
        % (until "start" marking)
        if ~started
            if strcmp(splt{1},'**') && length(splt)>1
                if startsWith(tline(4:end),'CONVERTED FROM')
                    nm = 'CONVERTED FROM';
                elseif startsWith(tline(4:end),'Recorded by')
                    nm = 'Recorded by';
                elseif startsWith(tline(4:end),'EYELINK')
                    nm = 'EYELINK';
                else
                    dts = strfind(tline,':');
                    nm = strtrim(tline(3:dts(1)-1));
                end
                vl = tline(strfind(tline,nm)+length(nm)+1:end);
                headers = [headers; table({nm},{strtrim(vl)},'VariableNames',{'name','val'})];
            elseif startsWith(splt{1},'START')
          %%elseif strcmp(splt{1},'START')
                startTime = str2double(splt{2});
                started = true;
            end
        % From body of data, extract events and raw eye data separately 
        else
            if isnan(str2double(splt(1)))
                events = [events; table(splt(1),{strtrim(tline(length(splt{1})+1:end))},'VariableNames',{'type','value'})];
            else
                data(end+1,1:4) = array2table(str2double(splt(1:4)));
               
            end
        end
    end
    fclose(fid);

    %data.Properties.VariableNames = colnames(1:4);
    %data.time = data.time - startTime;
    
    save(sprintf('results\\Mdata_%d.mat',s),'data');
    save(sprintf('results\\Mevents_%d.mat',s),'events');
    
    clear
end



