function urn_create_table

% Table file name
ftable = 'urn_trials.txt';

% Urn parameters
pWin       = [0.13 0.25 0.38];
ambLevel   = [0.25 0.50 0.75];
outcomeWin = [15 30 50];
exante     = [1 0];

% Compute ambigous and exante trials with winning red
n = 0;
for ip = 1:length(pWin)
    for ia = 1:length(ambLevel)
        for ie = 1:length(exante)
            for io = 1:length(outcomeWin)

                if ambLevel(ia)/2 < 0.5-pWin(ip)
                    continue
                end

                n = n + 1;
                probRedL(n)  = pWin(ip);
                ambLevelL(n) = ambLevel(ia);
                exanteL(n)   = exante(ie);
                winL(n)      = outcomeWin(io);

            end
        end
    end
end

% Now, compute risky conditions
for ip = 1:length(pWin)
    for io = 1:length(outcomeWin)
        n = n + 1;
        probRedL(n)  = pWin(ip);
        ambLevelL(n) = 0;
        exanteL(n)   = 0;
        winL(n)      = outcomeWin(io);
    end
end

% Now, repeat the same trials with winning blue
probRedL  = [probRedL 1-probRedL];
ambLevelL = [ambLevelL ambLevelL];
exanteL   = [exanteL exanteL];
winL      = [winL winL];

% Total number of trials created
nTrials = length(probRedL);

% Randomize trials
i = randperm(nTrials);
probRedL  = probRedL(i);
ambLevelL = ambLevelL(i);
exanteL   = exanteL(i);
winL      = winL(i);

% Write table
fid = fopen(ftable, 'w');

for n = 1:nTrials
    fprintf(fid, '%0.2f\t %0.2f\t %0.2f\t 0.5\t 0\t 0\t', ...
                                   probRedL(n), ambLevelL(n), exanteL(n));
    if probRedL(n) < 0.5                       
        fprintf(fid, '%d\t 0\t 10\t 0\n', winL(n));
    else
        fprintf(fid, '0\t %d\t 0\t 10\n', winL(n));
    end
end

fclose(fid);

disp([ftable ' created.']);

