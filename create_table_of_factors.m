function create_table_of_factors(input_dir, type, data_dir, ...
    output_table_of_factors_dir)
% input_dir: train,test,val directory with acScheduleData files
% type: train, test, val
% Creates the tableOfFactors data structure for all of the spots of
% interest after parsing the acScheduleData files in the input_dir
% Writes the tableOfFactors for the train, test and val set in the relevant
% Output directory.


% output_table_of_factors_dir = [data_dir '/table_of_factors/'];


d = dir(strcat(input_dir,'/*.txt'));
file_names = {d.name};

all_dep_spots = {'DA_015'};

[nodeLinkData, aircraftTypes] = load_static_data(data_dir);

% %% Generate the training data table - table of factors - from simulation data
% % Define time-bins
tstart = 1;
tend = 8*60*60; % Six hours, converted to seconds
timeBin_size = 30; % seconds
timeBin_startTimes = tstart:timeBin_size:tend;
timeBin_endTimes = timeBin_startTimes+timeBin_size-1;
% 

for spot_nbr = 1:length(all_dep_spots)
     
    spot_of_interest = all_dep_spots{spot_nbr};
    % Define/initialize data struct for the table of factors
    % The factors are basically the variables that form the nodes of the
    % Bayesian Belief Network. For the new PGM, these variables are:
    % v1 = Gate ('gate')
    % v2 = Spot ('spot')
    % v3 = Gate-to-spot distance ('gateToSpotDistance')
    % v4 = Actual Gate Release Time ('actPushbackTime')
    % v5 = Predicted number of gate releases from the same gate-area in 5 minutes prior to the actual gate release time ('pred_concurrentGateReleases')
    % v6 = Actual number of gate releases from the same gate-area in 5 minutes prior to the actual gate release time ('act_concurrentGateReleases')
    % v7 = Predicted number of spot crossings by arrivals into the same gate/ramp area in 5 minutes prior to the actual gate release time ('pred_concurrentSpotInflux')
    % v8 = Actual number of spot crossings by arrivals into the same gate/ramp area in 5 minutes prior to the actual gate release time ('act_concurrentSpotInflux')
    % v9 = Actual spot arrival time ('actSpotArrTime')
    % v11 = Predicted number of spot passages in the same departure direction in 5 minutes prior to the actual spot arrival time ('pred_spotPassagesInDepDir')
    % v12 = Actual number of spot passages in the same departure direction in 5 minutes prior to the actual spot arrival time ('act_spotPassagesInDepDir')
    % v13 = Actual spot release time ('actSpotRelTime')
    % v14 = Predicted number of spot passages in the same departure direction in 5 minutes prior to the actual spot release time ('pred_spotPassagesInDepDir_v2')
    % v15 = Predicted number of merge-node passages opposite to the departure direction in 5 minutes after (or should this be prior to) the actual spot release time ('pred_mergeNodePassagesInArrDir')  - not important, skip
    % v16 = Distance from spot to merge-node (may not be important because it is the same for all flights using the same spot, skip)
    % v17 = Actual merge-node arrival time ('actMergeNodeArrTime')
    % v18 = Departure queue-size at the actual merge-node arrival time ('depQueueSizeAtMergeNodeArrTime')
    % v19 = Actual runway node arrival time ('actRwyArrTime')
    % v20 = Predicted flow-rate across the "self-spot" (DA_015 for the initial test) in the same direction as the departure flow ('pred_floRateDA015_depDir' same as 'pred_spotPassagesInDepDir')
    % v21 = Actual flow-rate across the "self-spot" (DA_015 for the initial test) in the same direction as the departure flow ('act_floRateDA015_depDir')
    % v22 = Predicted flow-rate across the first "intermediate-spot" (F_010 for the initial test) in the same direction as the departure flow ('pred_floRateF010_depDir')
    % v23 = Actual flow-rate across the first "intermediate-spot" (F_010 for the initial test) in the same direction as the departure flow ('act_floRateF010_depDir')
    % v24 = Predicted flow-rate across the second "intermediate-spot" (G_003 for the initial test) in the same direction as the departure flow ('pred_floRateG003_depDir')
    % v25 = Actual flow-rate across the second "intermediate-spot" (G_003 for the initial test) in the same direction as the departure flow ('act_floRateG003_depDir')
    % v26 = Predicted flow-rate across the merging onto final queue node (B_034 for the initial test) in the same direction as the departure flow ('pred_floRateB034_depDir')
    % v27 = Actual flow-rate across the merging onto final queue node (B_034 for the initial test) in the same direction as the departure flow ('act_floRateB034_depDir')

    tableOfFactors_data = struct('callsign', {}, 'gate', {}, 'runway', {}, 'spot', {}, 'schPushbackTime', [], 'actPushbackTime', [], 'schSpotArrTime', [], 'actSpotArrTime', [], 'schSpotRelTime', [], 'actSpotRelTime', [],...
            'schRwyArrTime', [], 'actRwyArrTime', [], 'schRwyRelTime', [], 'actRwyRelTime', [], 'gateToSpotDistance', [], 'pred_concurrentGateReleases', [], 'act_concurrentGateReleases', [], ...
            'pred_concurrentSpotInflux', [], 'act_concurrentSpotInflux', [], 'pred_spotPassagesInDepDir', [], 'act_spotPassagesInDepDir', [], 'pred_spotPassagesInDepDir_v2', [], 'pred_mergeNodePassagesInArrDir', [], ...
            'actMergeNodeArrTime', [], 'schMergeNodeArrTime', [], 'pred_floRateDA015_depDir', [], 'act_floRateDA015_depDir', [], 'pred_floRateF010_depDir', [], 'act_floRateF010_depDir', [], ...
            'pred_floRateG003_depDir', [], 'act_floRateG003_depDir', [], 'pred_floRateB034_depDir', [], 'act_floRateB034_depDir', [], ...
            'pushbackDelay', [], 'rampDelay', [], 'spotDelay', [], 'movAreaDelay', [], 'runwayDelay', []);

    %% MAIN LOOP
    master_depFlt_counter = 0;
    
    d = dir(strcat(input_dir,'/*.txt'));
    max_sim_iters = numel({d.name});
