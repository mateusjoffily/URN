function urn_read_table(ftxt)

%we make now a function which takes the input from a txt file

if nargin == 0
    ftxt = 'urn_trials.txt';
end 

[probRedL, ambLeveRedL, exanteRedL, ...
 probRedR, ambLeveRedR, exanteRedR, ...
 outcomeRedL, outcomeBlueL, outcomeRedR, outcomeBlueR] = textread(ftxt);

%nargin is a command that controls if any input has been put in our
%fuction.
% if nargin is equal to zere the values will be attributed to the
% variables

ntrials = length(probRedL);

% we want now to print the all urns, we use for that a for loop
for n = 1:ntrials
    urn_board( probRedL(n), ambLeveRedL(n), exanteRedL(n), ...
               probRedR(n), ambLeveRedR(n), exanteRedR(n), ...
               outcomeRedL(n), outcomeBlueL(n), ...
               outcomeRedR(n), outcomeBlueR(n));
            
    fimg = fullfile('.', 'images', sprintf('%03d', n));
    print(gcf, '-dbitmap', fimg);
end

disp([ftxt ' read and images created.']);
