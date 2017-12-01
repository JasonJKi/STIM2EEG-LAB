%EYELINK SETUP AND CALIBRATION 
clear all
% select eye link
window = Screen('OpenWindow', 2,12); %Open screen. Set the display screen

% select demo
el = EyelinkInitDefaults(window); % find Eye linkdefault paramters for gui display and control.

% make sure that we get gaze data from the Eyelink
WaitSecs(0.1);
if EyelinkInit()~= 1; %
    return;
end; % connect display and the host computer
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,INPUT'); % make sure that we get gaze data from the Eyelink

WaitSecs(0.1);
% calibrate:

result1 = EyelinkDoTrackerSetup(el); % Instructions come up on the screen. It seems Esc has to be pressed on the stim computer to exit at the end
disp('bop')
result2 = EyelinkDoDriftCorrect(el);

if result2 == 0 || result2 == 27
    Screen('closeAll')
end






