clear all

% Set minimum payoff
minumpayoff = 5;

% Output path
pout = 'C:\Matlab_output\';

%==========================================================================
% DO NOT CHANGE BELOW THIS LINE
%==========================================================================

% Add path to ASFX @ Eye-tracker room
if isempty(strfind(path, 'ASFX'))
    addpath('\\FSC_V5_SERVER\V5\econ\usr\econ-expt-user-1\Documents\Giorgio_URN\mateusjoffily-ASFX-c721c6a');
%     addpath('C:\Documents and Settings\mattarello.PRECISION3100\Desktop\Francesco Zaffuto\Toolboxes\ASFX');
end

% Get subject name
answer = {};
while isempty(answer) || isempty(answer{1}) || isempty(answer{2})
    answer = inputdlg({'FIRST name:' 'LAST name:'}, ...
        'Enter your name', 1, {'' ''});
    if isequal(answer,0)
        % If cancelled, return
        return
    end
end

% Generate ID
answer{1} = [answer{1} 'XXX'];
answer{2} = [answer{2} 'XXX'];
dd = datestr(now, 2);
dd([3 6]) = [];
ftmp = tempname;
subjectID = [upper(answer{1}(1:3)) upper(answer{2}(1:3)) dd '_' ftmp(end-4:end)];

%DEMO
uiwait(warndlg(sprintf('Wait for the experimenter authorization and only after\npress the OK button below to start the training session.'), 'TRAINING'));
payoff = urn_LA_asfx(subjectID, 'EN', 'demo', false, false, pout);

%EXP
uiwait(warndlg(sprintf('Wait for the experimenter authorization and only after\npress the OK button below to start the experiment session.'), 'EXPERIMENT'));
payoff = urn_LA_asfx(subjectID, 'EN', 'exp', false, false, pout);

% Inform payoff
msg = sprintf('Your payoff is US$%0.2f !', minumpayoff + payoff);
fprintf(1, '%s\n', msg);
warndlg(msg, 'Payoff');

