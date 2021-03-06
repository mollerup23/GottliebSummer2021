function [ ] = abortPerBlock( matrix, P_code )

y = [];

d = matrix;
indices = find(d(:,2)~=P_code);
d(indices,:)=[];
speed = d(:,9);
freeForce = d(:,1);
abort = d(:,16);

slowFree = 0;
slowForce = 0;
fastFree = 0;
fastForce = 0;
countAbort = 0;
textArr = [];
m1 = 0;
m2 = 0;
m3 = 0;
m4 = 0;
counter = 1;
legARR = [];
xForce = [];
xFree = [];
blkNum = d(:, 17);
TrSp = d(:, 9);
ff = d(:,1);


for i = 3:10
   indecies = find(blkNum == i& abort == 1)
   abortPlot = length(indecies)/30
   indecies2 = (find(blkNum == i));
              % pointForTrial = 'gx- ';

  % if length(indecies) > 0
   if ff(indecies2(1)) == 1 && TrSp(indecies2(1)) == 1
       pointForTrial = 'bo-';
           elseif  ff(indecies2(1)) == 1 && TrSp(indecies2(1)) == 2
       
           pointForTrial = 'ro-';
           elseif  ff(indecies2(1)) == 2 && TrSp(indecies2(1)) == 1
       
           pointForTrial = 'bx-';
           elseif  ff(indecies2(1)) == 2 && TrSp(indecies2(1)) == 2
       
           pointForTrial = 'rx-';

    
   %end
   end
   plot(i-2, abortPlot, pointForTrial); hold on
end
xlabel('Block Number (1-8)')
    ylabel('Percent Trials Aborted');



end

