function nLL = urn_fit_data(params0, data)
% data = [probF, rewardF, probV, rewardV, ambV, exanteV, choice]

svF = urn_fit_sv(params0(1:3), data(:,1), data(:,2), 0, 0);
svV = urn_fit_sv(params0(1:3), data(:,3), data(:,4), ...
                          data(:,5), data(:,6));
Pv = urn_fit_Pv(svF, svV, params0(4));

% Minimize the negative log-likelihood
nLL = -urn_fit_LL(Pv, data(:,7));

end
