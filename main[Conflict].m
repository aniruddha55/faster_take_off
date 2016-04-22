addpath(genpath('~/Documents/MATLAB/useful-functions/FullBNT-1.0.7/'));
clear;

%Split AC Schedule data
% train_val_test_split()

%Train BN engine and perform inference
% training is done -- added by priya
[all_BN_engines, all_engines_data] = train();
current_time = 1;

flight_trajectory = struct('spot', {}, 'gate', {}, 'callsign', {}, 'actPushbackTime', NaN,...
    'actSpotArrTime', NaN, 'actSpotRelTime', NaN, 'actRwyRelTime', NaN, ...
    'actMergeNodeArrTime', NaN, 'act_concurrentGateReleases', NaN,...
    'act_concurrentSpotInflux', NaN, 'act_spotPassagesInDepDir', NaN,...
    'act_depQueueSizeAtMergeNodeArrTime', NaN);

%this will be updated by the predictions -- can be removed

%Compare distributions
all_dep_spots = {'DA_015'}
test_dir = '~/Google Drive/NASA-ATC/procast/eval_framework/data/table_of_factors/test'

%loop on each spot
for k = 1:length(all_dep_spots)
    tof_spot = load([test_dir '/tableOfFactors_data_30sec_timeBin_' all_dep_spots{k} '.mat' ])
    table_of_factors_data = tof_spot.tableOfFactors_data;
    tableOfFactors_data = table_of_factors_data;
    
    flights  = unique(table_of_factors_data.callsign);
    num_flights = numel(flights);
    
    % testing is done here -- added by priya
    [flight_trajectory] = test(all_BN_engines,all_engines_data,current_time);
    runway_pred_errors = zeros(1, num_flights);
    runway_p_distributions = zeros(1, num_flights);
    merge_pred_errors = zeros(1, num_flights);
    merge_p_distributions = zeros(1, num_flights);
    %loop on flight
    for j = 1:num_flights
         
         flight_test_idx = find(ismember(tableOfFactors_data.callsign, flights{j}));
         flight_pred_idx = find(ismember(flight_trajectory.callsign, flights{j}));
         
         act_spot_rel_time_test = tableOfFactors_data.actSpotRelTime(flight_test_idx);
         act_merge_arr_time_test = tableOfFactors_data.actMergeNodeArrTime(flight_test_idx);
         act_rwy_rel_time_test = tableOfFactors_data.actRwyRelTime(flight_test_idx);
         
         act_spot_rel_time_pred = flight_trajectory.actSpotRelTime(flight_pred_idx);
         act_merge_arr_time_pred = flight_trajectory.actMergeNodeArrTime(flight_pred_idx);
         act_rwy_rel_time_pred = flight_trajectory.actRwyRelTime(flight_pred_idx);
         
         test = vertcat(act_spot_rel_time_test, act_merge_arr_time_test, act_rwy_rel_time_test);
         pred = vertcat(act_spot_rel_time_pred, act_merge_arr_time_pred, act_rwy_rel_time_pred);
         
         runway_pred_error = sqrt(mean((act_rwy_rel_time_test - act_rwy_rel_time_pred).^2));
         [~, p_similar_distributions_rrunway] = kstest2(act_rwy_rel_time_test, act_rwy_rel_time_pred);
         
         merge_pred_error = sqrt(mean((act_merge_arr_time_test - act_merge_arr_time_pred).^2));
         [~, p_similar_distributions_merge] = kstest2(act_merge_arr_time_test, act_merge_arr_time_pred);
         
         runway_pred_errors(j) = runway_pred_error;
         runway_p_distributions(j) = p_similar_distributions_rrunway;
         
         merge_pred_errors(j) = merge_pred_error;
         merge_p_distributions(j) = p_similar_distributions_merge;
         
%          figure;plot(act_merge_arr_time_test,'b');hold on; plot(act_merge_arr_time_pred,'r')
%          pause;

    end 
end

figure;
plot(1:num_flights, merge_pred_errors/60,'linewidth',3);
set(gca,'fontsize',16)
set(gca,'XTickLabel', flights, 'XTickLabelRotation', 45, 'XTick', 1:num_flights)
ylabel('Root mean squared error (min)')
grid on;
% saveas(gcf, 'merge_node_errors', 'pdf');

% figure;
% bar(1:num_flights, merge_p_distributions);
% set(gca,'fontsize',16)
% set(gca,'XTickLabel', flights, 'XTickLabelRotation', 45, 'XTick', 1:num_flights)
% ylabel('P values of KS test');
% % saveas(gcf, 'merge_node_p_values', 'pdf');



figure;
plot(runway_pred_errors/60);
ylabel('Mean squared error (min)')

% figure;
% bar(runway_p_distributions);
% ylabel('P values of KS test');
% 

