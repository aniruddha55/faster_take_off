function flight_trajectory = perturb_trajectory_using_posteriors(index, ...
    flight_trajectory, current_time, engine, engine_data, table_of_factors_data, timeBin_size)

% Create flight_trajectory data structure.
% Data structure contains variables 1 to 6 and 10 of the BNet.
% 	All times are initialized to NaN.
if ~exist('timeBin_size', 'var')
    timeBin_size = 30; % seconds
end

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

[actSpotArrTime, actMergeArrTime, actRwyArrTime] = ...
    sampleAllTransitTimes(index, flight_trajectory, engine, engine_data, timeBin_size);

flight_trajectory.actSpotRelTime(index) = actSpotArrTime + ...
    flight_trajectory.actPushbackTime(index);
flight_trajectory.actMergeNodeArrTime(index) = actMergeArrTime + ...
    flight_trajectory.actPushbackTime(index);
flight_trajectory.actRwyRelTime(index) = actRwyArrTime+...
    flight_trajectory.actPushbackTime(index);


if 0
    % if abs(flight_trajectory.actRwyRelTime(index) - timeBin_size*table_of_factors_data.actRwyArrTime(index)) > 60
    fprintf('Error = %f', abs(flight_trajectory.actRwyRelTime(index) - timeBin_size*table_of_factors_data.actRwyArrTime(index)) )
    flight_trajectory.actPushbackTime(index)
    
    disp('Actual')
    timeBin_size * [table_of_factors_data.actSpotArrTime(index), table_of_factors_data.actMergeNodeArrTime(index), table_of_factors_data.actRwyArrTime(index)]
    
    fprintf('Actual bin %d \n', table_of_factors_data.actRwyArrTime(index) - table_of_factors_data.actPushbackTime(index))
    
    disp('Predicted')
    [flight_trajectory.actSpotRelTime(index), flight_trajectory.actMergeNodeArrTime(index), flight_trajectory.actRwyRelTime(index)]
    
    
    %     pause;
end

end




