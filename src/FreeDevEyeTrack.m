response = 0;
responseText = 'incorrect';

numTrials = 72;
abortedTrials = zeros(numTrials,1);
correctOrIncorrect = zeros(numTrials,1);
respTimeInc = zeros(numTrials,1);
rewardChoice = zeros(numTrials,1);
fatigueRating = nan(numTrials,1);
keyPress = zeros(numTrials,1);
abortedTrials2 = zeros(numTrials,1);
j = 1;

%%% 4. Calibrate the eye tracker
Eyelink('command','calibration_area_proportion = 0.5 0.5');
Eyelink('command','validation_area_proportion = 0.48 0.48');
EyelinkDoTrackerSetup(el);
WaitSecs(0.1);

eye_used = Eyelink('EyeAvailable'); % get eye that's tracked (only track left eye)
if eye_used == el.BINOCULAR % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

%========================================================================
%this loop itterates the specified number of trials. every iteration, a
%user will have a choice between a easy and a difficult task by selecting
%from two potential choices one of which has higher value than the other.
%if they choose the difficult option, they will be presented with eight
%letters in a circle and have to find a T and report its orientation. in the easy
%choice users will have only the t presented to them and will still have to
%report its orientation. In every trial the user is given a prompt to
%decide on the orientaion of the t and is also given feedback based upon
%weather or not their response was correct. this loop
%handles trial abortions and retries aborted at the end.
%========================================================================

