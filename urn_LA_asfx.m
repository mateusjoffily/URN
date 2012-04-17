function payoff = urn_LA_asfx(subjectID, language, sessType, debug_mode, send_triggers, pout)

%==========================================================================
% DO NOT CHANGE BELOW THIS LINE
%==========================================================================

% Emotion scale 
emoScaleFaces = false;

% Load standard configuration
%--------------------------------------------------------------------------
% Useful tips: CTRL-C - stop ASFX execution
%              sca    - clear screen and return to Win
Cfg = ASFX_setCfg([], 'lab', debug_mode);  

% ASF Send triggers to output device
if ~send_triggers
    Cfg.issueTriggers = 0;  
end

% ASF ShowTrial function
if emoScaleFaces
    Cfg.userSuppliedTrialFunction = @urn_asfx_showTrial_emoFaces;
    Cfg.responseDevice = 'KEYBOARD';
else
    Cfg.userSuppliedTrialFunction = @urn_asfx_showTrial_emoLine;
    Cfg.responseDevice = 'MOUSE';
end

% push button terminates "choice" period
Cfg.responseTerminatesTrial = true;

% Pleasure scale index in STD file
Cfg.RatingScales = 2;

% Inform if session is demo or experiment
Cfg.sessType = sessType;

% Output and TRD file
%--------------------------------------------------------------------------
fout = []; ftrd = [];
if strcmp(sessType, 'exp')
    fout = fullfile(pout, sprintf('%s_exp', subjectID));
    ftrd = 'urn_asf_exp.trd';
    
elseif strcmp(sessType, 'demo')
    fout = fullfile(pout, sprintf('%s_demo', subjectID));
    ftrd = 'urn_asf_demo.trd';
    
else
    fprintf(1, 'unknown session type: %s', sessType);
    
end

% STD file
fstd = sprintf('urn_asf_%s.std', language);

% Launch ASF
%--------------------------------------------------------------------------
expinfo = ASFX(...
    fstd, ...    % stimulus definition file
    ftrd, ...    % trial definitions file
    [fout '.mat'], ...    % output file
    Cfg);        % configuration structure

% Create results table
%--------------------------------------------------------------------------
payoff = urn_asfx_create_results_table(fout, sessType);

end
