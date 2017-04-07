function StimulusPlayer(moviename, backgroundMaskOut, tolerance, pixelFormat, maxThreads)
% PlayMoviesDemo(moviename [, backgroundMaskOut][, tolerance][, pixelFormat=4][, maxThreads=-1])
%
% This demo accepts a pattern for a valid moviename, e.g.,
% moviename=`*.mpg`, then it plays all movies in the current working
% directory whose names match the provided pattern, e.g., the `*.mpg`
% pattern would play all MPEG files in the current directory.
%
% If you don't specify a moviename, the demo will ask you if it should play
% our standard DualDiscs.mov demo movie, or rather play through a set of
% videos in a playlist which are streamed from the internet. These 'c'ool
% videos may provide you with useful information for your daily work.
%
% This demo uses automatic asynchronous playback for synchronized playback
% of video and sound. Each movie plays until end, then rewinds and plays
% again from the start. Pressing the Cursor-Up/Down key pauses/unpauses the
% movie and increases/decreases playback rate.
% The left- right arrow keys jump in 1 seconds steps. SPACE jumps to the
% next movie in the list. ESC ends the demo.
%
% If the optional RGB color vector backgroundMaskOut is provided, then
% color pixels in the video which are equal or close to backgroundMaskOut will be
% discarded during drawing. E.g., backgroundMaskOut = [255 255 255] would
% discard all white pixels, backgroundMaskOut = [0 0 0] would discard all
% black pixels etc. The optional tolerance parameter allows for some
% lenience, e.g., tolerance = 10 would discard all pixels whose euclidean
% distance in RGB color space is less than 10 units to the backgroundMaskOut
% color. Background color masking requires a graphics card with fragment
% shader support and will fail otherwise.
%
% If the optional `pixelFormat` is specified, it is used to choose
% optimized video playback methods for specific content. Valid values are 1
% or 2 for greyscale video playback, and 7 or 8 for optimized grayscale
% video playback on modern GPU's with GLSL shading support. Values 3, 4, 5
% and 6 play back color video. 4 is the default, 5 or 6 may provide
% significantly improved playback performance on modern GPUs.
%
% If the optional `maxThreads` is specified, it defines the maximum number
% of parallel processing threads that should be used by multi-threaded
% video codecs for playback. A setting of n selects n threads, a setting of
% zero asks to auto-select an optimum number of threads for a given
% computer. By default, a codec specific default number is used, typically
% one thread.

% Initialize with unified keynames and normalized colorspace:
disp('Loading library...');
addpath(genpath('../liblsl-Matlab'))
lib = lsl_loadlib();

addpath(genpath('../'))

disp('Creating a new streaminfo...');

info = lsl_streaminfo(lib,'StimulusPlayer-Markers','Markers',1,1,'cf_float32','sdfwerr32432');
outlet = lsl_outlet(info);
input('link stimulus player with lsl host machine. press enter to continue')

PsychDefaultSetup(2);

% Setup key mapping:
space=KbName('SPACE');
esc=KbName('ESCAPE');
right=KbName('RightArrow');
left=KbName('LeftArrow');
up=KbName('UpArrow');
down=KbName('DownArrow');
shift=KbName('RightShift');

try
    % Open onscreen window with gray background:
    screen = 0;
    win = PsychImaging('OpenWindow', screen, [0, 0, 0]);
