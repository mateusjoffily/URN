function urn_write_table

% Table file name
ftable = 'urn_trials.txt';

% Urn parameters
pWin       = [0.13 0.25 0.38];
ambLevel   = [0 0.25 0.50 0.75];
exante     = [0 1];
outcomeWin = [15 30 50];
colour     = [0 1];    % red=0, blue=1
code       = [];       % 6 factors with levels:
                       % [pWin=3 ambLevel=4 exante=2 outcomeWin=3 ...
                       %  colour=2 shiftLR=2]

% Compute ambigous and exante trials with winning red
n = 0;
for ip = 1:length(pWin)
    for ia = 1:length(ambLevel)
        for ie = 1:length(exante)
            for io = 1:length(outcomeWin)
                for ic = 1:length(colour)
                    
                    if ambLevel(ia) == 0
                        % risky conditions
                        if exante(ie) == 1
                            continue
                        end
                    elseif ambLevel(ia)/2 < 0.5-pWin(ip)
                        continue
                    end
                    
                    n = n + 1;
                    probRedL(n)    = abs( pWin(ip) - colour(ic) );
                    ambLevelL(n)   = ambLevel(ia);
                    exanteL(n)     = exante(ie);
                    outcomeWinL(n) = outcomeWin(io);
                    
                    % shift urns LR = 1 (no) or 2 (yes)
                    shiftLR(n) = 1 + round(rand(1)); 
                    
                    code(n) = ASF_encode([ip ia ie io ic shiftLR(n)] - 1, ...
                                              [3 4 2 3 2 2]);
                    
                end
            end
        end
    end
end

% Total number of trials created
nTrials = length(probRedL);

% Randomize trials
i = randperm(nTrials);
probRedL    = probRedL(i);
ambLevelL   = ambLevelL(i);
exanteL     = exanteL(i);
outcomeWinL = outcomeWinL(i);
shiftLR     = shiftLR(i);
code        = code(i);

% Write table
fid = fopen(ftable, 'w');

% Write table header
fprintf(fid, 'probRedL\t ambLevelL\t exanteL\t ');
fprintf(fid, 'probRedR\t ambLevelR\t exanteR\t ');
fprintf(fid, 'outcomeWinL\t outcomeLossL\t ');
fprintf(fid, 'outcomeWinR\t outcomeLossR\t ');
fprintf(fid, 'payDownUpL\t payDownUpR\t ');
fprintf(fid, 'shiftLR\t trialCode\n');

% Write trials
for n = 1:nTrials
    fprintf(fid, '%0.2f\t %0.2f\t %d\t 0.5\t 0\t 0\t ', ...
                                   probRedL(n), ambLevelL(n), exanteL(n));
    
    % 1 = down(red) and 2 = up(blue)
    payDownUpL = 1 + binornd(1, 1-probRedL(n));
    payDownUpR = 1 + binornd(1, 0.5);
    
    if probRedL(n) < 0.5
        fprintf(fid, '%d\t 0\t 10\t 0\t %d\t %d\t ', ...
            outcomeWinL(n), payDownUpL, payDownUpR);
    else
        fprintf(fid, '0\t %d\t 0\t 10\t %d\t %d\t ', ...
            outcomeWinL(n), payDownUpL, payDownUpR);
    end
    
    fprintf(fid, '%d\t %d\n', shiftLR(n), code(n));
end

fclose(fid);

disp([ftable ' created.']);

