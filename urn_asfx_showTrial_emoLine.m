function TrialInfo = urn_asfx_showTrial(atrial, windowPtr, Stimuli, Cfg)

% Last modified 16-11-2010 Mateus Joffily

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% Check if there is any sound event to be presented in this trial.
% Only one sound playback is allowed per trial. However, the same sound 
% can beplayed several time during the trial.
if ~isempty(Stimuli.sound)
    % Perform basic initialization of the sound driver
    InitializePsychSound;
    channels = size(Stimuli.sound(1).data, 1);
    pahandle = PsychPortAudio('Open', [], [], 0, ...
        Stimuli.sound(1).fs, channels);
    PsychPortAudio('FillBuffer', pahandle, ...
        Stimuli.sound(1).data);
end

% 6 factors with levels:
% [pWin=3 ambLevel=4 exante=2 outcomeWin=3 colour=2 shiftLR=2]
fac = ASF_decode(atrial.code, [3 4 2 3 2 2]);

% Load auxiliary picture
nTex = 0;
for selected = 0:2   % 0=none, 1=left, 2=right
    for pay = 0:1    % 0=none, 1=highlight pay
        
        if selected == 0 && pay == 1
            continue
        end
        
        if strcmp(Cfg.sessType, 'exp')
            fimg = fullfile('.', 'images', 'exp', ...
                sprintf('%03d_%d_%d.png', atrial.code, selected, pay));
        else
            fimg = fullfile('.', 'images', 'demo', ...
                sprintf('%03d_%d_%d.png', atrial.code, selected, pay));
        end
        
        [imdata, MAP, ALPHA] = imread(fimg);

        %PUT PICTURE ON A TEXTURE
        nTex = nTex + 1;
        stimuliTexAux(nTex)= Screen('MakeTexture', windowPtr, imdata);
    end
end

%--------------------------------------------------------------------------
%TRIAL PRESENTATION HAS SEVERAL PHASES
% 1) WAIT FOR THE RIGHT TIME TO START TRIAL PRESENTATION. THIS MAY BE 
%    IMMEDIATELY OR USER DEFINED (E.G. IN fMRI EXPERIMENTS)
%
% 2) LOOP THROUGH PAGE PRESENTATIONS
%--------------------------------------------------------------------------

%LOG DATE AND TIME OF TRIAL
strDate = datestr(now); %store when trial was presented

%--------------------------------------------------------------------------
% PHASE 1) WAIT FOR THE RIGHT TIME TO START TRIAL PRESENTATION. THIS MAY 
%          BE IMMEDIATELY OR USER DEFINED (E.G. IN fMRI EXPERIMENTS)
%--------------------------------------------------------------------------
%IF EXTERNAL TIMING REQUESTED (e.g. fMRI JITTERING)
if Cfg.useTrialOnsetTimes
    while((GetSecs- Cfg.experimentStart) < atrial.tOnset)
    end
end

if Cfg.Eyetracking.doDriftCorrection
    EyelinkDoDriftCorrect(Cfg.el);
end

%--------------------------------------------------------------------------
%END OF PHASE 1
%--------------------------------------------------------------------------


%LOG TIME OF TRIAL ONSET WITH RESPECT TO START OF THE EXPERIMENT
%USEFUL FOR DATA ANALYSIS IN fMRI
tStart = GetSecs - Cfg.experimentStart;

%MESSAGE TO EYELINK
if Cfg.Eyetracking.useEyelink
    % Check recording status, stop display if error
    Cfg.Eyetracking.err = Eyelink('checkrecording');
    Cfg.Eyetracking.status = Eyelink('message', 'TRIALSTART');
end


%--------------------------------------------------------------------------
% PHASE 2) LOOP THROUGH PAGE PRESENTATIONS
%--------------------------------------------------------------------------
nPages = length(atrial.pageNumber);

% timing: (1) pageDuration; (2) VBLTimestamp; (3) StimulusOnsetTime
%         (4) FlipTimestamp; (5) Missed Beampos
timing      = zeros(nPages, 6);
flipCount   = zeros(1, nPages);   % Number of screen flips during page presentation
Response    = struct('key', [], 'RT', []);
lastTexture = [];   % last shown texture
movie       = struct('start', struct('sec', [], 'frame', []), ...
                     'end',   struct('sec', [], 'frame', []), ...
                     'indexIsFrames', {});

