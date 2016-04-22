if 0
    clear;
    addpath(genpath('~/Documents/MATLAB/useful-functions/FullBNT-1.0.7/'));
    
    % pause;
    
    % % Split AC Schedule data
    % train_val_test_split()
    
    all_dep_spots = {'DA_015'};
    
    tof_dir =  '~/Google Drive/NASA-ATC/procast/eval_framework/data/table_of_factors';
    if ispc
        tof_dir = 'data\table_of_factors'
    end
    nodes =14;
    
    node_sizes_spot = struct('spot_name', {},'gate_size', [], 'spot_size', [], 'actPushbackTime_size' ...
        , [],'actSpotArrTime_size', [] , 'actSpotRelTime_size', [], 'actRwyRelTime_size', [] ...
        , 'actConcurrentGateReleases_size', [] , 'actConcurrentSpotInflux_size', [] ...
        ,'actSpotPassagesInDepDir_size', [] , 'actMergeNodeArrTime_size', [] ...
        ,'actFloRateF010_depDir_size', [] , 'actFloRateG003_depDir_size', []  ...
        ,'actFloRateB034_depDir_size', [] ,'actDepQueueSizeAtMergeNodeArrTime_size', []);
    
    %get max pgm_input node size per spot
    for s = 1:length(all_dep_spots)
        tof_spot = load([tof_dir '/tableOfFactors_data_30sec_timeBin_' all_dep_spots{s} '.mat' ]);
        if ispc
           tof_spot = load([tof_dir '\tableOfFactors_data_30sec_timeBin_' all_dep_spots{s} '.mat' ]);
        end
        table_of_factors_data = tof_spot.tableOfFactors_data;
        pgm_input = convert_table_of_factors_to_pgm_input(table_of_factors_data);
        node_sizes_spot(1).spot_name{s} = all_dep_spots{s};
        node_sizes = max(pgm_input')+1;
        
        node_sizes_spot(1).gate_size{s} = node_sizes(1);
        node_sizes_spot(1).spot_size{s} = node_sizes(2);
        node_sizes_spot(1).actPushbackTime_size{s} = node_sizes(3);
        node_sizes_spot(1).actSpotArrTime_size{s} = node_sizes(4);
        node_sizes_spot(1).actSpotRelTime_size{s} = node_sizes(5);
        node_sizes_spot(1).actRwyRelTime_size{s} = node_sizes(6);
        node_sizes_spot(1).actConcurrentGateReleases_size{s} = node_sizes(7);
        node_sizes_spot(1).actConcurrentSpotInflux_size{s} = node_sizes(8);
        node_sizes_spot(1).actSpotPassagesInDepDir_size{s} = node_sizes(9);
        node_sizes_spot(1).actMergeNodeArrTime_size{s} = node_sizes(10);
        node_sizes_spot(1).actFloRateF010_depDir_size{s} = node_sizes(11);
        node_sizes_spot(1).actFloRateG003_depDir_size{s} = node_sizes(12);
        node_sizes_spot(1).actFloRateB034_depDir_size{s} = node_sizes(13);
        node_sizes_spot(1).actDepQueueSizeAtMergeNodeArrTime_size{s} = node_sizes(14);
        
        
    end
    
    
    %Train BN engine and perform inference
    % training is done -- added by priya
    [all_BN_engines, all_engines_data] = train_BN(node_sizes_spot);
    current_time = 1;
        

 flight_trajectory = struct('spot', {}, 'gate', {}, 'callsign', {}, 'actPushbackTime', NaN,...
        'actSpotArrTime', NaN, 'actSpotRelTime', NaN, 'actRwyRelTime', NaN, ...
        'actMergeNodeArrTime', NaN, 'act_concurrentGateReleases', NaN,...
        'act_concurrentSpotInflux', NaN, 'act_spotPassagesInDepDir', NaN,...
        'act_depQueueSizeAtMergeNodeArrTime', NaN);
    % this will be updated by the predictions -- can be removed
    % Compare distributions
test_dir = '~/Google Drive/NASA-ATC/procast/eval_framework/data/table_of_factors/test';
if ispc
    test_dir = 'data\table_of_factors\test';
end

tstart = 1;
tend = 8*60*60; % Six hours, converted to seconds
timeBin_size = 30; % seconds

% loop on each spot
for k = 1:length(all_dep_spots)
    tof_spot = load([test_dir '/tableOfFactors_data_30sec_timeBin_' all_dep_spots{k} '.mat']);
    if ispc
           tof_spot = load([tof_dir '\tableOfFactors_data_30sec_timeBin_' all_dep_spots{s} '.mat' ]);
    end
    table_of_factors_data = tof_spot.tableOfFactors_data;
    tableOfFactors_data = table_of_factors_data;
    
    flights  = unique(table_of_factors_data.callsign);
    num_flights = numel(flights);
    
    % testing is done here -- added by priya
    [flight_trajectory] = test_BN(all_BN_engines,all_engines_data,current_time);
    runway_pred_errors = zeros(1, num_flights);
    p_distributions = zeros(1, num_flights);
    
    %loop on flight
    for j = 1:num_flights
        
        flight_test_idx = find(ismember(tableOfFactors_data.callsign, flights{j}));
        flight_pred_idx = find(ismember(flight_trajectory.callsign, flights{j}));
        
        act_spot_rel_time_test = tableOfFactors_data.actSpotRelTime(flight_test_idx) * timeBin_size;
        act_merge_arr_time_test = tableOfFactors_data.actMergeNodeArrTime(flight_test_idx) * timeBin_size;
        act_rwy_rel_time_test = tableOfFactors_data.actRwyRelTime(flight_test_idx) * timeBin_size;
        
        act_spot_rel_time_pred = flight_trajectory.actSpotRelTime(flight_pred_idx);
        act_merge_arr_time_pred = flight_trajectory.actMergeNodeArrTime(flight_pred_idx);
        act_rwy_rel_time_pred = flight_trajectory.actRwyRelTime(flight_pred_idx);
        
        test = vertcat(act_spot_rel_time_test, act_merge_arr_time_test, act_rwy_rel_time_test);
        pred = vertcat(act_spot_rel_time_pred, act_merge_arr_time_pred, act_rwy_rel_time_pred);
        
        runway_pred_error = mean((act_rwy_rel_time_test - act_rwy_rel_time_pred).^2);
        [~, p_similar_distributions] = kstest2(act_rwy_rel_time_test, act_rwy_rel_time_pred);
        
        runway_pred_errors(j) = runway_pred_error;
        p_distributions(j) = p_similar_distributions;
    end
end

end

figure;
plot(runway_pred_errors);
ylabel('Mean squared error (seconds)')
set(gca,'fontsize', 16)
figure;
bar(p_distributions);
ylabel('P values of KS test');
set(gca,'fontsize', 16)


figure; plot((act_spot_rel_time_pred - act_spot_rel_time_test));
title('error spot (sec)', 'fontsize', 16)
set(gca,'fontsize', 16)

figure; plot((act_merge_arr_time_pred - act_merge_arr_time_test));
title('error merge (sec)', 'fontsize', 16)
set(gca,'fontsize', 16)

figure; plot((act_rwy_rel_time_pred - act_rwy_rel_time_test));
title('error runway (sec)', 'fontsize', 16)
set(gca,'fontsize', 16)


figure; plot(act_spot_rel_time_pred, 'r'); hold on;
plot(act_spot_rel_time_test, 'b');
set(gca,'fontsize', 16)
% legend('Predicted', 'Observed');
title('spot', 'fontsize', 16)


figure; plot(act_merge_arr_time_pred, 'r'); hold on;
plot(act_merge_arr_time_test, 'b');
set(gca,'fontsize', 16)
% legend('Predicted', 'Observed');
title('Merge', 'fontsize', 16)

figure; plot(act_rwy_rel_time_pred, 'r'); hold on;
plot(act_rwy_rel_time_test, 'b');
set(gca,'fontsize', 16)
% legend('Predicted', 'Observed');
title('Runway', 'fontsize', 16)







