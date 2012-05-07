function LL = urn_fit_LL(Pv, choice)

logP = log( [1-Pv Pv] );

m = numel(Pv);
idx = sub2ind([m 2], (1:m)', choice+1);

% Log-likelihood
LL = sum( logP( idx ) );

end
