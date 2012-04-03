function urn_asfx_create_results_table(fout, sessType)

if nargin == 0 || isempty(fout)
    % Select asfx output mat file
    [fname, pname] = uigetfile('*.mat', 'Select MAT-file');
    [p, fname] = fileparts(fname);
    fout = fullfile(pname, fname);
end

if nargin < 2 || isempty(sessType)
    % Read exp table by default
    sessType = questdlg('What session is it?', 'Session type', ...
                      'demo', 'exp', 'exp');
end

% Load experiment results
load([fout '.mat'], 'ExpInfo');

% Load experiment parameters
if strcmp(sessType, 'exp')
    ftxt = 'urn_trials_exp.txt';
    
elseif strcmp(sessType, 'demo')
    ftxt = 'urn_trials_demo.txt';
    
else
    fprintf(1, 'unknown session type: %s', sessType);
    return

end

[probRedL, ambLevelL, exanteL, probRedR, ambLevelR, exanteR, ...
 outcomeRedL, outcomeBlueL, outcomeRedR, outcomeBlueR, ...
 payL, payR, shiftLR, code] = textread(ftxt, ...
    '%f %f %d %f %f %d %d %d %d %d %d %d %d %d', 'headerlines', 1);

% Total number of trials
nTrials = numel(ExpInfo.TrialInfo);

% Check consistency between parameters and output file
if nTrials ~= numel(probRedL)
    fprintf('Warning: parameters and output files have different number of trials.\n');
end

% Random selection of one trial for subject payoff
rand('twister',sum(100*clock));
iTrial = ceil(rand(1)*nTrials);
selected_payoff = zeros(1,nTrials);
selected_payoff(iTrial) = 1;

% open output file
fid = fopen([fout '.txt'], 'w');

% Write table header
fprintf(fid, 'probRedHighRisk\t ambLevelHighRisk\t exanteHighRisk\t ');
fprintf(fid, 'probRedBasicRisk\t ambLevelBasicRisk\t exanteBasicRisk\t ');
fprintf(fid, 'outcomeRedHighRisk\t outcomeBlueHighRisk\t ');
fprintf(fid, 'outcomeRedBasicRisk\t outcomeBlueBasicRisk\t ');
fprintf(fid, 'payRedBlueHighRisk\t payRedBlueBasicRisk\t ');
fprintf(fid, 'shiftLR\t trialCode\t ');
fprintf(fid, 'choiceKey\t choiceRT\t ');
fprintf(fid, 'emotionKey\t emotionRT\t ');
fprintf(fid, 'outcomeChoice\t outcomeAlternative\t payoff\n');

for n = 1:nTrials
    fprintf(fid, '%0.2f\t %0.2f\t %d\t ', ...
                  probRedL(n), ambLevelL(n), exanteL(n));
    fprintf(fid, '%0.2f\t %0.2f\t %d\t ', ...
                  probRedR(n), ambLevelR(n), exanteR(n));
    fprintf(fid, '%d\t %d\t %d\t %d\t ', ...
            outcomeRedL(n), outcomeBlueL(n), outcomeRedR(n), outcomeBlueR(n));
    fprintf(fid, '%d\t %d\t %d\t %d\t ', ...
            payL(n), payR(n), shiftLR(n), code(n));
    
    % choice key and RT (msec)
    if length(ExpInfo.TrialInfo(n).Response) >= 2 && ...
        ~isempty( ExpInfo.TrialInfo(n).Response(2).key )
        keyChoice = ExpInfo.TrialInfo(n).Response(2).key;
        RTChoice  = ExpInfo.TrialInfo(n).Response(2).RT;
    else
        keyChoice = NaN;
        RTChoice  = NaN;
    end
    fprintf(fid, '%d\t %0.2f\t ', keyChoice, RTChoice);
    
    % emotion key and RT (msec)
    if length(ExpInfo.TrialInfo(n).Response) >= 5 && ...
       ~isempty( ExpInfo.TrialInfo(n).Response(5).key )
        keyEmo = ExpInfo.TrialInfo(n).Response(5).key;
        RTEmo  = ExpInfo.TrialInfo(n).Response(5).RT;
    else
        keyEmo = NaN;
        RTEmo  = NaN;
    end
    fprintf(fid, '%d\t %0.2f\t', keyEmo, RTEmo);
    
    % Compute outcome at trial
    outcome_ALL = [outcomeRedL(n)  outcomeRedR(n);
                   outcomeBlueL(n) outcomeBlueR(n)];
    if shiftLR(n) == 1
        outcome_LR = [outcome_ALL(payL(n),1) outcome_ALL(payR(n),2)];
    else
        outcome_LR = [outcome_ALL(payR(n),2) outcome_ALL(payL(n),1)];
    end
    if keyChoice == 37 || keyChoice == 1
        outcomeChoice      = outcome_LR(1);
        outcomeAlternative = outcome_LR(2);
    elseif keyChoice == 39 || keyChoice == 3
        outcomeChoice      = outcome_LR(2);
        outcomeAlternative = outcome_LR(1);
    else
        outcomeChoice      = NaN;
        outcomeAlternative = NaN;
    end
    fprintf(fid, '%d\t %d\t', outcomeChoice, outcomeAlternative);
    
    % Selected payoff
    fprintf(fid, '%d\n', selected_payoff(n));
    
end    

% close output file
fclose(fid);

fprintf(1, 'Results table created.\n');

end

