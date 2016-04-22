function [tableOfFactors_data] = load_table_of_factors_data(spot_of_interest, data_path)

% spot_of_interest = 'DA_015';

% Load training data
disp('Loading tableOfFactors.mat...');
trainingData_filename = [data_path, 'tableOfFactors_data_30sec_timeBin_', ...
    spot_of_interest, '.mat'];

%trainingData_filename = [data_path, 'tableOfFactors_data_no_Bins_', ...
   % spot_of_interest, '.mat'];

if( isempty(trainingData_filename) )
    return
else
    load(trainingData_filename);
end


end