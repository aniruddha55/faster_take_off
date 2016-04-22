
clear;
% data_directory = '~/Google Drive/NASA-ATC/procast/eval_framework/data';
% if ispc
%     data_directory = 'data';
% end
% -----------------------------------------------------------------------
% table_of_factors_path = [data_directory '/table_of_factors/train/'];
% if ispc
%     table_of_factors_path = [data_directory 'table_of_factors\train\*.mat'];
% end
% [nodeLinkData, aircraftTypes] = load_static_data(data_directory);
% 
% all_dep_spots = {'DA_015', 'F_010'};
% all_dep_spots = {'DA_015'};
% Each spot of interest has its own training data associated with it.
% if ispc
%     table_of_factors_path = ['data\table_of_factors\test\*.mat'];
% end
% files = dir(table_of_factors_path) 
% all_BN_engines= containers.Map;
% all_engines_data=[];
% for table_of_factors_file = files'
% for spot_nbr = 1:length(all_dep_spots)
%     spot_of_interest = all_dep_spots{spot_nbr};
%       table_of_factors_path = [data_directory '/table_of_factors/train/'];
%     if ispc
%         table_of_factors_path = [data_directory '\table_of_factors\train\'];
%     end
%     [table_of_factors_data] = load_table_of_factors_data(spot_of_interest, ...
%         table_of_factors_path);
%     load(table_of_factors_file.name);
%     spot = tableOfFactors_data.spot(1);
%     spot_of_interest = sprintf('%s',spot{:});
%     [engine_map, engine_data_map] = train_BN_engine(spot_of_interest, tableOfFactors_data);
%    if spot_nbr == 1
%        all_BN_engines = engine_map;
%        all_engines_data = engine_data_map;
%    else
%         all_BN_engines = [all_BN_engines; engine_map];
%         all_engines_data = [all_engines_data; engine_data_map];
%     end
%     
%     flight_index = 1;
%     for flight_index = 1:4%length(table_of_factors_data.gate)
%         flight_index=2;
%     current_time = 10;
%     
%     str=sprintf('%s','PGM_Engines_data_',spot_of_interest);
%     engine_spot_name = strcat('engine_',spot_of_interest); %sprintf('%s','engine_',thisDep_spot);
%     engine = all_BN_engines(engine_spot_name); % First, select the correct PGM engine based on the spot
%     
%     flight_trajectory = struct('spot', {}, 'gate', {}, 'callsign', {},'actPushbackTime', NaN,...
%     'actSpotArrTime', NaN, 'actSpotRelTime', NaN, 'actRwyRelTime', NaN, ...
%     'actMergeNodeArrTime', NaN, 'act_concurrentGateReleases', NaN,...
%     'act_concurrentSpotInflux', NaN, 'act_spotPassagesInDepDir', NaN,...
%     'act_depQueueSizeAtMergeNodeArrTime', NaN);
%     for index = 1:10
%     flight_trajectory = perturb_trajectory(index, flight_trajectory,current_time, engine, tableOfFactors_data);
%     [flight_trajectory.actPushbackTime(index) flight_trajectory.actSpotRelTime(index) ...
%         flight_trajectory.actMergeNodeArrTime(index) flight_trajectory.actRwyRelTime(index)]
%     end
%     end
% end
%train_val_test_split();
[all_BN_engines, all_engines_data] = train();
current_time = 10;
%[flight_trajectory] = test(all_BN_engines,all_engines_data,current_time);





