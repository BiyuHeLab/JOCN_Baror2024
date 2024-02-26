function SP_CreateICA_Presentation(subjectName, subjectICADirectory,numComps,ICAtemplateFileName)
subjectName=116;
ICAtemplateFileName='ICA_Template.pptx';
pngDirectory = [subjectICADirectory '/png/'];
pptDirectory = [subjectICADirectory '/ppt/'];

if ~exist(pptDirectory,'dir')
    mkdir(pptDirectory);
end

import mlreportgen.ppt.*
slidesFile = [pptDirectory '/' subjectName '_ICAComponents.pptx'];

slides = Presentation(slidesFile,ICAtemplateFileName);

presentationTitleSlide = add(slides,'Title Slide');
replace(presentationTitleSlide,'Title',['ICA components ' subjectName]);

for i = 1:numComps
    pictureSlide = add(slides,'ICALayout');
    
    nmData = [pngDirectory 'Data' num2str(i) '.png'];
    pnameData = Picture(nmData);
    data = find(pictureSlide,'Data');
    replace(data(1),pnameData);
    
    nmPwelch = [pngDirectory 'Pwelch' num2str(i) '.png'];
    pnamePwelch = Picture(nmPwelch);
    pwelc = find(pictureSlide,'Pwelch');
    replace(pwelc(1),pnamePwelch);
    
    
    nmTopo = [pngDirectory 'Topo' num2str(i) '.png'];
    pnameTopo = Picture(nmTopo);
    topo = find(pictureSlide,'Topo');
    replace(topo(1),pnameTopo);
    
    head1 = Paragraph(['Component ' num2str(i)]);
    replace(pictureSlide,'Title',head1);
    
end

close(slides);

    