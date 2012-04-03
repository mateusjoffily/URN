function prob = urn_simulation_choice 

%Risk Behavior in Averse, Neutral and Loving subject

% table=importdata('subject_Roby.txt');
table=importdata('urn_trials_exp.txt');

% Total number of trials
nT = size(table.data,1);

probRedHR  = table.data(:,1);
probBlueHR = 1 - probRedHR;
AmbHR      = table.data(:,2);
exanteHR   = table.data(:,3);

probRedBR  = table.data(:,4);
probBlueBR = 1 - probRedBR;
AmbBR      = table.data(:,5);
exanteBR   = table.data(:,6);

outcomeRedHR  = table.data(:,7);
outcomeBlueHR = table.data(:,8);

outcomeRedBR  = table.data(:,9);
outcomeBlueBR = table.data(:,10);

outcomeHR = [outcomeRedHR outcomeBlueHR];
idx = sub2ind(size(outcomeHR), 1:nT, table.data(:,11)');
payRedBlueHR = outcomeHR(idx);

outcomeBR = [outcomeRedBR outcomeBlueBR];
idx = sub2ind(size(outcomeBR), 1:nT, table.data(:,12)');
payRedBlueBR = outcomeBR(idx);

prob.riskIdx   = find( AmbHR == 0 );                  % risk trials
prob.ambIdx    = find( AmbHR > 0 & exanteHR == 0 );  % ambigous
prob.exanteIdx = find( AmbHR > 0 & exanteHR == 1 );  % exante

% Our assumption that the subjects evaluates the hidden probability of Red
% and Blue in the HR urn as 0.5
probRedHR([prob.ambIdx prob.exanteIdx]) = 0.5;

EvHR  = probRedHR .* outcomeRedHR + probBlueHR .* outcomeBlueHR;
SdHR  = ( probRedHR  .* (outcomeRedHR - EvHR).^2 + ...
          probBlueHR .* (outcomeBlueHR - EvHR).^2 ) .^(1/2);

EvBR  = probRedBR .* outcomeRedBR + probBlueBR .* outcomeBlueBR;
SdBR  = ( probRedBR  .* (outcomeRedBR - EvBR).^2 + ...
          probBlueBR .* (outcomeBlueBR - EvBR).^2 ) .^(1/2);

dEv  = EvHR - EvBR;
dSd  = SdHR - SdBR;
dAmb = AmbHR - AmbBR;

prob.subjType = {'averse', 'neutral', 'lover'};
NS       = numel(prob.subjType);

% Initalize variables
prob.HR         = zeros(nT, NS);
prob.EmoNeutral = zeros(nT, NS);
prob.EmoRegret  = zeros(nT, NS);
prob.EmoRelief  = zeros(nT, NS);

for nS = 1:NS   % loop over subject types

    prob.HR(:, nS) = prob_HR(dEv, dSd, dAmb, prob.subjType{nS});
%     prob.HR(:, nS) = prob_HR_simple(nT, prob.subjType{nS});

    % Indexes of outcome comparison
    prob.iHReqBR = find(payRedBlueHR == payRedBlueBR);
    prob.iHRgtBR = find(payRedBlueHR > payRedBlueBR);
    prob.iHRloBR = find(payRedBlueHR < payRedBlueBR);

    % When the pay in both urns are the same, only neutral emotion can be
    % experienced
    prob.EmoNeutral( prob.iHReqBR, nS ) = 1;

    % Emotions when HR urn pays more than BR urn
    prob.EmoRelief(prob.iHRgtBR, nS) = prob.HR(prob.iHRgtBR, nS);
    prob.EmoRegret(prob.iHRgtBR, nS) = 1 - prob.HR(prob.iHRgtBR, nS);

    % Emotions when HR urn pays less than BR urn
    prob.EmoRelief(prob.iHRloBR, nS) = 1 - prob.HR(prob.iHRloBR, nS);
    prob.EmoRegret(prob.iHRloBR, nS) = prob.HR(prob.iHRloBR, nS);

end

% Now we compute the average probability of experiencing each emotion
prob.risk.HR         = mean(prob.HR(prob.riskIdx,:), 1);
prob.risk.EmoNeutral_mean = mean(prob.EmoNeutral(prob.riskIdx,:), 1);
prob.risk.EmoRelief_mean  = mean(prob.EmoRelief(prob.riskIdx,:), 1);
prob.risk.EmoRegret_mean  = mean(prob.EmoRegret(prob.riskIdx,:), 1);
prob.risk.EmoNeutral_sd = std(prob.EmoNeutral(prob.riskIdx,:), 1);
prob.risk.EmoRelief_sd  = std(prob.EmoRelief(prob.riskIdx,:), 1);
prob.risk.EmoRegret_sd  = std(prob.EmoRegret(prob.riskIdx,:), 1);
prob.risk.N = numel(prob.riskIdx);
prob.risk.EmoNeutral_meanNTrial = prob.risk.N * prob.risk.EmoNeutral_mean;
prob.risk.EmoRelief_meanNTrial  = prob.risk.N * prob.risk.EmoRelief_mean;
prob.risk.EmoRegret_meanNTrial  = prob.risk.N * prob.risk.EmoRegret_mean;


prob.amb.HR         = mean(prob.HR(prob.ambIdx,:), 1);
prob.amb.EmoNeutral_mean = mean(prob.EmoNeutral(prob.ambIdx,:), 1);
prob.amb.EmoRelief_mean  = mean(prob.EmoRelief(prob.ambIdx,:), 1);
prob.amb.EmoRegret_mean  = mean(prob.EmoRegret(prob.ambIdx,:), 1);
prob.amb.EmoNeutral_sd = std(prob.EmoNeutral(prob.ambIdx,:), 1);
prob.amb.EmoRelief_sd  = std(prob.EmoRelief(prob.ambIdx,:), 1);
prob.amb.EmoRegret_sd  = std(prob.EmoRegret(prob.ambIdx,:), 1);
prob.amb.N = numel(prob.ambIdx);
prob.amb.EmoNeutral_meanNTrial = prob.amb.N * prob.amb.EmoNeutral_mean;
prob.amb.EmoRelief_meanNTrial  = prob.amb.N * prob.amb.EmoRelief_mean;
prob.amb.EmoRegret_meanNTrial  = prob.amb.N * prob.amb.EmoRegret_mean;

end


function p = prob_HR(dEvR, dSdR, dAmbR, subjType)

A = 0;  
B = 0.25;
K = -4; 

switch subjType 
    case 'averse'
        G = -0.15; 
        
    case 'neutral'
        G = 0;
        
    case 'lover'
        G = 0.15;
end

EU = A + B * dEvR + G * dSdR + K * dAmbR;

p = exp( EU ) ./ ( 1 + exp(EU) );

end


function p = prob_HR_simple(nT, subjType)

switch subjType 
    case 'averse'
        p = 0.1; 
        
    case 'neutral'
        p = 0.5;
        
    case 'lover'
        p = 0.9;
end

p = repmat(p, nT, 1);

end


    
