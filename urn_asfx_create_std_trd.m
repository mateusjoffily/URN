function urn_asfx_create_std_trd(sessType, emoLang, emoFacesLoad)
% Creates the Stimulus Definition File (STD) and the Trial Definition file
% (TRD)

if nargin < 1 || isempty( sessType )
    sessType = 'exp';  % 'demo' or 'exp'
end

if nargin < 2 || isempty( emoLang )
    % Language of the scales: 'IT' or 'EN'
    emoLang = 'IT';
end

if nargin < 3 || isempty( emoFacesLoad )
    % Load emotion faces scale?
    emoFacesLoad = false;
end

% Load trials' parameters
ftxt = sprintf('urn_trials_%s.txt', sessType);
[probRedL, ambLeveRedL, exanteRedL, ...
 probRedR, ambLeveRedR, exanteRedR, ...
 outcomeRedL, outcomeBlueL, outcomeRedR, outcomeBlueR, ...
 outcomeL, outcomeR, shiftLR, code] = textread(ftxt, ...
    '%f %f %d %f %f %d %d %d %d %d %d %d %d %d', 'headerlines', 1);

Ntrials = length(probRedL);

% Create ASF Stimulus Definition file (.std)
fstd = sprintf('urn_asf_%s.std', emoLang);
fid = fopen(fstd, 'w');   % open STD file
fprintf(fid, '"+"\n');
if emoFacesLoad
    emoScaleName = sprintf('EmotionScaleFaces_%s.png', emoLang);
    fprintf(fid, '%s\n', fullfile('.', 'images', emoScaleName));
    for n = 0:9
        fscale = sprintf('EmotionScaleFaces_%d_%s.png', n, emoLang);
        fprintf(fid, '%s\n', fullfile('.', 'images', fscale));
    end
else
    emoScaleName = sprintf('EmotionScaleLine_%s.png', emoLang);
    fprintf(fid, '%s\n', fullfile('.', 'images', emoScaleName));
end
fclose(fid);   % close STD file

% 6 factors with levels: [pWin=3 ambLevel=4 exante=2 outcomeWin=3 ...
%                         colour=2 shiftLR=2]
fac = [3 4 2 3 2 2];
fac_names  = {'pWin' 'ambLevel' 'exante' 'outcomeWin' 'colour' 'shiftLR'};

% Create ASF Trial Definition file (.trd)
ftrd = sprintf('urn_asf_%s.trd', sessType);
fid = fopen(ftrd, 'w');    % open TRD file
fprintf(fid, '%d ', fac); % write factors' levels 
fprintf(fid, '%s ', fac_names{:}); % write factors' names 
fprintf(fid, '\n');  
for iT = 1:Ntrials
    fprintf(fid, '%d 0 ', code(iT));
    % "fixation" with 1-2s duration and no response button
    fprintf(fid, '1 %0.2f 0 0 ', 1 + rand(1) );
    % "choice" (free time, but max 60s) and response button
    fprintf(fid, '1 60 1 0 ');
    % "delay" with 6-8s duration and no response button
    fprintf(fid, '1 %0.2f 0 0 ', 6 + 2*rand(1));
    % "outcome" with 6s duration and no response button
    fprintf(fid, '1 6 0 0 ');
    % "emotion scale" (free time, but max 60s) and response button
    fprintf(fid, '2 60 1 0\n');
end

fclose(fid);    % close TRD file

