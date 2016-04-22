function flight_trajectory = perturb_trajectory(index, flight_trajectory, current_time, engine, engine_data, table_of_factors_data)

% Create flight_trajectory data structure.
% Data structure contains variables 1 to 6 and 10 of the BNet.
% 	All times are initialized to NaN.

timeBin_size = 30; % seconds

% Get historical data and update trajectory
flight_trajectory(1).spot(index) = table_of_factors_data.spot(index);
flight_trajectory.gate(index) = table_of_factors_data.gate(index);
flight_trajectory.callsign(index) = table_of_factors_data.callsign(index);
flight_trajectory.act_concurrentGateReleases(index) = table_of_factors_data.act_concurrentGateReleases(index);
flight_trajectory.act_concurrentSpotInflux(index) = table_of_factors_data.act_concurrentSpotInflux(index);
flight_trajectory.act_spotPassagesInDepDir(index) = table_of_factors_data.act_spotPassagesInDepDir(index);
flight_trajectory.act_floRateF010_depDir(index) = table_of_factors_data.act_floRateF010_depDir(index);
flight_trajectory.act_floRateG003_depDir(index) = table_of_factors_data.act_floRateG003_depDir(index);
flight_trajectory.act_floRateB034_depDir(index) = table_of_factors_data.act_floRateB034_depDir(index);
flight_trajectory.act_depQueueSizeAtMergeNodeArrTime(index) = table_of_factors_data.act_depQueueSizeAtMergeNodeArrTime(index);

flight_trajectory.actPushbackTime(index) = ...
        table_of_factors_data.actPushbackTime(index) * timeBin_size;
if(current_time > table_of_factors_data.actSpotArrTime(index))
    flight_trajectory.actSpotArrTime(index) = ...
        table_of_factors_data.actSpotArrTime(index);
end

    disp('sampleErlstSpotTime');
if (current_time > table_of_factors_data.actSpotRelTime(...
            index))
    flight_trajectory.actSpotRelTime(index) = ...
            table_of_factors_data.actSpotRelTime(index);
else
    % update gate to spot trasit time
    actSpotRelTime_current = sampleErlstSpotTime(index, ...
        flight_trajectory, engine, engine_data);
    flight_trajectory.actSpotRelTime(index) = actSpotRelTime_current + ...
        flight_trajectory.actPushbackTime(index);
end

disp('actMergeNodeArrTime')
if (current_time > table_of_factors_data.actMergeNodeArrTime(index))
    flight_trajectory.actMergeNodeArrTime(index) = ...
        table_of_factors_data.actMergeNodeArrTime(index);
else
    % update gate to merge node trasit time
    actMergeNodeArrTime_current = sampleErlstMergeNodeTime(index, ...
        flight_trajectory, engine, engine_data);
    flight_trajectory.actMergeNodeArrTime(index) = actMergeNodeArrTime_current + ...
        flight_trajectory.actPushbackTime(index);
end    

disp('sampleErlstRwyTime')
if (current_time > table_of_factors_data.actRwyRelTime(index))
    flight_trajectory.actRwyRelTime(index) = ...
        table_of_factors_data.actRwyRelTime(index);
else
    % update gate to runway trasit time
    actRwyRelTime_current = sampleErlstRwyTime(index, flight_trajectory, ...
        engine, engine_data);
    flight_trajectory.actRwyRelTime(index) = actRwyRelTime_current+...
        flight_trajectory.actPushbackTime(index);
end 
end




