function urn_board(probRedL, ambLeveRedL, exanteRedL, probRedR, ambLeveRedR, exanteRedR, outcomeRedL, outcomeBlueL, outcomeRedR, outcomeBlueR)

%we are setting a function called "board" which allows us to introduce...
% the values of risk, ambiguity and exante in the two possible choices.

h = figure('color', 'k', 'position', [257 292 674 480],...
        'inverthardcopy', 'off');
   
% option one

subplot(1,2,1)
urn_create(probRedL, ambLeveRedL, exanteRedL, outcomeRedL, outcomeBlueL);

%option two

subplot(1,2,2)
urn_create(probRedR, ambLeveRedR, exanteRedR, outcomeRedR, outcomeBlueR);

% close(h)
