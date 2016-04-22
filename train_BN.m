function [engine_map, engine_data_map] = ...
    train_BN(table_of_factors_train_path)
add_global_variables;
   
files = dir(adjust_path_by_OS([table_of_factors_train_path ...
    '/tableOfFactors_data_' num2str(timeBin_size) 'sec_timeBin_' '*.mat']));

% Each spot of interest has its own training data associated with it.
% A BN is created for each spot

engine_map = containers.Map;
engine_data_map = containers.Map;

% iterate through each spot in the test directory
counter = 1;
files
for table_of_factors_file = files'
    %disp(sprintf(['Train: loading \n' table_of_factors_train_path '/' table_of_factors_file.name]));

    tableOfFactors_data = load(adjust_path_by_OS([table_of_factors_train_path '/' table_of_factors_file.name]));
    tableOfFactors_data = tableOfFactors_data.tableOfFactors_data;%_train;
    
    spot = tableOfFactors_data.spot(1);
    spot_of_interest = sprintf('%s',spot{:});
    [engine_key, engine, engine_data_key, PGM_Engines_data] = train_BN_engine(spot_of_interest, ...
        tableOfFactors_data);
    if counter == 1
        engine_map = containers.Map(engine_key, engine);
        engine_data_map = containers.Map(engine_data_key, PGM_Engines_data);
    else
        engine_map(engine_key) = engine;
        engine_data_map(engine_data_key) = engine_data_key;
    end
%     all_BN_engines = [all_BN_engines; engine_map];
%     all_engines_data = [all_engines_data; engine_data_map];
    counter = counter + 1;
end
end