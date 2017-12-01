%% instantiate the library
disp('Loading library...');
lib = lsl_loadlib();

% make a new stream outlet
disp('Creating a new streaminfo...');
info = lsl_streaminfo(lib,'Newton','Trigger',1,100,'cf_float32','sdfwerr32432');

disp('Opening an outlet...');
outlet = lsl_outlet(info);

% send data into the outlet, sample by sample
disp('Now transmitting data...');

keyPressed = 0; % set this to zero until we receive a sensible keypress
while true  % hang the system until a response is given
    [ keyIsDown, seconds, keyCode ] = KbCheck; % check for keypress
    code = find(keyCode)
    disp([code keyIsDown])
    if code == 120
       outlet.push_sample(1);
       keyPressed = keyPressed +1;
       code
    elseif code == 120 || keyPressed > 5
         outlet.push_sample(0);
    end
    pause(0.1);
end
outlet.push_sample(0);

% 
% while true
%     outlet.push_sample(randn(8,1));
%     pause(0.01);
% end