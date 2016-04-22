function [flight_trajectory] = test_BN(all_BN_engines,all_engines_data,current_time)
data_directory = '~/Google Drive/NASA-ATC/procast/eval_framework/data';
if ispc
    data_directory = 'data\';
end
table_of_factors_path = [data_directory '/table_of_factors/test/'];
if ispc
    table_of_factors_path = [data_directory 'table_of_factors\test\*.mat'];
end
    
files = dir([table_of_factors_path '/*.mat']); 

% iterate through each spot in the test directory
for table_of_factors_file = files'
    load([table_of_factors_path '/' table_of_factors_file.name]);
    
    spot = tableOfFactors_data.spot(1);
    spot_of_interest = sprintf('%s',spot{:});
    % extract the BN engine
    data_name = sprintf('%s','PGM_Engines_data_',spot_of_interest);
    engine_spot_name = strcat('engine_',spot_of_interest); %sprintf('%s','engine_',thisDep_spot);
    
    engine = all_BN_engines(engine_spot_name); % First, select the correct PGM engine based on the spot
    
%     % ANIRUDDHA: THIS DOES NOT WORK
%     % TRAIN AND TEST SETS ARE DIFFERNET
%     engine_data = all_engines_data(data_name);
    
   
    pgm_input = convert_table_of_factors_to_pgm_input(tableOfFactors_data);
    engine_data.samples = pgm_input;
    
    
    flight_trajectory = struct('spot', {}, 'gate', {}, 'callsign', {},'actPushbackTime', NaN,...
    'actSpotArrTime', NaN, 'actSpotRelTime', NaN, 'actRwyRelTime', NaN, ...
    'actMergeNodeArrTime', NaN, 'act_concurrentGateReleases', NaN,...
    'act_concurrentSpotInflux', NaN, 'act_spotPassagesInDepDir', NaN,...
    'act_depQueueSizeAtMergeNodeArrTime', NaN);

    length(tableOfFactors_data.gate)
    for index = 1:length(tableOfFactors_data.gate)
%         flight_trajectory = perturb_trajectory(index, flight_trajectory,current_time, ...
%             engine,engine_data, tableOfFactors_data);
        
        flight_trajectory = perturb_trajectory_using_posteriors(index, flight_trajectory,current_time, ...
            engine,engine_data, tableOfFactors_data);
        
        
        %[flight_trajectory.actPushbackTime(index) flight_trajectory.actSpotRelTime(index) ...
        %flight_trajectory.actMergeNodeArrTime(index) flight_trajectory.actRwyRelTime(index)]
    end
end
    





