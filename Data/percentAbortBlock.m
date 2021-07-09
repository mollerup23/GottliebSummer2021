function [ output_args ] = percentAbortBlock( matrix, P_code )
load final;

d = matrix;
sbjNum = d(:,2);

y = [];

sbjInd = find(sbjNum == P_code);
sbjMat = d(sbjInd,:);
speed = sbjMat(:,9);

for s = 1:2
    speedInd = find(speed == s);
    sbjSpeedMat = sbjMat(speedInd,:);
    abortVec = sbjSpeedMat(:,16);
    
    numAbort1 = 0;
    numAbort2 = 0;
    numAbort3 = 0;
    numAbort4 = 0;
    
    for i = 1:120
        if abortVec(i) == 0 & i <= 30
            numAbort1 = numAbort1 + 1;
        elseif abortVec(i) == 0 & i <= 60
            numAbort2 = numAbort2 + 1;
        elseif abortVec(i) == 0 & i <= 90
            numAbort3 = numAbort3 + 1;
        elseif abortVec(i) == 0 & i <= 120
            numAbort4 = numAbort4 + 1;
        end
    end
    numAbortBlockVec = [numAbort1, numAbort2, numAbort3, numAbort4];
    
    for j = 1:4
        yPoint(j) = numAbortBlockVec(j);
    end
    
    x = 1:4;
    if s == 1
        plot(x-0.1, ((yPoint/30)*100), 'b-o'); hold on
    elseif s == 2
        plot(x-0.1, ((yPoint/30)*100), 'r-x'); hold on
    end
    
    title('Percent Aborted Trials per Block')
    %legend(' ', ' ', 'Regular', 'Speeded')
    xlabel('block numbers 1-4');
    ylabel('percent aborted trials');
    
end

end