while j <= numTrials
    
    %%% 5. Mark events, messages, etc. in dataviwer trial
    Eyelink('Message', 'TRIAL_%d', trial);
    % This supplies the title at the bottom of the eyetracker display
    Eyelink('command', 'record_status_message "TRIAL %d OF %d"', j, numTrials);
    WaitSecs(0.001);
    
    %%% 6. START RECORDING each trial
    Eyelink('StartRecording');
    error=Eyelink('CheckRecording');
    if(error~=0)
        isEyeInside = false;
    end
  
     if j == 1
       DrawFormattedText(window, 'Free Choice Trials', 'center',...
           screenYpixels * 0.25, [0 0 0]); 
        Screen('Flip', window);
        WaitSecs(2);
    end
   % while isEyeInside
        
        Screen('DrawTexture', window, dispImageCross, [], crossPos);
        Screen('TextSize', window, 30);
        DrawFormattedText(window, 'Choose the reward amount using the left and right arrow keys', 'center',...
            screenYpixels * 0.25, [0 0 0]);
        
         %calculate random incentive amounts for trial 1 = 2 is the only
        %unique case because there cannot be 2 1 incentives presented the
        %rest follow the order
        % 2 = 2, 3 =3... etc
        if trialData(j, 5)==1
            incentiveForTrial = disTwoIncentive;
        elseif trialData(j, 5)==2
            incentiveForTrial= disTwoIncentive;
        elseif trialData(j, 5)==3
            incentiveForTrial= disThreeIncentive;
        elseif trialData(j, 5)==4
            incentiveForTrial= disFourIncentive;
        elseif trialData(j, 5)==5
            incentiveForTrial= disFiveIncentive;
        elseif trialData(j, 5)==6
            incentiveForTrial= disSixIncentive;
        end
        
        incentiveAmt(j) = trialData(j, 5);
        
        
        %make random position of incentives for presentation, if trual data
        %= 1, the larger incentive will be presented on the right and if it
        %is 2 the larger incentive will be presented on the users left
        if  trialData(j, 4)==1
            Screen('DrawTexture', window, disOneIncentive, [], leftRectPos);
            Screen('DrawTexture', window, incentiveForTrial, [], rightRectPos);
        elseif  trialData(j, 4)==2
            Screen('DrawTexture', window, incentiveForTrial, [], leftRectPos);
            Screen('DrawTexture', window, disOneIncentive, [], rightRectPos);
        end
        
        
        
        %Starting response time interval
        [~,actualFlipTime,~,~]= Screen('Flip', window);
        
        %Clearing and initializing keyboard config for trial(i)
        
        [secs, ~,~] = KbWait;
        
        %Storing response interval time
        respTimeInc(j,1) = secs - actualFlipTime;
        
        [pressed, firstPress] = KbQueueCheck(deviceIndices);
        
        
        WaitSecs(0.25);
        
        %Conditional for easy task choice
        if (firstPress(37) > 0 &&  trialData(j, 4)==1) || (firstPress(39) > 0 &&  trialData(j, 4)==2)
            
            %record data on which reward was chosen
            rewardChoice(j,1) = 1;
            %======================================
            %EASY TASK CODE HERE
            %======================================
            
            
        %determine orientation of t presented 1 means the t is upright 0
        %means the t is upsidedown
            if trialData(j, 3) == 1
                orientationT = dispImageT;
                
            elseif trialData(j, 3) == 0
                orientationT = dispImageUSDT;
                
            end
            
            %record data on how the t is oriented
            orientationOfT = trialData(j, 3);
            up = 1;
            down = 0;
            
            %drawing T to screen given value in random T location matrix
        % a value of 1 indicates the right most value position of the
        % circle, a value of 2 indicates a up rihgt diagonal orientation
        % and then continues to increase counter clock wise
            if trialData(j, 2) == 1
                Screen('DrawTexture', window, orientationT, [], rightMostRect);
            elseif trialData(j, 2) == 2
                Screen('DrawTexture', window, orientationT, [], diagonalUpRight);
                
            elseif trialData(j, 2) == 3
                Screen('DrawTexture', window, orientationT, [], vertMostRect);
                
            elseif trialData(j, 2) == 4
                Screen('DrawTexture', window, orientationT, [], diagonalUpLeft);
                
            elseif trialData(j, 2) == 5
                Screen('DrawTexture', window, orientationT, [], leftMostRect);
                
            elseif trialData(j, 2) == 6
                Screen('DrawTexture', window, orientationT, [], diagonalDownLeft);
                
            elseif trialData(j, 2) == 7
                Screen('DrawTexture', window, orientationT, [], downMostRect);
                
            elseif trialData(j, 2) == 8
                Screen('DrawTexture', window, orientationT, [], diagonalDownRight);
                
            end
            %record location of drawn t
            occupiedByT = trialData(j, 2);
            
            %store data on t location in circle
            positionOfT(j,1) = occupiedByT;
            
            
            Screen('DrawTexture', window, dispImageCross, [], centerRect);
             %present task screen for 2 seconds
       [~,start1, ~] =  Screen('Flip', window);
        WaitSecs(0.2);
        
        timeToWait = 2;
        startTime = GetSecs;
        timeInLoop = 0;
        flag = 0;
       
        
          %++++++++++++IMPORTANT++++++++++++++
        %THIS KbWait DECIDES IF THE TRIALS IS ABORTED OR NOT, THE KbWait
        %SPECIFIES A TIME TO BE WAITED, IF THAT TIME IS EXCEEDED IT SKIPS
        %THE FOLLOWING IF BLOCK AND EXECUTES CODE TO ABORT THE TRIAL. IF
        %A KEY BOARD INPUT IS DETECTED, IT WILL ENTER THE IF BLOCK AND
        %DECIDE IF THE KEY PRESS WAS CORRECT OR INCORRECT. IF IT WAS NOT
        %CODE WILL TRIGGER TO ABORT THE TRIAL
      KbWait([], [], start1 + timeToWait);
      timeWaited = GetSecs;
      respTime(j,1) = timeWaited-start1;

       clear Press;
        [pressed, Press] = KbQueueCheck(deviceIndices);
            
            if Press(38) > 0 || Press(40)>0
                %code to tell user how many points they gained
                rewardAmtText = num2str(trialData(j, 5));
                plus = '+';
                responseText = [plus ' ' rewardAmtText];
                flag = 1;
                % code to find if user input was correct
                
                %user presses up arrow and t is up so correct
                if Press(38) > 0 && trialData(j, 3) == up
                    text = 'correct';
                    response = 1;
                    keyPress(j,1) = 1;
                   responseText = '+ 1';
                    
                    
                    
                    %user presses down arrow and t is down so correct
                elseif Press(40) > 0 && trialData(j, 3) == down
                    text = 'correct';
                    response = 1;
                    keyPress(j,1) = 0;
                    responseText = '+ 1';
                    
                    
                    %user presses up arrow and t is down so incorrect
                elseif Press(38) > 0 && trialData(j, 3) == down
                    text = 'incorrect';
                    responseText = '+ 0';
                    response = 0;
                    keyPress(j,1) = 1;
                    
                    %user presses down arrow and t is up so incorrect
                elseif Press(40) > 0 && trialData(j, 3) == up
                    text = 'incorrect';
                    responseText = '+ 0';
                    response = 0;
                    keyPress(j,1) = 0;
                end
                
               Screen('DrawTexture', window, dispImageCross, [], centerRect);
                Screen('Flip', window);
                WaitSecs(3-respTime(j,1));

                %record response data
                correctOrIncorrect(j,1) = response;
                %print feedback from decesion in trial to screen
                DrawFormattedText(window, text,'center' , yCenter, black);
                DrawFormattedText(window, responseText, 'center',screenYpixels * 0.25, black);
                Screen('Flip', window);
                WaitSecs(2)
               % DrawFormattedText(window, responseText, 'center',screenYpixels * 0.25, black);
            end
            
        
        
        
  %++++++THIS CODE CONTROLLS WEATHER OR NOT THE TRIAL IS ABORTED, IF THE
  %BOOLEAN CONTAINED IN THE BLOCK IS FALSE THE TRIAL IS ABORTED

  
   if flag == 0
        isEyeInside = false;
        text = 'TOO LATE';
         DrawFormattedText(window, text,'center' , yCenter, black);
         Screen('Flip', window);
        WaitSecs(2);
        
    end
    

        %record response data
        correctOrIncorrect(j,1) = response;
        %print feedback from decesion in trial to screen
        Screen('DrawTexture', window, dispImageCross, [], centerRect);

        Screen('Flip', window);
        
        WaitSecs(2);
            
            
            
            %code for confidence assessment EVERY 10 TRIALS
            decideConfRating = mod(j,10);
            if decideConfRating == 0
                
                DrawFormattedText(window, responseText, 'How woud you rate your mental fatigue?',screenYpixels * 0.25, black);
                [~, trial_datum, ~, ~, ~ ,~] = Ratings('confidence', window,p);
                fatigueRating(j) = trial_datum;
                
                Screen('DrawTexture', window, dispImageCross, [], centerRect);
                Screen('Flip', window);
                WaitSecs(1);
                
            end
            
            
            
            %Conditional for difficult task choice
        elseif (firstPress(37) > 0 &&  trialData(j, 4)==2) || (firstPress(39) > 0 &&  trialData(j, 4)==1)
            
            %record data on which option was chosen
            rewardChoice(j,1) = 2;
            
            %======================================
            %DIFFICULT TASK CODE HERE
            %======================================
            
            Screen('DrawTexture', window, dispImageCross, [], centerRect);
            
            
            
            %determine orientation of t presented 1 means the t is upright 0
            %means the t is upsidedown
            if trialData(j, 3) == 1
                orientationT = dispImageT;
            elseif trialData(j, 3) == 0
                orientationT = dispImageUSDT;
                
            end
            
            %record data on how the t is oriented
            orientationOfT = trialData(j, 3);
            up = 1;
            down = 0;
            
            %drawing T to screen given value in random T location matrix
            % a value of one indicates the right most value position of the
            % circle, a value of two indicates a up rihgt diagonal orientation
            % and then continues to increase counter clock wise
            if trialData(j, 2) == 1
                Screen('DrawTexture', window, orientationT, [], rightMostRect);
                
            elseif trialData(j, 2) == 2
                Screen('DrawTexture', window, orientationT, [], diagonalUpRight);
                
            elseif trialData(j, 2) == 3
                Screen('DrawTexture', window, orientationT, [], vertMostRect);
                
            elseif trialData(j, 2) == 4
                Screen('DrawTexture', window, orientationT, [], diagonalUpLeft);
                
            elseif trialData(j, 2) == 5
                Screen('DrawTexture', window, orientationT, [], leftMostRect);
                
            elseif trialData(j, 2) == 6
                Screen('DrawTexture', window, orientationT, [], diagonalDownLeft);
                
            elseif trialData(j, 2) == 7
                Screen('DrawTexture', window, orientationT, [], downMostRect);
                
            elseif trialData(j, 2) == 8
                Screen('DrawTexture', window, orientationT, [], diagonalDownRight);
                
            end
            %decide where the t is located
            occupiedByT = trialData(j, 2);
            %store data on t location in circle
            positionOfT(j,1) = occupiedByT;
            
            %loop is used to find orientation of L and assign it to trial image
            %and draw to screen
            for k = 1:8
                %find the orientation of the L then assign it to the trial image
                %variable
                if randLOrientationArray(k) == 1
                    imageForTrial = upsideDownL;
                elseif randLOrientationArray(k) == 2
                    imageForTrial = normalL;
                elseif randLOrientationArray(k) == 3
                    imageForTrial = sideL;
                elseif randLOrientationArray(k) == 4
                    imageForTrial = sideWL;
                end
                
                %Draw L with proper orientation to all locations except for
                %location where T is located
                if randLPositionArray(k) == occupiedByT
                    %do nothing if the positon is occupied by the t for trial
                elseif  randLPositionArray(k) == 1
                    Screen('DrawTexture', window, imageForTrial, [], rightMostRect);
                elseif  randLPositionArray(k) == 2
                    Screen('DrawTexture', window, imageForTrial, [], diagonalUpRight);
                elseif  randLPositionArray(k) == 3
                    Screen('DrawTexture', window, imageForTrial, [], vertMostRect);
                elseif  randLPositionArray(k) == 4
                    Screen('DrawTexture', window, imageForTrial, [], diagonalUpLeft);
                elseif  randLPositionArray(k) == 5
                    Screen('DrawTexture', window, imageForTrial, [], leftMostRect);
                elseif  randLPositionArray(k) == 6
                    Screen('DrawTexture', window, imageForTrial, [], diagonalDownLeft);
                elseif  randLPositionArray(k) == 7
                    Screen('DrawTexture', window, imageForTrial, [], downMostRect);
                elseif  randLPositionArray(k) == 8
                    Screen('DrawTexture', window, imageForTrial, [], diagonalDownRight);
                    
                end
                
            end
            
            
              %present task screen for 2 seconds
       [~,start1, ~] =  Screen('Flip', window);
        WaitSecs(0.2);
        
        timeToWait = 2;
        startTime = GetSecs;
        timeInLoop = 0;
        flag = 0;
       
        
         %++++++++++++IMPORTANT++++++++++++++
        %THIS KbWait DECIDES IF THE TRIALS IS ABORTED OR NOT, THE KbWait
        %SPECIFIES A TIME TO BE WAITED, IF THAT TIME IS EXCEEDED IT SKIPS
        %THE FOLLOWING IF BLOCK AND EXECUTES CODE TO ABORT THE TRIAL. IF
        %A KEY BOARD INPUT IS DETECTED, IT WILL ENTER THE IF BLOCK AND
        %DECIDE IF THE KEY PRESS WAS CORRECT OR INCORRECT. IF IT WAS NOT
        %CODE WILL TRIGGER TO ABORT THE TRIAL
      KbWait([], [], start1 + timeToWait);
      timeWaited = GetSecs;
      respTime(j,1) = timeWaited-start1;

       clear Press;
        [pressed, Press] = KbQueueCheck(deviceIndices);
            
            if Press(38) > 0 || Press(40)>0
                %code to tell user how many points they gained
                rewardAmtText = num2str(trialData(j, 5));
                plus = '+';
                responseText = [plus ' ' rewardAmtText];
                flag = 1;
                % code to find if user input was correct
                
                %user presses up arrow and t is up so correct
                if Press(38) > 0 && trialData(j, 3) == up
                    text = 'correct';
                    response = 1;
                    keyPress(j,1) = 1;
                    
                    
                    %user presses down arrow and t is down so correct
                elseif Press(40) > 0 && trialData(j, 3) == down
                    text = 'correct';
                    response = 1;
                    keyPress(j,1) = 0;
                    
                    
                    %user presses up arrow and t is down so incorrect
                elseif Press(38) > 0 && trialData(j, 3) == down
                    text = 'incorrect';
                    responseText = '+ 0';
                    response = 0;
                    keyPress(j,1) = 1;
                    
                    %user presses down arrow and t is up so incorrect
                elseif Press(40) > 0 && trialData(j, 3) == up
                    text = 'incorrect';
                    responseText = '+ 0';
                    response = 0;
                    keyPress(j,1) = 0;
                end
                
              Screen('DrawTexture', window, dispImageCross, [], centerRect);
                Screen('Flip', window);
                WaitSecs(3-respTime(j,1));

                %record response data
                correctOrIncorrect(j,1) = response;
                %print feedback from decesion in trial to screen
                DrawFormattedText(window, text,'center' , yCenter, black);
                DrawFormattedText(window, responseText, 'center',screenYpixels * 0.25, black);
                Screen('Flip', window);
                WaitSecs(2)
               % DrawFormattedText(window, responseText, 'center',screenYpixels * 0.25, black);
            end
            
        
        
        
 
