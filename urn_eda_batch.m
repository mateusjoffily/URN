% Example script for processing and analyising Electrodemal Activity (EDA)

% convert BrainAmp VHDR to matlab formatdata
[data fs event fmat saveOK] = vhdr2mat([], [], [], 1, false);
if ~saveOK
    error('script interrupted!')
end

nChan = 1;                % select EDA channel
eda = data(nChan,:);      % EDA signal to be processed

% Filter EDA signal (default: low-pass filter @ 1Hz) (see 'help eda_filt')
%--------------------------------------------------------------------------
[eda filt] = eda_filt(eda, fs, 'default');

% Detect Electrodermal Responses (EDR). (see 'help eda_edr')
%--------------------------------------------------------------------------
edr = eda_edr(eda, fs);

% Create conditions file (see 'help eda_conditions')
%--------------------------------------------------------------------------
% % remove false trigger 3
% n = 1;
% while true
%     i = find(event(2).onsets(n) > event(3).onsets(n:end));
%     if ~isempty(i)
%         event(3).onsets(n+i-1) = [];
%     end
%     n = n + 1;
%     if n > numel(event(2).onsets)
%         break
%     end
% end
% create markers
names{1}     = 'choice';
onsets{1}    = event(2).onsets;
durations{1} = event(3).onsets - event(2).onsets + 1;
names{2}     = 'outcome';
onsets{2}    = event(4).onsets;
durations{2} = 0;

save(fmat, 'names', 'onsets', 'durations', '-APPEND');
conds = eda_conditions(eda, fs, fmat, edr);

% Save results to mat file
%--------------------------------------------------------------------------
save(fmat, 'filt', 'edr', 'conds', '-APPEND');

% Review EDR/EDL/Conditions and remove artifacts (GUI). (see 'help eda_gui')
%--------------------------------------------------------------------------
uiwait( eda_gui(eda, fs, edr, fmat) );

% Save results (EDR and EDL) grouped by conditions in TEXT file (see
% 'eda_save_text')
%--------------------------------------------------------------------------
load(fmat);
[fpath,fname] = fileparts(fmat);
ftxt = fullfile(fpath, [fname(1:end-4) '_gsr_res.txt']);
eda_save_text(eda, fs, edr, conds, ftxt);
