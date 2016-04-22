function [engine_key, engine, engine_data_key, PGM_Engines_data] = ...
    train_BN_engine(spot_of_interest, tableOfFactors_data)
% Convert the training data into the correct format for input to PGM model
% generation code
pgm_input = convert_table_of_factors_to_pgm_input(tableOfFactors_data);

% Generate the PGM engine
engine = PROCAST_PGM_v3(pgm_input, spot_of_interest);
PGM_Engines_data.samples = pgm_input;

% eval([sprintf(['engine_', spot_of_interest]) '=engine']);
% eval([sprintf(['PGM_Engines_data_', spot_of_interest]) '=PGM_Engines_data']);

engine_key = sprintf(['engine_', spot_of_interest]);
engine_data_key = sprintf(['PGM_Engines_data_', spot_of_interest]);

% engine_map = containers.Map(engine_key, engine);
% engine_data_map = containers.Map(engine_data_key, PGM_Engines_data);

end