%++++++THIS CODE CONTROLLS WEATHER OR NOT THE TRIAL IS ABORTED, IF THE
  %BOOLEAN CONTAINED IN THE BLOCK IS FALSE THE TRIAL IS ABORTED
    if flag == 0
        isEyeInside = false;
        text = 'TOO LATE';
        DrawFormattedText(window, text,'center' , yCenter, black);
                Screen('Flip', window);

        WaitSecs(2)

        
    end
    

        %record response data
        correctOrIncorrect(j,1) = response;
        %print feedback from decesion in trial to screen
        Screen('DrawTexture', window, dispImageCross, [], centerRect);

        Screen('Flip', window);
        
        WaitSecs(2);
        
            %code for confidence assessment every 10 trials
            decideConfRating = mod(j,10);
            if decideConfRating == 0 || j == 1
                
                DrawFormattedText(window, responseText, 'How would you rate your mental fatigue?',screenYpixels * 0.25, black);
                [~, trial_datum, ~, ~, ~ ,~] = Ratings('confidence', window,p);
                fatigueRating(j) = trial_datum;
                Screen('DrawTexture', window, dispImageCross, [], centerRect);
                Screen('Flip', window);
                WaitSecs(1);
                
            end
            
            
        end
        
        clear firstPress
        
        
        
  %  end
    
       %++++++IMPORTANT+++++++++++++++++++
    %this if statment houses code that takes the data for the setup in the
    %aborted trial and moves it to the end
    if ~isEyeInside
        numTrials = numTrials + 1;
        countAbortFree = countAbortFree + 1;
        randTarray(numTrials) = randTarray(j);
        orientationTArray(numTrials) = orientationTArray(j);
        cardinalVec(numTrials) = cardinalVec(j);
        incentiveVec(numTrials) = incentiveVec(j);
        trialData(numTrials,1) = j;
        trialData(numTrials, 2) = randTarray(j);
        trialData(numTrials, 3) = orientationTArray(j);
        trialData(numTrials, 4) = cardinalVec(j);
        trialData(numTrials, 5) = incentiveVec(j);
        abortedTrials(numTrials) = 0;
        abortedTrials(j) = 1;
        abortedTrials2(j) = 1;
        isEyeInside = true;
        respTimeInc(numTrials) = 0;
        rewardChoice(numTrials) = 0;
        fatigueRating(numTrials) = 0;
        keyPress(numTrials) = 0;
        correctOrIncorrect(numTrials) = 0;
        respTime(numTrials) = 0;
        
        
        
        
        DrawFormattedText(window, 'TRIAL ABORTED','center' , yCenter, black);
        Screen('Flip', window);
        WaitSecs(2);
        
        
        
    end
    
    
    %%% 7. END RECORDING each trial
    Eyelink('StopRecording');
    
    j = j + 1;
