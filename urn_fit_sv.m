function  sv = urn_fit_sv(params, prob, reward, amb, exante)
% params = [alpha, beta, theta]

% Force probability to be equal to 0.5 in ambiguity and exante urns
prob( amb > 0 ) = 0.5;

% sv = ( prob - ( params(2) + params(3) .* exante ) .* ( amb ./ 2 ) ) .* ...
%     reward.^params(1);

% Estimate theta and beta independently for ambigous and exante urns
sv = ( prob - ( params(2) .* ~exante + params(3) .* exante ) .* ( amb ./ 2 ) ) .* ...
    reward.^params(1);

end