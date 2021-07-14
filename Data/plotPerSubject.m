function [] = plotPerSubject(DataMatrix, SubjectCodes)
SC = SubjectCodes;
d = DataMatrix;

for i = 1:length(SC)
    figure;
    for j = 1:2
        if j == 1
            subplot(4,3,1); 
            title('No Feedback')
            hold on
            RTincPlot(d, SC(i), j)
            subplot(4,3,4); hold on
            pcPlots(d,SC(i),j);
            subplot(4,3,7); hold on
            abtPlots(d,SC(i),j);
        elseif j ==2
            subplot(4,3,2); 
            title('Feedback')
            hold on 
            RTincPlot(d, SC(i),j)
            subplot(4,3,5); hold on
            pcPlots(d,SC(i),j);
            subplot(4,3,8); hold on
            abtPlots(d,SC(i),j);
   
        end
            subplot(4,3,10); hold on
            rcPlots(d,SC(i),0);
            subplot(4,3,11); hold on
            rcfbPlots(d,SC(i),0);
            subplot(4,3,3); hold on 
            pcFR(d,SC(i),0);
            subplot(4,3,6); hold on
            abortPerBlock(d, SC(i));
    end
    
    titleHead = 'Participant';
    SCstr = num2str(SC(i));
    titleStr = strcat(titleHead, {' '}, SCstr, {' '}, {'(Regular/Speeded = Blue/Red, No Feedback/Feedback = O/X)'});
    suptitle(titleStr);
end
end