switch Cfg.responseDevice
    case 'MOUSE'
        left_button_index  = 1;
        right_button_index = 3;
        valid_responses = [1 3];
   case 'LUMINA'
        left_button_index  = 1;
        right_button_index = 3;
        valid_responses = [1 3];
    case 'KEYBOARD'
        left_button_index  = 37;    % left arrow
        right_button_index = 39;    % right arrow
        valid_responses = [37 39];
end

%CYCLE THROUGH PAGES FOR THIS TRIAL
for i = 1:nPages

    % Show page
    switch i
        case 1      % fixation
            [timing(i,:) flipCount(i) Response(i)] = show_text(atrial, ...
                windowPtr, Stimuli, Cfg, i, lastTexture);
            
        case 2      % choice
            [timing(i,:) flipCount(i) Response(i) lastTexture] = ...
                show_picture(atrial, windowPtr, stimuliTexAux(1), ...
                Cfg, i, valid_responses);

            if isempty( Response(i).key )
                % Interrupt trial if no response
                break
            end

        case 3      % delay
            if Response(2).key == left_button_index   % Left Selected
                if fac(6) == 0        % switch LR
                    k = 2;
                else
                    k = 4;
                end
            else
                if fac(6) == 0
                    k = 4;
                else
                    k = 2;
                end
            end
            [timing(i,:) flipCount(i) Response(i) lastTexture] = ...
                show_picture(atrial, windowPtr, stimuliTexAux(k), Cfg, i);

        case 4      % outcome
            if Response(2).key == left_button_index   % Left Selected
                if fac(6) == 0        % switch LR
                    k = 3;
                else
                    k = 5;
                end
            else
                if fac(6) == 0
                    k = 5;
                else
                    k = 3;
                end
            end
            [timing(i,:) flipCount(i) Response(i) lastTexture] = ...
                show_picture(atrial, windowPtr, stimuliTexAux(k), Cfg, i);

        case 5     % emotion report
            [timing(i,:) flipCount(i) Response(i) lastTexture] = ...
                show_scale(atrial, windowPtr, Stimuli, Cfg, i, []);

    end

end

%--------------------------------------------------------------------------
%END OF PHASE 2
%--------------------------------------------------------------------------

% Close audio handle
if ~isempty(Stimuli.sound)
    PsychPortAudio('Close', pahandle);
end

% Close auxiliary textures
for nT = 1:nTex
    Screen('Close', stimuliTexAux(nT));
end


%PACK INFORMATION ABOUT THIS TRIAL INTO STRUCTURE TrialInfo (THE RETURN ARGUMENT)
TrialInfo.trial         = atrial;  %store page numbers and durations
TrialInfo.datestr       = strDate;
TrialInfo.tStart        = tStart;
TrialInfo.timing        = timing;
TrialInfo.pageFlipCount = flipCount;
TrialInfo.Response      = Response;
TrialInfo.movie         = movie;

end

function [timing flipCount Response stimuliTex]= show_picture(atrial, windowPtr, stimuliTex, Cfg, i, valid_responses)

if nargin < 6
    valid_responses = [];
end

Screen('DrawTexture', windowPtr, stimuliTex, [], Cfg.Screen.destinationRect);

% [timing flipCount Response] = show_texture(windowPtr, stimuliTex,  ...
%     atrial.pageDuration(i), atrial.pageNumber(i), ...
%     atrial.getResponse(i), Cfg, valid_responses);
[timing flipCount Response] = show_texture(windowPtr, stimuliTex,  ...
    atrial.pageDuration(i), i, ...
    atrial.getResponse(i), Cfg, valid_responses);

end

function [timing flipCount Response texture]= show_scale(atrial, windowPtr, Stimuli, Cfg, i, texture)

stimuliTex = [texture ...
              Stimuli.picture(Stimuli.index(atrial.pageNumber(i))).tex];

if isempty(Cfg.Screen.destinationRect)
    destinationRect = [];
    
