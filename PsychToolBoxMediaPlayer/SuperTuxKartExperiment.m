stkExecutablePath = 'C:\Users\Jason\STIM2EEGLAB\Supertuxkart\SuperTuxKart-Neuromatter\stk-code\build\bin\Release\'
cd(stkExecutablePath)
command = 'supertuxkart.exe'

runtime = java.lang.Runtime.getRuntime();
process = runtime.exec(command);

ScreenCapture
