function [all_BN_engines, all_engines_data] = ...
    train_BN(node_sizes_spot, table_of_factors_train_path)

   
files = dir([table_of_factors_train_path '/*.mat']) 
if ispc
    files = dir([table_of_factors_train_path '\*.mat']) 
end

% Each spot of interest has its own training data associated with it.
% A BN is created for each spot
all_BN_engines= containers.Map;
all_engines_data= containers.Map;
% iterate through each spot in the test directory
for table_of_factors_file = files'
    disp(sprintf(['Train: loading \n' table_of_factors_train_path '/' table_of_factors_file.name]));

%     tableOfFactors_data = load([table_of_factors_train_path '/' table_of_factors_file.name]);
%     tableOfFactors_data = tableOfFactors_data.tableOfFactors_data_train;
%     
    load([table_of_factors_train_path '/' table_of_factors_file.name]);
    
    spot = tableOfFactors_data.spot(1);
    spot_of_interest = sprintf('%s',spot{:});
    [engine_map, engine_data_map] = train_BN_engine(spot_of_interest, ...
        tableOfFactors_data, node_sizes_spot);
    all_BN_engines = [all_BN_engines; engine_map];
    all_engines_data = [all_engines_data; engine_data_map];
end
end