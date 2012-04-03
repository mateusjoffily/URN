function urn_read_table(ftxt)

%we make now a function which takes the input from a txt file

if nargin == 0
    ftxt = 'urn_trials_exp.txt';
end 

% Images output folder
pimg = '.\images\exp';

[probRedL, ambLevelL, exanteL, probRedR, ambLevelR, exanteR, ...
 outcomeRedL, outcomeBlueL, outcomeRedR, outcomeBlueR, ...
 payL, payR, shiftLR, code] = textread(ftxt, ...
    '%f %f %d %f %f %d %d %d %d %d %d %d %d %d', 'headerlines', 1);

%nargin is a command that controls if any input has been put in our
%fuction.
% if nargin is equal to zere the values will be attributed to the
% variables

nTrials = length(probRedL);
% we want now to print the all urns, we use for that a for loop
for nT = 1:nTrials
    for selected = 0:2   % 0=none, 1=left, 2=right
        for pay = 0:1    % 0=none, 1=highlight pay
            
            if selected == 0 && pay == 1
                continue
            end
            
            % Create struct of urn parameters
            urn_params.code    = code(nT);
            urn_params.shiftLR = shiftLR(nT);
            
            urn_params.L.probRed     = probRedL(nT);
            urn_params.L.ambLevel    = ambLevelL(nT);
            urn_params.L.exante      = exanteL(nT);
            urn_params.L.outcomeRed  = outcomeRedL(nT);
            urn_params.L.outcomeBlue = outcomeBlueL(nT);
            
            urn_params.R.probRed     = probRedR(nT);
            urn_params.R.ambLevel    = ambLevelR(nT);
            urn_params.R.exante      = exanteR(nT);
            urn_params.R.outcomeRed  = outcomeRedR(nT);
            urn_params.R.outcomeBlue = outcomeBlueR(nT);
           
            switch selected
                case 0
                    urn_params.L.selected = false;
                    urn_params.R.selected = false;
                case 1
                    urn_params.L.selected = true;
                    urn_params.R.selected = false;
                case 2
                    urn_params.L.selected = false;
                    urn_params.R.selected = true;
            end
            
            switch pay
                case 0
                    urn_params.L.pay = [];
                    urn_params.R.pay = [];
                case 1
                    urn_params.L.pay = payL(nT);
                    urn_params.R.pay = payR(nT);
            end
            
            % create urns
            urn_board( urn_params );

            % save urns figure
            fimg = fullfile(pimg, sprintf('%03d_%d_%d', ...
                urn_params.code, selected, pay));
            print(gcf, '-dpng', '-r100', fimg);
            close(gcf);
            
        end
    end
end

disp([ftxt ' read and images created.']);
