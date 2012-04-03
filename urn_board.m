function h = urn_board( urn_params)

%we are setting a function called "board" which allows us to introduce...
% the values of risk, ambiguity and exante in the two possible choices.

h = figure('color', 'k', 'position', [40 40 512 384],...
           'inverthardcopy', 'off', 'Units', 'pixels');

pL = [0.15 0.2 0.3 0.6];
pR = [0.55 0.2 0.3 0.6];

% remove exante ambiguity when pay
if ~isempty( urn_params.L.pay ) || ~isempty( urn_params.R.pay )
    if urn_params.L.exante
        urn_params.L.ambLevel = 0;
        urn_params.L.exante = 0;
    end
    if urn_params.R.exante
        urn_params.R.ambLevel = 0;
        urn_params.R.exante = 0;
    end
end

% option one
if urn_params.shiftLR == 1
    axes('position', pL)
    urn_urn( urn_params.L );
    
    axes('position', pR)
    urn_urn( urn_params.R );
    
else
    axes('position', pR)
    urn_urn( urn_params.L );
    
    axes('position', pL)
    urn_urn( urn_params.R );
end