%    screen = 0;
%     win = Screen('OpenWindow', screen, 1);
    shader = [];
    if (nargin > 1) && ~isempty(backgroundMaskOut)
        if nargin < 3
            tolerance = [];
        end
        shader = CreateSinglePassImageProcessingShader(win, 'BackgroundMaskOut', backgroundMaskOut, tolerance);
    end
    
    % Use default pixelFormat if none specified:
    if nargin < 4
        pixelFormat = [];
    end
    
    % Use default maxThreads if none specified:
    if nargin < 5
        maxThreads = [];
    end
    
    % Initial display and sync to timestamp:
    Screen('Flip',win);
    iteration = 0;
    abortit = 0;
    
    % Use blocking wait for new frames by default:
    blocking = 1;
    
    % Default preload setting:
    preloadsecs = [];
  
    
    % Playbackrate defaults to 1:
    rate=1;
    
    % Choose 16 pixel text size:
    Screen('TextSize', win, 16);
    Screen('Preference', 'TextAlphaBlending', 1)
   
    pause
    
    % Endless loop, runs until ESC key pressed:
    while (abortit<2)
       
        iteration = iteration + 1;
        fprintf('ITER=%i::', iteration);
        
        % Show title while movie is loading/prerolling:
        disp(['displaying movie name ' moviename])

        DrawFormattedText(win, ['Loading ...\n' moviename], 'center', 'center', 0, 40);
        Screen('Flip', win);
        
        % Open movie file and retrieve basic info about movie:
        [movie movieduration fps imgw imgh count] = Screen('OpenMovie', win, moviename, [], preloadsecs, [], pixelFormat, maxThreads);
        fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', moviename, movieduration, fps, imgw, imgh);
        
        i=1;
        
        % Start playback of movie. This will start
        % the realtime playback clock and playback of audio tracks, if any.
        % Play 'movie', at a playbackrate = 1, with endless loop=1 and
        % 1.0 == 100% audio volume.
        Screen('PlayMovie', movie, rate, 0,1.0);
        ShowCursor
        t1 = GetSecs;
        
        % Infinite playback loop: Fetch video frames and display them...
        while 1
            [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
            if (keyIsDown==1 && keyCode(esc))
                % Set the abort-demo flag.
                abortit=2;
                break;
            end;
            
            % Check for skip to next movie:
            if (keyIsDown==1 && keyCode(space))
                % Exit while-loop: This will load the next movie...
                break;
            end;
            
            % Only perform video image fetch/drawing if playback is active
            % and the movie actually has a video track (imgw and imgh > 0):
            if ((abs(rate)>0) && (imgw>0) && (imgh>0))
                % Return next frame in movie, in sync with current playback
                % time and sound.
                % tex is either the positive texture handle or zero if no
                % new frame is ready yet in non-blocking mode (blocking == 0).
                % It is -1 if something went wrong and playback needs to be stopped:
                [tex, timeindex] = Screen('GetMovieImage', win, movie, blocking);
                
                % Valid texture returned?
                if tex < 0
                    % No, and there won't be any in the future, due to some
                    % error. Abort playback loop:
                    abortit=2;
                    break;
                end
                
                if tex == 0
                    % No new frame in polling wait (blocking == 0). Just sleep
                    % a bit and then retry.
                    WaitSecs('YieldSecs', 0.005);
                    continue;
                end
                
                % Draw the new texture immediately to screen:
                Screen('DrawTexture', win, tex, [], [], [], [], [], [], shader);
                [VBLTimestamp, StimulusOnsetTime, FlipTimestamp]= Screen('Flip', win);
                
                if ~mod(i,fps)
                    outlet.push_sample(2);
                else
                    outlet.push_sample(0);
                end
 
%                 DrawFormattedText(win, ['time: ' num2str(timeindex) '/' num2str(movieduration) 's'], 'center', 20, [1 1 1]);
%                 DrawFormattedText(win, ['flip duration: ' num2str(VBLTimestamp - FlipTimestamp) 's'], 'right', 20, [1 1 1]);
%                 DrawFormattedText(win, ['on set time: ' num2str(StimulusOnsetTime)], 'right', 30, [1 1 1]);
%                 DrawFormattedText(win, ['VBL time stamp: ' num2str(VBLTimestamp)], 'right', 40, [1 1 1]);
%                 DrawFormattedText(win, ['Flip time stamp: ' num2str(FlipTimestamp)], 'right', 50, [1 1 1]);
 
%                 DrawFormattedText(win, ['frame: ' num2str(i)], 'left', 20, [1 1 1]);

                % Update display:
%                 disp(['VBL Time stamp: ' num2str(VBLTimestamp)]);
%                 disp(['Stimulus On set Time: ' num2str(StimulusOnsetTime)]);
%                 disp(['Flip Time stamp: ' num2str(FlipTimestamp)]);
%                 disp(['actual movie time: ' num2str(Screen('GetMovieTimeIndex', movie))])
                % Release texture:
                Screen('Close', tex);
                
                if (movieduration==timeindex)
                    % Set the abort-demo flag.
                    abortit=2;
                    break;
                end;
                
                % Framecounter:
%                 outlet.push_sample(VBLTimestamp);
%                 outlet.push_sample(i);
                
             
                %outlet.push_sample(VBLTimestamp);
                i=i+1;
            end;
            outlet.push_sample(10);
            % Further keyboard checks...
            
            if (keyIsDown==1 && keyCode(right))
                % Advance movietime by one second:
                Screen('SetMovieTimeIndex', movie, Screen('GetMovieTimeIndex', movie) + 1);
            end;
            
            if (keyIsDown==1 && keyCode(left))
                % Rewind movietime by one second:
                Screen('SetMovieTimeIndex', movie, Screen('GetMovieTimeIndex', movie) - 1);
            end;
            
            if (keyIsDown==1 && keyCode(up))
                % Increase playback rate by 1 unit.
                if (keyCode(shift))
                    rate=rate+0.1;
                else
                    KbReleaseWait;
                    rate=round(rate+1);
                end;
                Screen('PlayMovie', movie, rate, 1, 1.0);
            end;
            
            if (keyIsDown==1 && keyCode(down))
                % Decrease playback rate by 1 unit.
                if (keyCode(shift))
                    rate=rate-0.1;
                else
                    while KbCheck; WaitSecs(0.01); end;
                    rate=round(rate-1);
                end;
                Screen('PlayMovie', movie, rate, 1, 1.0);
            end;
        end;
        
        telapsed = GetSecs - t1;
        fprintf('Elapsed time %f seconds, for %i frames.\n', telapsed, i);
        
        Screen('Flip', win);
        KbReleaseWait;
        
        % Done. Stop playback:
        Screen('PlayMovie', movie, 0);
        
        % Close movie object:
        Screen('CloseMovie', movie);
    end;
    
    % Close screens.
    sca;
    
    % Done.
    return;
catch E%#ok<*CTCH>
    % Error handling: Close all windows and movies, release all ressources.
    sca;
    errordlg(E.message)

end