%     ONLY 1 acschedule file available
%     max_sim_iters = 1;
    runtimes = zeros(max_sim_iters,2);
    
    for sim_iter = 1:max_sim_iters

        if(mod(sim_iter,20) == 1)
            disp(['Processing simulation number ', num2str(sim_iter), ' out of ' num2str(max_sim_iters)])
        end

        % Load ACScheduleData.txt
        % disp('Loading ACScheduleData.txt...')
        % acScheduleDataFile = ['C:\Work\LEARN_MDO_SOSS_SimData\SOSS_Kevin_sims2\051414_1256_', num2str(sim_iter), '\ACScheduleData.txt'];
        % acScheduleDataFile = ['C:\Work\LEARN_MDO_SOSS_SimData\SOSS_Kevin_6hr_sims\090814_1800_', num2str(sim_iter), '\ACScheduleData.txt'];
        acScheduleDataFile = [input_dir, ...
            '/' char(file_names(sim_iter))];

        tstart = tic;
        
        loadACScheduleData;       
        
        telapsed1 = toc(tstart);
% pause;

        % Process simulation data for this simulation iteration
        % disp(['Processing data for iteration ', num2str(sim_iter)])
        processData_and_updateTableOfFactors;
        
        
        telapsed2 = toc(tstart);
        runtimes(sim_iter,:) = [telapsed1 telapsed2];
        
        if(sim_iter == 20)
            stoppp = 1;
        end
    end

    %save([output_table_of_factors_dir ,type,'/tableOfFactors_data_30sec_timeBin_', spot_of_interest, '.mat'], 'tableOfFactors_data', 'runtimes')    
    save([output_table_of_factors_dir ,type,'/tableOfFactors_data_no_Bin_', spot_of_interest, '.mat'], 'tableOfFactors_data', 'runtimes')    

end

