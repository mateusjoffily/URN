clear all

fraw = '..\Data\dataALL.xls';        % Table with input data
fout = '..\Data\dataALLfitted.txt';  % Output file in which results will be saved

dowhat = 'fit';  % You can choose to 'fit' the data or 'plot' the results 
                 % after fitting: 'fit' or 'plot'.

% Load raw data
%-------------------------------------------------------------------------
[numeric, txt] = xlsread(fraw, 'B2:X2071');

subjID = numeric(:,23);

choiceKey = numeric(:,15);
shiftLR = numeric(:,13);

choice = zeros( size(choiceKey) );
choice( ( choiceKey == 1 & shiftLR == 1 ) | ...
    ( choiceKey == 3 & shiftLR == 2 ) ) = 1;

probV = numeric(:,1);
idx = find( probV > 0.5 );
probV( idx ) =  1 - probV( idx );

rewardV = numeric(:,7) + numeric(:,8);

ambV = numeric(:,2);
exanteV = numeric(:,3);

subjALL = unique(subjID);
Ntrials = numel(choice) / numel(subjALL);

% fixed urn probability and reward is always the same
probF = repmat(0.5, Ntrials, 1);
rewardF = repmat(10, Ntrials, 1);

% Do what?
%--------------------------------------------------------------------------
switch dowhat

    case 'fit'
        % Initial value of parameters
        %------------------------------------------------------------------
        alpha =  0.1:0.2:2;
        beta  = -1:0.2:1;
        theta = -1:0.2:1;
        gamma =  0:0.2:3;

        [ALPHA, BETA, THETA, GAMMA] = ndgrid(alpha, beta, theta, gamma);

        % parameters constraints (alpha, beta, theta, gamma)
        LB = [0   -1 -1 0];
        UB = [Inf  1  1 Inf];

        % Optimization options
        dispOK = true;
        if dispOK
            options = optimset('Display','iter');
        else
            options = optimset('Display','final');
        end
        try
            options = optimset(options, 'Algorithm', 'interior-point');
        catch
            options = optimset(options, 'LargeScale', 'off');
        end

        % Loop over subjects
        %------------------------------------------------------------------
        params0S  = zeros(max(subjALL), 4);
        paramsS   = zeros(max(subjALL), 4);
        LLS       = zeros(max(subjALL), 1);
        pseudoR2S = zeros(max(subjALL), 1);
        exitflagS = zeros(max(subjALL), 1);

        % Find best initial parameters
        %------------------------------------------------------------------
        for subj = subjALL'

            fprintf(1, 'Searching best initial values for subject %d\n', subj);

            iS = find( subjID == subj );

            data = [probF, rewardF, probV(iS), rewardV(iS), ...
                ambV(iS), exanteV(iS), choice(iS)];

            LL = zeros(1, numel(ALPHA));
            for n = 1:numel(ALPHA)
                params = [ALPHA(n), BETA(n), THETA(n), GAMMA(n)];
                LL(n) = -urn_fit_data(params, data);
            end

            % Index of best initial parameters
            [iV iP] = max(LL);
            params0S(subj,:) = [ALPHA(iP), BETA(iP), THETA(iP), GAMMA(iP)];
        end

        % % set mean best initial parameters the same to every subject
        % params0Sback = params0S;
        % params0S = repmat(mean(params0S), numel(subjALL), 1);

        % Fit subject data
        %------------------------------------------------------------------
        for subj = subjALL'

            fprintf(1, 'Estimating parameters for subject %d\n', subj);

            iS = find( subjID == subj );

            data = [probF, rewardF, probV(iS), rewardV(iS), ...
                ambV(iS), exanteV(iS), choice(iS)];

            % Fit model
            [params nLL exitflag] = fmincon(@urn_fit_data, ....
                params0S(subj,:), [], [], [], [], LB, UB, [], options, data);

            paramsS(subj,:) = params;
            LLS(subj)       = -nLL;
            exitflagS(subj) = exitflag;

            % compute pseudo-r2 (Camerer and Ho, 1999)
            %--------------------------------------------------------------
            % log data likelihood under chance
            R = Ntrials * log( 0.5 );

            % 0 = pure chance, 1 = perfect prediction
            pseudoR2S(subj) = 1 - ( LLS(subj) / R );

        end

        % Save results to file
        %------------------------------------------------------------------
        [pf,nf] = fileparts(fout);
        
        save(fullfile(pf, nf), 'paramsS', 'params0S', 'LLS', ...
            'pseudoR2S', 'exitflagS');

        fid = fopen(fullfile(pf, [nf '.txt']), 'w');
        fprintf(fid, 'subjID\t');
        fprintf(fid, 'alpha0\tbeta0\ttheta0\tgamma0\t');
        fprintf(fid, 'alpha\tbeta\ttheta\tgamma\t');
        fprintf(fid, 'LL\tpseudoR2\tfitExitFlag\n');
        for subj = subjALL'
            fprintf(fid, '%d\t', subj);
            fprintf(fid, '%0.3f\t', params0S(subj,1));
            fprintf(fid, '%0.3f\t', params0S(subj,2));
            fprintf(fid, '%0.3f\t', params0S(subj,3));
            fprintf(fid, '%0.3f\t', params0S(subj,4));
            fprintf(fid, '%0.3f\t', paramsS(subj,1));
            fprintf(fid, '%0.3f\t', paramsS(subj,2));
            fprintf(fid, '%0.3f\t', paramsS(subj,3));
            fprintf(fid, '%0.3f\t', paramsS(subj,4));
            fprintf(fid, '%0.3f\t', LLS(subj));
            fprintf(fid, '%0.3f\t', pseudoR2S(subj));
            fprintf(fid, '%d\n', exitflagS(subj));
        end
        fclose(fid);

    case 'plot'
        % load fitted parameters
        %------------------------------------------------------------------
        [pf,nf] = fileparts(fout);
        load(fullfile(pf, nf));
        
        % Plot results
        %------------------------------------------------------------------
        for subj = subjALL'
