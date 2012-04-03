function urn_urn( urn_params )
% urn_params is a struct with following fields:
% probRed= probability Red level: 0.13, 0.25, 0.38...
% amblevel=ambiguity level: 0, 0.25, 0.50, 0.75...
% exante= true or false
% color = this command indicates the winning color 1=red 0=blue

wRect = 0.5;
% the width of the rectangle is 0.5;

hRed = rectangle(...
    'position', [0 0 wRect urn_params.probRed],...
    'FaceColor',[1 0 0],...
    'EdgeColor',[0.5 0.5 0.5],...
    'linewidth',2);
% we are setting the red rectangle, the position is x=0, y=0...
% width=wRect and high=probRed. The face color is red, the edge gray and...
% linewidth 2

hBlue = rectangle( ...
    'position',[0 urn_params.probRed  wRect 1-urn_params.probRed], ...
    'FaceColor',[0 0 1], ...
    'EdgeColor',[0.5 0.5 0.5], ...
    'linewidth', 2);
% we are setting the blue rectangle, the position is x=0, y=probRed level...
% width=wRect and high=1-probRed. The face color is blue, the edge gray and...
%linewidth 2

wAmb = 0.55;

if urn_params.ambLevel > 0
    % the if condition allows us to set the width of the ambRectangle

    hAmb = rectangle('position', [-(wAmb-wRect)/2 ...
                                  0.5-urn_params.ambLevel/2 ...
                                   wAmb urn_params.ambLevel], ...
                     'FaceColor',[0.5 0.5 0.5], ...
                     'EdgeColor',[0.5 0.5 0.5], ...
                     'lineWidth',2);
    % the ambiguity rectangle position x= -(the diff btw the width of the ...
    % rectangle and ambiguity width, y= 0.5-hAmb/2 and widgh=wAmb, hAmb=hAmb
end

if urn_params.selected
    hSel = rectangle('position', [-0.3 -0.3 1.1 1.6], ...
                     'FaceColor', 'none', ...
                     'EdgeColor', [1 1 1], ...
                     'lineWidth', 1);
    
%     set(hRed,  'lineWidth', 6);
%     set(hBlue, 'lineWidth', 6);
%     if urn_params.ambLevel > 0
%         set(hAmb,  'lineWidth', 6);
%     end
end

if urn_params.exante
    %  we are setting the occluder rectangle in exante
    set(hAmb, 'FaceColor', [1 0 0])
    pos = get(hAmb, 'Position');
    sq = pos(3) / 10;
    nx = pos(3) / sq;
    ny = pos(4) / sq;
    for kx = 0:nx
        for ky = 0:ny
            if rem(kx,2) == rem(ky,2)
                continue
            end
            x0 = pos(1) + sq * kx;
            y0 = pos(2) + sq * ky;
            if ( x0 + sq > pos(1) + pos(3) )
                sqx = pos(1) + pos(3) - x0;
                if sqx <=0
                    continue;
                end
            else
                sqx = sq;
            end
            if ( y0 + sq > pos(2) + pos(4) )
                sqy = pos(2) + pos(4) - y0;
                if sqy <=0
                    continue;
                end
            else
                sqy = sq;
            end
            rectangle('position', [x0 y0 sqx sqy], ...
                'FaceColor', [0 0 1], ...
                'EdgeColor', 'none');
        end
    end
    rectangle('position', pos, 'FaceColor', 'none', ...
        'EdgeColor', [0.5 0.5 0.5], 'lineWidth', 2);
end

% Write outcome values
ht(1) = text(0.25, -0.15, num2str(urn_params.outcomeRed));
set(ht(1), 'Color', 'w', 'FontSize', 22, 'FontWeight', 'normal', ...
           'HorizontalAlignment', 'center');
ht(2) = text(0.25, 1.15, num2str(urn_params.outcomeBlue));
set(ht(2), 'Color', 'w', 'FontSize', 22, 'FontWeight', 'normal', ...
           'HorizontalAlignment', 'center');
if ~isempty( urn_params.pay )
    set(ht( urn_params.pay ), 'FontSize', 28, ...
        'Color', 'g', 'FontWeight', 'bold')
end

% Setting of axes
axis equal 
set(gca, 'Xlim', [-0.4 0.9], 'Ylim', [-0.4 1.4], ...
         'color',[0 0 0], ...
         'XTicklabel', [], 'YTicklabel', []);
% set(gca, 'Xlim', [-0.4 0.9], 'Ylim', [-0.4 1.4]);
% set(gcf, 'Color', 'w');
