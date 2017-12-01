%initialize eyelink
if EyelinkInit()~= 1; %
    return;
end;

%Get screen specification
whichScreen =1
[scresw, scresh]=Screen('WindowSize',whichScreen);  % Get screen resolution
center = [scresw scresh]/2

%File save pathq
subjnum = input('Enter experiment and Subject # ','s')
name = input('Enter Subject name ', 's')
filename = [ subjnum '_' name ]

%Start Recording
Eyelink('OpenFile', name)
Eyelink('StartRecording'); %Start the recording

WaitSecs(0.1);
Eyelink('Message', 'SYNCTIME');
eye_used = Eyelink('EyeAvailable');
% event = Eyelink( 'NwestFloatSample');

while  1
    
    % Stop Loop if....
    error=Eyelink('CheckRecording');
    if(error~=0)
        %INSERT WARNING SOUND
        beep on
        break;
    end
    
    % Or PRESS q to quit recording.
    [keyIsDown,secs,keyCode] = KbCheck;
    a = find(keyCode);
    
    
    if a == 81; % press q to quit recording
        
        break
    end
    
end


Eyelink('StopRecording');
Eyelink('CloseFile');
status =  Eyelink('receivefile');
status = 0
