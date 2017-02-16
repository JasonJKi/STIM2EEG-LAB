function ScreenCapture
addpath(genpath('../liblsl-Matlab'))
lib = lsl_loadlib();
disp('Creating markers for new screen capture');
info = lsl_streaminfo(lib,'ScreenCapture','Markers',1,1,'cf_int32','myuniquesourceid23443');
outlet = lsl_outlet(info);
esc=KbName('ESCAPE');
f9 = KbName('F9');
input('link screen capture trigger with lsl host machine. press enter to continue')

f9Trigger=1;

while 1
    [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
    if (keyIsDown==1 && keyCode(f9))
        outlet.push_sample(f9Trigger);
    else
         outlet.push_sample(0)
    end;
    
    if (keyIsDown==1 && keyCode(esc))
        break
    end
end

end