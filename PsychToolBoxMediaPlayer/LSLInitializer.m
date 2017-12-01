% Initialize with unified keynames and normalized colorspace:
disp('Loading library...');
addpath(genpath('../liblsl-Matlab'))
lib = lsl_loadlib();

disp('Creating a new streaminfo...');
% info1 = lsl_streaminfo(lib,'StimulusPlayer-Trigger','Trigger',1,100,'cf_int32','StimulusPlayerNewton');
% outlet1 = lsl_outlet(info1);


info = lsl_streaminfo(lib,'StimulusPlayer-Markers','Markers',1,1,'cf_float32','sdfwerr32432');
outlet = lsl_outlet(info);
input('link stimulus player with lsl host machine. press enter to continue')