else
    scaleW  = Stimuli.picture(Stimuli.index(atrial.pageNumber(i))).size(1);
    scaleH  = Stimuli.picture(Stimuli.index(atrial.pageNumber(i))).size(2);
    screenW = Cfg.Screen.Resolution.width;
    screenH = Cfg.Screen.Resolution.height;
    rectW   = diff(Cfg.Screen.destinationRect([1 3]));
    rectH   = diff(Cfg.Screen.destinationRect([2 4]));
    
    ratioW  = rectW / screenW;
    ratioH  = rectH / screenH;
    ratio   = min([ratioW ratioH]);
    
    w1 = fix(Cfg.Screen.destinationRect(1) + (rectW - ratio*scaleW) / 2);
    w2 = fix(w1 + ratio*scaleW);
    h1 = fix(Cfg.Screen.destinationRect(2) + (rectH - ratio*scaleH) / 2);
    h2 = fix(h1 + ratio*scaleH);
  
    destinationRect = [Cfg.Screen.destinationRect' ...
                       repmat([w1 h1 w2 h2], 2, 1)'];
end

Screen('DrawTextures', windowPtr, stimuliTex, [], destinationRect);

% [timing flipCount Response] = show_scale_texture(windowPtr, stimuliTex,  ...
%     atrial.pageDuration(i), atrial.pageNumber(i), Cfg, Stimuli, destinationRect);
[timing flipCount Response] = show_scale_texture(windowPtr, stimuliTex,  ...
    atrial.pageDuration(i), i, Cfg, Stimuli, destinationRect);

end

function [timing flipCount Response]= show_text(atrial, windowPtr, Stimuli, Cfg, i, texture)

% Index of current text in Stimuli structure array
textIdx = Stimuli.index(atrial.pageNumber(i));

% Current text string
textStr = Stimuli.text(textIdx).str;

% Set text backgorund texture
if isempty(Cfg.text.texture)
    % By default, use screen default background
    textTexture = 0;   
else
    if length(Cfg.text.texture) == 1 && ...
       length(Cfg.text.texture{1}) == 1
        % Use the same user defined texture for every text
        textTexture = Cfg.text.texture{1};
    else
        if length(Cfg.text.texture{Cfg.currentTrialNumber}) == 1
            % Use the same user defined texture for every text in trial
            textTexture = Cfg.text.texture{Cfg.currentTrialNumber};
        else
            % Use specific user defined texture for each text
            textTexture = Cfg.text.texture{Cfg.currentTrialNumber}(i);
        end
    end
end

% Draw text backgorund texture
if textTexture == -1
    if  isempty(texture)
        Screen(windowPtr,'FillRect');
    else
        Screen('DrawTexture', windowPtr, texture, [], ...
                                         Cfg.Screen.destinationRect);
    end
elseif textTexture > 0
    texture = Stimuli.picture(textTexture).tex;
    Screen('DrawTexture', windowPtr, texture, [], Cfg.Screen.destinationRect);

else
    Screen(windowPtr,'FillRect');
    
end

% Draw current text over texture
if ~isempty(Cfg.Screen.destinationRect)
    screenRect = Cfg.Screen.destinationRect;
else
    screenRect = Screen('Rect', windowPtr);
end

ASFX_DrawFormattedText(windowPtr, textStr, 'center', 'center', ...
    [255, 255, 255, 255], [], [], [], [], [], screenRect);

% Flip texture
% [timing flipCount Response] = show_texture(windowPtr, texture, ...
%     atrial.pageDuration(i), atrial.pageNumber(i), ...
%     atrial.getResponse(i), Cfg);
[timing flipCount Response] = show_texture(windowPtr, texture, ...
    atrial.pageDuration(i), i, ...
    atrial.getResponse(i), Cfg);

end

function timing = show_sound(pahandle, pageDuration, Cfg, pageNumber)

StimulusOnsetTime = PsychPortAudio('Start', pahandle, 1, 1, 1);

%SET TRIGGER
ASF_setTrigger(Cfg, pageNumber);
if Cfg.Eyetracking.useEyelink
    % Check recording status, stop display if error
    Cfg.Eyetracking.err = Eyelink('checkrecording');
    Cfg.Eyetracking.status = Eyelink('message', sprintf('PAGE %04d', pageNumber));
end

%LOG WHEN THIS PAGE APPEARED
timing   = zeros(1,6);
timing(1) = pageDuration;
timing(3) = StimulusOnsetTime;

end

function [timing  flipCount texture movie] = show_movie(atrial, windowPtr, Stimuli, Cfg, i)

timing = zeros(1,6);
movie  = struct('start', struct('sec', [], 'frame', []), ...
                'end',   struct('sec', [], 'frame', []), ...
                'indexIsFrames', []);

moviePtr = Stimuli.movie(Stimuli.index(atrial.pageNumber(i))).Ptr;
movieFps = Stimuli.movie(Stimuli.index(atrial.pageNumber(i))).fps;

% Start playback:
Screen('PlayMovie', moviePtr, 1);

% Set current movie frame (frame 0 is the first frame in the movie)
if isempty(Cfg.movie.index)
    % By default, resume movie presentation
    SetMovieTimeIndex = -1;   
else
    if length(Cfg.movie.index) == 1 && ...
       length(Cfg.movie.index{1}) == 1
        % Same user defined timeindex for every page
        SetMovieTimeIndex = Cfg.movie.index{1};
    else
        % Specific user defined timeindex for each page
        SetMovieTimeIndex = Cfg.movie.index{Cfg.currentTrialNumber}(i);
    end
end

% Set movie time index to specified value.
% Otherwise, movie will be presented from time index it stopped before
if SetMovieTimeIndex >= 0
    Screen('SetMovieTimeIndex', moviePtr, SetMovieTimeIndex , ...
        Cfg.movie.indexIsFrames);
end

% Retrieve texture handle to first movie frame
[texture timeindex0] = Screen('GetMovieImage', windowPtr, moviePtr);

% Fill movie timing structure
movie.start.sec   = timeindex0;
movie.start.frame = timeindex0 * movieFps;

% Valid texture returned? A negative value means end of movie reached:
if texture <= 0
    disp('Movie length is shorter than expected!!!!');
    return;    % We're done, break out of loop
end;

%PUT THE APPROPRIATE TEXTURE ON THE BACK BUFFER
Screen('DrawTexture', windowPtr, texture, [], Cfg.Screen.destinationRect);

%FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT IN THE
%BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED AGAIN TO THE SCREEN
[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = ...
    ASFX_xFlip(windowPtr, texture, Cfg, 1);
flipCount = 1;

%LOG WHEN THIS PAGE APPEARED
timing(1:6) = [atrial.pageDuration(1), VBLTimestamp ...
               StimulusOnsetTime FlipTimestamp Missed Beampos];

if Cfg.movie.indexIsFrames
    timeindex0 = floor( timeindex0 * movieFps );
end   
timeindex1 = timeindex0;
while timeindex1 - timeindex0 < atrial.pageDuration(i)
    % CLOSE PREVIOUS TEXTURE
    Screen('Close', texture);
    
    [texture timeindex1] = Screen('GetMovieImage', windowPtr, moviePtr, ...
        1, GetSecs-FlipTimestamp);
    
    % Valid texture returned? A negative value means end of movie reached:
    if texture<= 0
        break;        % We're done, break out of loop
    end;

    %PUT THE APPROPRIATE TEXTURE ON THE BACK BUFFER
    Screen('DrawTexture', windowPtr, texture, [], Cfg.Screen.destinationRect);

    if Cfg.movie.indexIsFrames
        timeindex1 = floor( timeindex1 * movieFps );
    end
    
    %FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND DESTRUCT IT
    ASFX_xFlip(windowPtr, texture, Cfg, 0);
    flipCount = flipCount + 1;
end

% Fill movie timing structure
movie.end.sec   = Screen('GetMovieTimeIndex', moviePtr);
movie.end.frame = movie.end(1).sec * movieFps;

% Stop playback
Screen('PlayMovie', moviePtr, 0);

% Wait before continue...
% WaitSecs(1.5);

end

function [timing flipCount Response] = show_texture(windowPtr, texture, pageDuration, pageNumber, getResponse, Cfg, valid_responses)

% Initialize Response structure array
Response = struct('key', [], 'RT', []);

%PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOW AGAIN AT THE NEXT FLIP
bPreserveBackBuffer = pageDuration > Cfg.Screen.monitorFlipInterval;

%FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT IN THE
%BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED AGAIN TO THE SCREEN
[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = ...
    ASFX_xFlip(windowPtr, texture, Cfg, bPreserveBackBuffer);
flipCount = 1;

%SET TRIGGER
ASF_setTrigger(Cfg, pageNumber);
if Cfg.Eyetracking.useEyelink
    % Check recording status, stop display if error
    Cfg.Eyetracking.err = Eyelink('checkrecording');
    Cfg.Eyetracking.status = Eyelink('message', sprintf('PAGE %04d', pageNumber));
end
ASF_setTrigger(Cfg, 0);  % set trigger output to zero

%LOG WHEN THIS PAGE APPEARED
timing(1, 1:6) = [pageDuration VBLTimestamp StimulusOnsetTime ...
                  FlipTimestamp Missed Beampos];

% Wait out the remainder of the stimulus duration
remaining_time = pageDuration - (GetSecs - StimulusOnsetTime);
nResp = 0;
timeLastResp = 0;  % key press debouncing
if getResponse
    while remaining_time > 0
        [x, y, buttons, t0, t1] = ASF_waitForResponse(Cfg, remaining_time);
        if any(buttons) && (t1 - timeLastResp > 0.05)
            if ~isempty(valid_responses) && ~any(buttons(valid_responses))
                continue
            end
            nResp = nResp + 1;
            % button has been pressed before timeout
            Response.key(nResp) = find(buttons); %find which button it was
            Response.RT(nResp)  = (t1 - StimulusOnsetTime) * 1000; % RT in ms
            if Cfg.responseTerminatesTrial || pageDuration == inf
                break;
            end            
        end
        timeLastResp = t1;  % key press debouncing
        remaining_time = pageDuration - (GetSecs - StimulusOnsetTime);
    end
else
    while remaining_time > 0
        %PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOW AGAIN AT THE NEXT FLIP
        bPreserveBackBuffer = remaining_time > Cfg.Screen.monitorFlipInterval;

        ASFX_xFlip(windowPtr, texture, Cfg, bPreserveBackBuffer);
        flipCount = flipCount + 1;

        remaining_time = pageDuration - (GetSecs - StimulusOnsetTime);
    end
end

end

function [timing flipCount Response] = show_scale_texture(windowPtr, texture, pageDuration, pageNumber, Cfg, Stimuli, destinationRect)

% Initialize Response structure array
Response = struct('key', [], 'RT', []);

%PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOWN AGAIN AT THE NEXT FLIP
bPreserveBackBuffer = pageDuration > Cfg.Screen.monitorFlipInterval;

%FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT IN THE
%BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED AGAIN TO THE SCREEN
[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = ...
    ASFX_xFlip(windowPtr, texture, Cfg, bPreserveBackBuffer);
flipCount = 1;

%SET TRIGGER
ASF_setTrigger(Cfg, pageNumber);
if Cfg.Eyetracking.useEyelink
    % Check recording status, stop display if error
    Cfg.Eyetracking.err = Eyelink('checkrecording');
    Cfg.Eyetracking.status = Eyelink('message', sprintf('PAGE %04d', pageNumber));
end
ASF_setTrigger(Cfg, 0);  % set trigger output to zero

%LOG WHEN THIS PAGE APPEARED
timing(1, 1:6) = [pageDuration VBLTimestamp StimulusOnsetTime ...
                  FlipTimestamp Missed Beampos];

% Wait out the remainder of the stimulus duration
remaining_time = pageDuration - (GetSecs - StimulusOnsetTime);
rating.value = 0;

% Only 'MOUSE' is available for emotion line scale
enter_button_index = 1;

% Compute scale position
if isempty( Cfg.Screen.rect )
    rect = Cfg.Screen.rect;
else
    rect = [1, 1, ...
            Cfg.Screen.Resolution.width - 1, ...
            Cfg.Screen.Resolution.height - 1];
end
yRef = round( ( diff(rect([2 4]))  ) / 2 ) + 12 ;
xRef = round( ( diff(rect([1 3]))  ) / 2 ) + [-253 254];
SetMouse(floor(mean(xRef)), yRef);

% get response
while remaining_time > 0
    
    [x, y, buttons] = GetMouse;
    t1 = GetSecs;
    
    if x < xRef(1)
        x = xRef(1);
        SetMouse(xRef(1), yRef);
    end
    
    if x > xRef(2)
        x = xRef(2);
        SetMouse(xRef(2), yRef);
    end
    
    Screen('DrawTextures', windowPtr, texture, [], destinationRect);
    Screen('DrawLine', windowPtr, [255 0 0], x, yRef-12, x, yRef+12, 3);
    Screen(windowPtr, 'Flip');

    if buttons(enter_button_index)
        Response.key(1) = round( 100 * ( ( x - xRef(1) ) / diff(xRef) ) ...
                          - 50 );
        Response.RT(1)  = (t1 - StimulusOnsetTime) * 1000; % RT in ms
        break;

    end
    
    remaining_time = pageDuration - (GetSecs - StimulusOnsetTime);

end

end