%         for subj = 1

            iS = find( subjID == subj );

            h = figure(subj);
            set(h, 'Color', 'w');
            ftitle = sprintf('Subject %d (r^2= %0.2f, n=%d)', ...
                subj, pseudoR2S(subj), Ntrials);
            set(h, 'Name', ftitle);

            %     data = [probF, rewardF, probV(iS), rewardV(iS), ...
            %         ambV(iS), exanteV(iS), choice(iS)];
            params = paramsS(subj,:);

            reward = 0:70;
            
            probS   = unique(probV(iS));
            rewardS = unique(rewardV(iS));
            ambS = unique(ambV(iS));
            exanteS = unique(exanteV(iS));

            cc   = {[0.6 0.6 1] [0 0 0.9] [0 0 0.6]; ...
                    [1 0.6 0.6] [0.9 0 0] [0.6 0 0]; ...
                    [0.6 1 0.6] [0 0.9 0] [0 0.6 0]};
            param_str1 = {'alpha' 'beta' 'theta'};
            param_str2 = {'p=' 'A=' 'E='};
            param_val2 = {num2str(probS(1:3)) num2str(ambS(2:4)) ...
                          num2str(ambS(2:4))};
            for k = 1:3
                subplot(1,3,k);
                hold on
                for n = 1:3
                    if k == 1       % risk
                        svV = urn_fit_sv(params(1:3), probS(n), reward, 0, 0);
                        idx = ( subjID == subj & ambV == 0 & ...
                                exanteV == 0 & probV == probS(n));
                    elseif k == 2   % ambiguity
                        svV = urn_fit_sv(params(1:3), 0.5, reward, ambS(1+n), 0);
                        idx = ( subjID == subj & ambV == ambS(1+n) & ...
                                exanteV == 0);
                    elseif k == 3   % exante
                        svV = urn_fit_sv(params(1:3), 0.5, reward, ambS(1+n), 1);
                        idx = ( subjID == subj & ambV == ambS(1+n) & ...
                                exanteV == 1);
                    end
                    svF = urn_fit_sv(params(1:3), 0.5, 10, 0, 0);
                    Pv = urn_fit_Pv(svF, svV, params(4));
                    hp(n) = plot(reward, Pv, 'Color', cc{k,n}, 'LineWidth', 2);

                    % Plot measured proportions
                    for i = 1:numel(rewardS)
                        idxR = idx & rewardV == rewardS(i);
                        plot(rewardS(i), sum(choice(idxR))/sum(idxR), 'o', ...
                            'Color', cc{k,n}, 'LineWidth', 2);
                    end
                end
                xlabel('Amount[$]');
                ylabel(sprintf('Proportion of trials in which subject\nchose the variable option'));
                title( sprintf( '%s=%0.3f', param_str1{k}, params(k) ) );
                ylim([0 1]);
                xlim([0 70]);
                axis square
                legend(hp, [repmat(param_str2{k},3,1) param_val2{k}], ...
                    'Location','SouthOutside');
                legend('boxoff')
            end
        end
end

