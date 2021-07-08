function [] = pcPlots (DataMatrix, partCode, FreeForce)

d = DataMatrix;
pCode = partCode;
ff = d(:,1);
sn = d(:,2);
tr = d(:,3);
tori = d(:,4);
loc = d(:,5);
abtT = d(:,8);
incV = d(:,7);
TrSp = d(:, 9);
CI = d(:, 14)
x = 1:6;


for i = 1:2
    pC = [];
    for j = 1:6
       correct = find(CI == 1& ff == FreeForce & sn == partCode& TrSp == i& incV == j);
       total = find(ff == FreeForce & sn == partCode& TrSp == i& incV == j);
       pC(j) = (length(correct)/length(total))*100;
    end 
    
     if i == 1
      plot(x-0.1, pC, 'bo-'); hold on 
      
    elseif i == 2
      plot(x+0.1, pC, 'rx-'); hold on 
    
    
     end
    legend('Regular Trial','Speeded Trial')

      title('Percent Correct By Reward')
    xlabel('Reward Size (1-6)')
    ylabel('Percent Correct');




end