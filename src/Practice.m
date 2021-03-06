response = 0;
responseText = 'incorrect';
%initialize variables for data storage
abortedTrials = nan(numTrials,1);
correctOrIncorrect = nan(numTrials,1);
respTimeInc = nan(numTrials,1);
rewardChoice = nan(numTrials,1);
fatigueRating = nan(numTrials,1);
keyPress = nan(numTrials,1);
abortedTrials2 = nan(numTrials,1);
randSpeedVecData = nan(numTrials, 1);
confidence = true;

j = 1;


eye_used = Eyelink('EyeAvailable'); % get eye that's tracked (only track left eye)
if eye_used == el.BINOCULAR % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

Eyelink('command','calibration_area_proportion = 0.5 0.5');
Eyelink('command','validation_area_proportion = 0.48 0.48');
EyelinkDoTrackerSetup(el);
WaitSecs(0.1);

%========================================================================
%this loop itterates the specified number of trials. every iteration, a
%user will be shown an incentive that can be eithe 10 or 30. the user has
%to fixate on the center starting at the offset of the incentives and
%ending once they have made a decesion or the trial has started. the user
%will ALWAYS be given a difficult search array. if fixation is broken or a
%user takes too long to respond, the trial will be aborted.
%========================================================================
fixation_pos = crossPos;
while j <= numTrials
    
    %% 5. Mark events, messages, etc. in dataviwer trial
    Eyelink('Message', 'TRIAL_%d', j);
    % This supplies the title at the bottom of the eyetracker display
    Eyelink('command', 'record_status_message "TRIAL %d OF %d"', j, numTrials);
    WaitSecs(0.001);
    isEyeInside = true;
    
    %%% 6. START RECORDING each trial
    Eyelink('StartRecording');
    error=Eyelink('CheckRecording');
    if(error~=0)
        
    end
    
    %initialize flag to one every trial, this variable is used to determine
    %if the user has made a decesion within the proper amount of time
    flag = 1;
    
    [pressed, firstPress] = KbQueueCheck(deviceIndices);
    WaitSecs(0.25);
    clear pressed;
    clear firstPress;
    
    WaitSecs(0.5);
    %variable "isForce" is initialized to false inorder to draw the proper
    %incentive in the script "DrawIncentiveForce"
    isForce = false;
    DrawIncentiveForce;
    %drawing and flipping incentive screen
    Screen('DrawTexture', window, dispImageCross, [], crossPos);
    Screen('Flip', window);
    
    if strcmp(elstate, 'on')
        % Mark events, messages, etc. in dataviwer trial
        Eyelink('Message', 'Initial incentive shown');
        WaitSecs(0.001);
    end
    WaitSecs(1);
    Screen('DrawTexture', window, dispImageCross, [], crossPos);
    Screen('Flip', window);
    WaitSecs(0.1);
    
    
    
    if strcmp(elstate, 'on')
        % Mark events, messages, etc. in dataviwer trial
        Eyelink('Message', 'Fix cross shown, no incentive shown');
        WaitSecs(0.001);
    end
    
    
    % Wait until fixation in fixation cross (abort trial after 200ms)
    T_delay = 0.5; %rand time delay
    nofixflag=1;
    startrt=GetSecs;
    
    %fixation check for initial fixation
    while (GetSecs-startrt)<=T_delay %|| nofixflag==1
        if Eyelink('NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink('NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = evt.gy(eye_used+1);
                
                % do we have valid data and is the pupil visible?
                if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                    eyemx=x;
                    eyemy=y;
                    % if no fixation
                    if (eyemx>fixation_pos(1)-150 && eyemx < fixation_pos(3)+150 && eyemy>fixation_pos(2)-150 && eyemy<fixation_pos(4)+150) %%change fixation_pos
                        nofixflag=0;
                        break
                    elseif (eyemx<fixation_pos(1)-150 || eyemx > fixation_pos(3)+150 || eyemy<fixation_pos(2)-150 || eyemy>fixation_pos(4)+150)% broke fixation reset time
                        
                        %abort trial if there is an issue with the initial
                        %fixation
                        AbortFree;
                    end
                end
            end
        end
    end
    
    %enter this if statement if the initial fixation is passed
    if nofixflag==0
        
        T_delay = randi([3 5],1);
        nofixtimeflag=1;
        startrt=GetSecs;
        totalFixTime =0;
        totalFixTimeout=0;
        Novalid=0;
        fixTime = T_delay;
        
        %check fixation during delay to stimilus presentation
        while (GetSecs-startrt)<=T_delay  && Novalid==0
            if Eyelink('NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink('NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        eyemx=x;
                        eyemy=y;
                        % if no fixation
                        if  (eyemx>fixation_pos(1)-150 && eyemx < fixation_pos(3)+150 && eyemy>fixation_pos(2)-150 && eyemy<fixation_pos(4)+150)
                            totalFixTime = totalFixTime + 50;
                            totalFixTimeout=0;
                            if totalFixTime >= fixTime-250
                                nofixtimeflag=0;
                            end
                        elseif (eyemx<fixation_pos(1)-150 || eyemx > fixation_pos(3)+150 || eyemy<fixation_pos(2)-150 || eyemy>fixation_pos(4)+150)% broke fixation reset time
                            totalFixTimeout = totalFixTimeout + 0.5;% change 50ms
                            totalFixTime = 0;
                            
                            if totalFixTimeout >= 250
                                nofixtimeflag =1;
                                Novalid=1;
                            end
                            % Mark events, messages, etc. in dataviwer trial
                            WaitSecs(0.001);
                        end
                    end
                end
            end
        end
    end
    
    %this if statement stores and decides on weather or not a trial was
    %speeded or slowed and sets the max reaction time accordingly
    if speed == 1
        
        randSpeedVecData(j) = 1;
        timeToWaitResponse = 2;
        
    elseif speed == 2
        
        randSpeedVecData(j) = 2;
        timeToWaitResponse = 0.8;
    end
    
    %if fixation is heald user starts search here
    if nofixtimeflag==0 && nofixflag == 0
        %%%%the serach screen
        T_delay = timeToWaitResponse; %%take your search time
        nofixtimeflag=1;
        startrt=GetSecs;
        totalFixTime =0;
        totalFixTimeout=0;
        Novalid=0;
        fixTime = T_delay;
        
        %Conditional for easy task choice
        
        %sets up hard trial to be drawn in DrawTLLocation
        easy = false;
        %record data on which option was chosen
        rewardChoice(j,1) = 2;
        %======================================
        %DIFFICULT TASK CODE HERE
        %======================================
        %draw difficult task
        DrawTLLocation;
        %present task screen for 2 seconds
        [~,start1, ~] =  Screen('Flip', window);
        
        if strcmp(elstate, 'on')
            % Mark events, messages, etc. in dataviwer trial
            Eyelink('Message', 'SS8 search array drawn');
            WaitSecs(0.001);
        end
        %"ArrayET" executes and checks fixation while search array is shown
        %and saves button press. it also will terminate if the maximum
        %reatcion time is reached.
        ArrayET;
        
        
        %enters if statement if there was a key press
        if nofixtimeflag == 0
            %set to zero, when "CorrectDecesion" executes there will be
            %a check if there is a button press and if there is, flag
            %will be set to one. if there is not button press, flag
            %will stay zero and the trial will be aborted.
            flag = 0;
            %code housed in script decides weather or not input from
            %user was correct
            CorrectDecision;
            %aborts trial if time has ran out
            if flag == 0
                AbortFree;
            end
            
            %record response data
            correctOrIncorrect(j,1) = response;
            
            % trial is aborted if fixation was broken during the
            % search
        elseif ~isEyeInside || nofixtimeflag==1
            AbortFree;
        end
        clear firstPress;
        
        %enter this else if statement if the initial fixation was broken
    elseif (~isEyeInside || nofixtimeflag==1) && nofixflag == 0
        AbortFree;
    end
    %%% 7. END RECORDING each trial
    Eyelink('StopRecording');
    
    j = j + 1;
end

%only in Practice trials will a confidence rating be taken at the end of
%each block.
if confidence == true
    DrawFormattedText(window, 'What percent do you think you got correct?', responseText,screenYpixels * 0.25, black);
    [~, trial_datum, ~, ~, ~ ,~] = RatingsConfidence('confidence', window,p);
    fatigueRating(length(trialData(:,1)), 1) = trial_datum;
    Screen('DrawTexture', window, dispImageCross, [], centerRect);
    Screen('Flip', window);
    
    if strcmp(elstate, 'on')
        % Mark events, messages, etc. in dataviwer trial
        Eyelink('Message', 'Percent correct rating shown');
        WaitSecs(0.001);
    end
    
    WaitSecs(1);
end

if feedback == true
    feedbackFlag = 2;
elseif feedback == false
    feedbackFlag = 1;
end
partInfo1 = zeros(length(trialData(:,1)),1) + feedbackFlag;
partInfo2 = zeros(length(trialData(:,1)),1) + P_codeUSE;
blockInfo = zeros(length(trialData(:,1)),1) + practiceNum;
trialData(:, 6) = abortedTrials;
trialData(:, 7) = randSpeedVecData;
trialData = horzcat(partInfo1, partInfo2, trialData, blockInfo);


if countFreeBlocks == 1 && confidence == false && P1Practice == true
    finalTrialData.free.results.responseTimeIncentive =respTimeInc;
    finalTrialData.free.results.rewardChoice = rewardChoice;
    finalTrialData.free.results.correctOrIncorrect = correctOrIncorrect;
    finalTrialData.free.results.respTime = respTime;
    finalTrialData.free.results.abortedTrials = abortedTrials;
    finalTrialData.free.results.fatigueRating = fatigueRating;
    finalTrialData.free.results.keyPress = keyPress;
    finalTrialData.free.trialData.allTrialData = trialData;
    save('finalTrialData');
    load('finalTrialData.mat');
elseif countFreeBlocks ~= 1 && confidence == false && P1Practice == true
    finalTrialData.free.results.responseTimeIncentive = vertcat(finalTrialData.free.results.responseTimeIncentive, respTimeInc);
    finalTrialData.free.results.rewardChoice = vertcat(finalTrialData.free.results.rewardChoice, rewardChoice);
    finalTrialData.free.results.correctOrIncorrect = vertcat(finalTrialData.free.results.correctOrIncorrect, correctOrIncorrect);
    finalTrialData.free.results.respTime = vertcat(finalTrialData.free.results.respTime, respTime);
    finalTrialData.free.results.abortedTrials = vertcat(finalTrialData.free.results.abortedTrials, abortedTrials);
    finalTrialData.free.results.fatigueRating = vertcat(finalTrialData.free.results.fatigueRating, fatigueRating);
    finalTrialData.free.results.keyPress = vertcat(finalTrialData.free.results.keyPress, keyPress);
    finalTrialData.free.trialData.allTrialData = vertcat(finalTrialData.free.trialData.allTrialData, trialData);
    save('finalTrialData');
    load('finalTrialData.mat');
elseif countPracticeBlocks == 1 && confidence == true && P1Practice == true
    
    practiceTrialData.free.results.responseTimeIncentive =respTimeInc;
    practiceTrialData.free.results.rewardChoice = rewardChoice;
    practiceTrialData.free.results.correctOrIncorrect = correctOrIncorrect;
    practiceTrialData.free.results.respTime = respTime;
    practiceTrialData.free.results.abortedTrials = abortedTrials;
    practiceTrialData.free.results.fatigueRating = fatigueRating;
    practiceTrialData.free.results.keyPress = keyPress;
    practiceTrialData.free.trialData.allTrialData = trialData;
    save('practiceTrialData');
    load('practiceTrialData.mat');
elseif countPracticeBlocks ~= 1 && confidence == true && P1Practice == true
    practiceTrialData.free.results.responseTimeIncentive = vertcat(practiceTrialData.free.results.responseTimeIncentive, respTimeInc);
    practiceTrialData.free.results.rewardChoice = vertcat(practiceTrialData.free.results.rewardChoice, rewardChoice);
    practiceTrialData.free.results.correctOrIncorrect = vertcat(practiceTrialData.free.results.correctOrIncorrect, correctOrIncorrect);
    practiceTrialData.free.results.respTime = vertcat(practiceTrialData.free.results.respTime, respTime);
    practiceTrialData.free.results.abortedTrials = vertcat(practiceTrialData.free.results.abortedTrials, abortedTrials);
    practiceTrialData.free.results.fatigueRating = vertcat(practiceTrialData.free.results.fatigueRating, fatigueRating);
    practiceTrialData.free.results.keyPress = vertcat(practiceTrialData.free.results.keyPress, keyPress);
    practiceTrialData.free.trialData.allTrialData = vertcat(practiceTrialData.free.trialData.allTrialData, trialData);
    save('practiceTrialData');
    load('practiceTrialData.mat');
end

if P1Practice == true
    countPracticeBlocks = countPracticeBlocks + 1;
end

% finalTrialData.free.results.allTrialsData = horzcat([respTimeInc, rewardChoice, fatigueRating, keyPress, correctOrIncorrect, respTime, abortedTrials]);
% finalTrialData.free.results.dataDescription = {'Column 1 represents the response time for choosing incentive'; 'Column 2 represents the reward choice(difficult = 2, easy = 1)'; 'Columnn 3 represents self assessed fatigue on a scale of 1 to 10';...
%     'Column 4 represents key presses to decide the orientation of t( 1 = up, 0 = down)'; 'Columnn 5 represents weather or not a trial was correct (1 = correct, 0 = incorrect)';...
%     'Column 6 represents the time it took for a person to decide the orientation of T'; 'Column 7 represents the aborted trials (1 = aborted, 0 = succesful)'};
%
% finalTrialData.free.trialData.description = {'Column 1 represents the trial number(1-72 + aborted trials)'; 'Column 2 represents the position of T in the circle (0 is farthest right and increases traveling counterclock wise around the circle)';...
%     'Column 3 represents the orientation of T (1 = upright T, 0 = upsidedown)'; ' Column 4 where the incentive is drawm (1 = drawn on right, 2 = drawn on left)';'Column 5 represents the incentive value shown 1-6 where an incentive value of 1 will be handled as a 2';'Column 6 is where aborted trials are represented (1= aborted, 0 = completed)'};
%
% finalTrialData.free.trialData.data = trialData;

%finalDataFree = [incentiveAmt,trialData(:, 3),trialData(:, 2),correctOrIncorrect,respTime];

%save('V1mollerusBell\finalDataFree.mat','finalData');
%save('V1mollerusBell\finalTrialData.mat','finalTrialData');

% load('finalDataFree.mat');