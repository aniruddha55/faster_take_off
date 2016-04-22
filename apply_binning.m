function apply_binning(tof_dir, timeBin_size)

tof_spot = load([tof_dir '/tableOfFactors_data_no_Bin_DA_015.mat']);
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
    

save([tof_dir '/tableOfFactors_data_30sec_timeBin_DA_015.mat'],'tableOfFactors_data');

end



function timeBin_number = TimeBinNbrVector(time_in_seconds, time_bin_width)
timeBin_number = ceil(time_in_seconds/time_bin_width);
end