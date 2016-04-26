function apply_binning(tof_dir, timeBin_size)

all_dep_spots = {'DA_015'};
for s = 1:length(all_dep_spots)

    tof_spot = load([tof_dir '/tableOfFactors_data_no_Bin_' all_dep_spots{s} '.mat']);
    tableOfFactors_data = tof_spot.tableOfFactors_data;

    tableOfFactors_data.schPushbackTime = TimeBinNbrVector(tableOfFactors_data.schPushbackTime, timeBin_size);
    tableOfFactors_data.actPushbackTime = TimeBinNbrVector(tableOfFactors_data.actPushbackTime, timeBin_size);
    tableOfFactors_data.schSpotArrTime = TimeBinNbrVector(tableOfFactors_data.schSpotArrTime, timeBin_size);
    tableOfFactors_data.actSpotArrTime = TimeBinNbrVector(tableOfFactors_data.actSpotArrTime, timeBin_size);
    tableOfFactors_data.schSpotRelTime = TimeBinNbrVector(tableOfFactors_data.schSpotRelTime, timeBin_size);
    tableOfFactors_data.actSpotRelTime = TimeBinNbrVector(tableOfFactors_data.actSpotRelTime, timeBin_size);
    tableOfFactors_data.schRwyArrTime = TimeBinNbrVector(tableOfFactors_data.schRwyArrTime, timeBin_size);
    tableOfFactors_data.actRwyArrTime = TimeBinNbrVector(tableOfFactors_data.actRwyArrTime, timeBin_size);
    tableOfFactors_data.schRwyRelTime = TimeBinNbrVector(tableOfFactors_data.schRwyRelTime, timeBin_size);
    tableOfFactors_data.actRwyRelTime = TimeBinNbrVector(tableOfFactors_data.actRwyRelTime, timeBin_size);

    tableOfFactors_data.actMergeNodeArrTime = TimeBinNbrVector(tableOfFactors_data.actMergeNodeArrTime, timeBin_size);

    save([tof_dir '/tableOfFactors_data_'  num2str(timeBin_size) 'sec_timeBin_' all_dep_spots{s} '.mat'],'tableOfFactors_data');
end
end



function timeBin_number = TimeBinNbrVector(time_in_seconds, time_bin_width)
timeBin_number = ceil(time_in_seconds/time_bin_width);
end