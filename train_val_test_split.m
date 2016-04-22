function train_val_test_split(data_directory, input_dir, timeBin_size)
% Randomly shuffles the files and copies the partitioned files
% into three separate directories train-{timestamp}, test-{timestamp}
% and val-{timestamp}

if ~exist('data_directory', 'var')
    data_directory = '~/Google Drive/NASA-ATC/procast/eval_framework/data';
    if ispc
        data_directory  = 'Procast_code\';
    end
end
if ~exist('input_dir', 'var')
    input_dir = [data_directory  '/acschedules-txt-10-temp'];
    input_dir = [data_directory  '/acschedules-txt-501'];
end

data_directory = '~/Google Drive/NASA-ATC/procast/eval_framework/data';
input_dir = [data_directory  '/acschedules-txt-501'];

% tof_dir =  [data_directory '/table_of_factors'];
tof_dir =  [data_directory '/table_of_factors_no_bin'];

if 0
    create_table_of_factors(input_dir, '', data_directory, tof_dir);
end

if 0
    %     timeBin_size = 30;
    apply_binning(tof_dir, timeBin_size);
end


d = dir(strcat(input_dir,'/*.txt'));
fileNames = {d.name};
n = numel(fileNames);
shuffleidx = randperm(length(fileNames));


% Divide files in train:val:test ratio (3:1:1)
len_train = floor(4/5*n);
%len_val = floor(1/5*n);
% len_train = 2;
% len_val = 2;

len_train
%%%%%%SPLI TOF%%%%%%%%%%%

all_dep_spots = {'DA_015'};
for s = 1:length(all_dep_spots)
    tof_fname = [tof_dir '/tableOfFactors_data_no_Bin_'...
        all_dep_spots{s} '.mat' ];
    tof_spot = load(tof_fname);
    table_of_factors_data = tof_spot.tableOfFactors_data;
    
    flights  = unique(table_of_factors_data.callsign);
    num_flights = numel(flights);
    
    tableOfFactors_data_train = struct('callsign', {}, 'gate', {}, 'runway', {}, 'spot', {}, 'schPushbackTime', [], 'actPushbackTime', [], 'schSpotArrTime', [], 'actSpotArrTime', [], 'schSpotRelTime', [], 'actSpotRelTime', [],...
        'schRwyArrTime', [], 'actRwyArrTime', [], 'schRwyRelTime', [], 'actRwyRelTime', [], 'gateToSpotDistance', [], 'pred_concurrentGateReleases', [], 'act_concurrentGateReleases', [], ...
        'pred_concurrentSpotInflux', [], 'act_concurrentSpotInflux', [], 'pred_spotPassagesInDepDir', [], 'act_spotPassagesInDepDir', [], 'pred_spotPassagesInDepDir_v2', [], 'pred_mergeNodePassagesInArrDir', [], ...
        'actMergeNodeArrTime', [], 'schMergeNodeArrTime', [], 'pred_floRateDA015_depDir', [], 'act_floRateDA015_depDir', [], 'pred_floRateF010_depDir', [], 'act_floRateF010_depDir', [], ...
        'pred_floRateG003_depDir', [], 'act_floRateG003_depDir', [], 'pred_floRateB034_depDir', [], 'act_floRateB034_depDir', [], ...
        'pushbackDelay', [], 'rampDelay', [], 'spotDelay', [], 'movAreaDelay', [], 'runwayDelay', []);
    
    tableOfFactors_data_test = struct('callsign', {}, 'gate', {}, 'runway', {}, 'spot', {}, 'schPushbackTime', [], 'actPushbackTime', [], 'schSpotArrTime', [], 'actSpotArrTime', [], 'schSpotRelTime', [], 'actSpotRelTime', [],...
        'schRwyArrTime', [], 'actRwyArrTime', [], 'schRwyRelTime', [], 'actRwyRelTime', [], 'gateToSpotDistance', [], 'pred_concurrentGateReleases', [], 'act_concurrentGateReleases', [], ...
        'pred_concurrentSpotInflux', [], 'act_concurrentSpotInflux', [], 'pred_spotPassagesInDepDir', [], 'act_spotPassagesInDepDir', [], 'pred_spotPassagesInDepDir_v2', [], 'pred_mergeNodePassagesInArrDir', [], ...
        'actMergeNodeArrTime', [], 'schMergeNodeArrTime', [], 'pred_floRateDA015_depDir', [], 'act_floRateDA015_depDir', [], 'pred_floRateF010_depDir', [], 'act_floRateF010_depDir', [], ...
        'pred_floRateG003_depDir', [], 'act_floRateG003_depDir', [], 'pred_floRateB034_depDir', [], 'act_floRateB034_depDir', [], ...
        'pushbackDelay', [], 'rampDelay', [], 'spotDelay', [], 'movAreaDelay', [], 'runwayDelay', []);
    
    tof_train_idx=1;
    tof_test_idx=1;
    f = fieldnames(table_of_factors_data);
    eval(['n = length(table_of_factors_data.' f{1} ');'])
    n = n/num_flights;
    
    sim_idx = [1:n*num_flights];
    sim_idx = reshape(sim_idx, num_flights, (n));
    sim_idx = sim_idx';
    
    sim_shfl = randperm(n);
    train_idx = sim_idx(sim_shfl(1:len_train),:);
    test_idx = sim_idx(sim_shfl(len_train+1: numel(sim_shfl)),:);
    train_idx = train_idx(:);
    test_idx = test_idx(:);
    len_test = numel(sim_shfl) - len_train;
    
    for f_idx=1:length(f)        
        eval(['field_size = size(table_of_factors_data.' f{f_idx} ');']);
        if( field_size > 0)
            eval(['tableOfFactors_data_train(1).' f{f_idx} ' = table_of_factors_data.' f{f_idx} '(train_idx);' ]);
            eval(['tableOfFactors_data_test(1).' f{f_idx} ' = table_of_factors_data.' f{f_idx} '(test_idx);' ]);
        end        
    end
    
    tableOfFactors_data = tableOfFactors_data_train;
    size(tableOfFactors_data.spot)
    save([tof_dir ,'/train/tableOfFactors_data_30sec_timeBin_', all_dep_spots{s}, '_train.mat'], 'tableOfFactors_data');
    
    tableOfFactors_data = tableOfFactors_data_test;
    size(tableOfFactors_data.spot)
    save([tof_dir ,'/test/tableOfFactors_data_30sec_timeBin_', all_dep_spots{s}, '_test.mat'], 'tableOfFactors_data');
end


end

