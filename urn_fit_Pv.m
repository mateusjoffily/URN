function Pv = urn_fit_Pv(svF, svV, gamma)

% Probability that the subject chose the variable lottery
D = ( 1 + exp( gamma .* ( svF - svV ) ) );
Pv  = 1 ./ D;

end