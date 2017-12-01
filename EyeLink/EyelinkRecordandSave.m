function repeat = EyelinkRecordandSave(filename,directory)
if EyelinkInit()~= 1; %
    return;
end; % connect d  10isplay and the host computer

currentDir=pwd;
i = 1;
%Start Recording
Eyelink('OpenFile', filename)
Eyelink('StartRecording'); %Start the recording

WaitSecs(0.5);
Eyelink('Message', 'SYNCTIME');
eye_used = Eyelink('EyeAvailable');
% event = Eyelink( 'NwestFloatSample');

while  1
    error=Eyelink('CheckRecording');
    if(error~=0)
        %INSERT WARNING SOUND
        beep on
        break;
    end
    
    [keyIsDown,secs,keyCode] = KbCheck;
    a = find(keyCode);
    if or(a == 81,a == 68) % q == quit and d= driftcorrection
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            cd(directory);
            Eyelink('receivefile');
            cd(currentDir);
    end
    
end


