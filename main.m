% All paths are relative

clear;
global node_sizes_spots

% -------- Input parameters ----------------
all_dep_spots = {'DA_015'};
tof_dir =  adjust_path_by_OS('data/table_of_factors');
train_dir = adjust_path_by_OS([tof_dir '/train']);
test_dir = adjust_path_by_OS([tof_dir '/test']);

add_global_variables;
% ------------------------------------------

% Load BNT functions
bnt_path = adjust_path_by_OS('../Procast_code/FullBNT-CMU/');
addpath(genpath(bnt_path));
% pause;
% ------------------------------------------

% Split AC Schedule data
% train_val_test_split();

node_sizes_spot = initialize_node_sizes(all_dep_spots);

% get max pgm_input node size per spot
for s = 1:length(all_dep_spots)
    spot_of_interest = all_dep_spots{s};
    tof_spot = load(adjust_path_by_OS([tof_dir '/tableOfFactors_data_30sec_timeBin_' spot_of_interest '.mat']));
    
    node_sizes_spots(spot_of_interest) = ...
        increase_node_sizes(node_sizes_spots(spot_of_interest), ...
        tof_spot.tableOfFactors_data);
end
    
  
% Train BN engine and perform inference
[all_BN_engines, all_engines_data] = train_BN(train_dir);
current_time = 1;


flight_trajectory = struct('spot', {}, 'gate', {}, 'callsign', {}, 'actPushbackTime', NaN,...
    'actSpotArrTime', NaN, 'actSpotRelTime', NaN, 'actRwyRelTime', NaN, ...
    'actMergeNodeArrTime', NaN, 'act_concurrentGateReleases', NaN,...
    'act_concurrentSpotInflux', NaN, 'act_spotPassagesInDepDir', NaN,...
    'act_depQueueSizeAtMergeNodeArrTime', NaN);
% this will be updated by the predictions -- can be removed
% Compare distributions

% loop on each spot
for k = 1:length(all_dep_spots)
    tof_spot = load([test_dir '/tableOfFactors_data_30sec_timeBin_' all_dep_spots{k} '.mat']);
    if ispc
        tof_spot = load([test_dir '\tableOfFactors_data_30sec_timeBin_' all_dep_spots{s} '.mat' ]);
    end
    table_of_factors_data = tof_spot.tableOfFactors_data;
    tableOfFactors_data = table_of_factors_data;
    
    flights  = unique(table_of_factors_data.callsign);
    num_flights = numel(flights);
    
    % testing is done here -- added by priya
    [flight_trajectory] = test_BN(all_BN_engines,all_engines_data,current_time,test_dir);
    runway_pred_errors = zeros(1, num_flights);
    p_distributions = zeros(1, num_flights);
    
    %loop on flight
    for j = 1:num_flights
        
        flight_test_idx = find(ismember(tableOfFactors_data.callsign, flights{j}));
        flight_pred_idx = find(ismember(flight_trajectory.callsign, flights{j}));
        
        act_spot_rel_time_test = tableOfFactors_data.actSpotRelTime(flight_test_idx) * timeBin_size;
        act_merge_arr_time_test = tableOfFactors_data.actMergeNodeArrTime(flight_test_idx) * timeBin_size;
        act_rwy_rel_time_test = tableOfFactors_data.actRwyRelTime(flight_test_idx) * timeBin_size;
        
        act_spot_rel_time_pred = flight_trajectory.actSpotRelTime(flight_pred_idx)*timeBin_size;
        act_merge_arr_time_pred = flight_trajectory.actMergeNodeArrTime(flight_pred_idx)*timeBin_size;
        act_rwy_rel_time_pred = flight_trajectory.actRwyRelTime(flight_pred_idx)*timeBin_size;
        
        test = vertcat(act_spot_rel_time_test, act_merge_arr_time_test, act_rwy_rel_time_test);
        pred = vertcat(act_spot_rel_time_pred, act_merge_arr_time_pred, act_rwy_rel_time_pred);
        
        runway_pred_error = mean((act_rwy_rel_time_test - act_rwy_rel_time_pred).^2);
        [~, p_similar_distributions] = kstest2(act_rwy_rel_time_test, act_rwy_rel_time_pred);
        
        runway_pred_errors(j) = runway_pred_error;
        p_distributions(j) = p_similar_distributions;
    end
end



if 0
    figure;
    plot(runway_pred_errors);
    ylabel('Mean squared error (seconds)')
    set(gca,'fontsize', 16)
    saveas(gcf,'runway_pred_errors','pdf')
    figure;
    bar(p_distributions);
    ylabel('P values of KS test');
    set(gca,'fontsize', 16)
    saveas(gcf,'p_distributions','pdf')
    
    figure; plot((act_spot_rel_time_pred - act_spot_rel_time_test));
    title('error spot (sec)', 'fontsize', 16)
    set(gca,'fontsize', 16)
    saveas(gcf,'error_spot','pdf')
    
    figure; plot((act_merge_arr_time_pred - act_merge_arr_time_test));
    title('error merge (sec)', 'fontsize', 16)
    set(gca,'fontsize', 16)
    saveas(gcf,'error_merge','pdf')
    
    figure; plot((act_rwy_rel_time_pred - act_rwy_rel_time_test));
    title('error runway (sec)', 'fontsize', 16)
    set(gca,'fontsize', 16)
    saveas(gcf,'error_runway','pdf')
    
    figure; plot(act_spot_rel_time_pred, 'r'); hold on;
    plot(act_spot_rel_time_test, 'b');
    set(gca,'fontsize', 16)
    % legend('Predicted', 'Observed');
    title('spot', 'fontsize', 16)
    saveas(gcf,'Spot','pdf')
    
    figure; plot(act_merge_arr_time_pred, 'r'); hold on;
    plot(act_merge_arr_time_test, 'b');
    set(gca,'fontsize', 16)
    % legend('Predicted', 'Observed');
    title('Merge', 'fontsize', 16)
    saveas(gcf,'Merge','pdf')
    
    figure; plot(act_rwy_rel_time_pred, 'r'); hold on;
    plot(act_rwy_rel_time_test, 'b');
    set(gca,'fontsize', 16)
    % legend('Predicted', 'Observed');
    title('Runway', 'fontsize', 16)
    saveas(gcf,'Runway','pdf')
    
end