end
trialData(:, 6) = abortedTrials;
completedFree = 1;
trialChoice = 0;



finalTrialData.free.results.responseTimeIncentive =respTimeInc;
finalTrialData.free.results.rewardChoice = rewardChoice;
finalTrialData.free.results.fatigueRating = fatigueRating;
finalTrialData.free.results.keyPress = keyPress;
finalTrialData.free.results.correctOrIncorrect = correctOrIncorrect;
finalTrialData.free.results.respTimeSearch = respTime;
finalTrialData.free.results.abortedTrials = abortedTrials;
finalTrialData.free.results.allTrialsData = horzcat([respTimeInc, rewardChoice, fatigueRating, keyPress, correctOrIncorrect, respTime, abortedTrials]);
finalTrialData.free.results.dataDescription = {'Coloum 1 represents the response time for choosing incentive'; 'Coloum 2 represents the reward choice(difficult = 2, easy = 1)'; 'Coloumn 3 represents self assessed fatigue on a scale of 1 to 10';...
    'Coloum 4 represents key presses to decide the orientation of t( 1 = up, 0 = down)'; 'Coloumn 5 represents weather or not a trial was correct (1 = correct, 0 = incorrect)';... 
    'Coloum 6 represents the time it took for a person to decide the orientation of T'; 'Coloum 7 represents the aborted trials (1 = aborted, 0 = succesful)'};
    
finalTrialData.free.trialData.description = {'Coloum 1 represents the trial number(1-72 + aborted trials)'; 'Coloum 2 represents the position of T in the circle (0 is farthest right and increases traveling counterclock wise around the circle)';...
    'Coloum 3 represents the orientation of T (1 = upright T, 0 = upsidedown)'; ' Coloum 4 where the incentive is drawm (1 = drawn on right, 2 = drawn on left)';'Coloum 5 represents the incentive value shown 1-6 where an incentive value of 1 will be handled as a 2';'Coloum 6 is where aborted trials are represented (1= aborted, 0 = completed)'}; 


finalTrialData.free.trialData.data = trialData;


%finalDataFree = [incentiveAmt,trialData(:, 3),trialData(:, 2),correctOrIncorrect,respTime];

%save('V1mollerusBell\finalDataFree.mat','finalData');
%save('V1mollerusBell\finalTrialData.mat','finalTrialData');

% load('finalDataFree.mat');
