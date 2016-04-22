% This script accesses the airport transit times PGM, conditions it on the
% earliest gate arrival time, spot release time, extracts the conditional PMF of merge node arrival
% times, and randomly samples a spot arrival time from that distribution
function actMergeArrTime = sampleErlstMergeNodeTime(index, flight_trajectory, engine, engine_data)
%% First, calculate the values of all "measured" nodes in the PGM

% % Define time-bins
tstart = 1;
tend = 8*60*60; % Six hours, converted to seconds
timeBin_size = 1; % seconds
timeBin_startTimes = tstart:timeBin_size:tend;
timeBin_endTimes = timeBin_startTimes+timeBin_size-1;

% ~~ The below variables are computed from functions that use acSchedules_temp
% Update the acSchedules_temp struct with the new erlstSpotTime
% concurrentGateReleases_current
% concurrentSpotInflux_current
% actFloRateF010_depDir_current
% actFloRateG003_depDir_current
% SpotPassagesInDepDir
% actDepQueueSizeAtMergeNodeArrTime_current

% Actual Pushback Time and Spot Time
actPushbackTime_current = calculateTimeBinNbr(flight_trajectory.actPushbackTime(index), timeBin_startTimes, timeBin_endTimes);
%actSpotTime_current = calculateTimeBinNbr(flight_trajectory.actSpotRelTime(index), timeBin_startTimes, timeBin_endTimes);
actSpotTime_current = flight_trajectory.actSpotRelTime(index);
N = 14; 
timeBin_size = 1;
concurrentGateReleases_current = flight_trajectory.act_concurrentGateReleases(index);
concurrentSpotInflux_current = flight_trajectory.act_concurrentSpotInflux(index); 
concurrentSpotPasseges_current = flight_trajectory.act_spotPassagesInDepDir(index);
actFloRateF010_depDir_current = flight_trajectory.act_floRateF010_depDir(index);
actFloRateG003_depDir_current = flight_trajectory.act_floRateG003_depDir(index);

%% Condition the PGM on the observed nodes, and obtain the spotArrivalTime PMF
% Define the PGM nodes
gate=1;
spot=2;
actPushbackTime=3;
actSpotArrTime=4;
actSpotRelTime=5;
actConcurrentGateReleases=7;
actConcurrentSpotInflux=8;
actSpotPassagesInDepDir=9;
actFloRateF010_depDir=11;
actFloRateG003_depDir=12;
%actFloRateB034_depDir=13;
%actDepQueueSizeAtMergeNodeArrTime=14;

% Get the indicies of Gate and Spot
pgm_gate_index=engine_data.samples(1,index); % 1 - is the gate node
pgm_spot_index=engine_data.samples(2,index); % 2 - is the spot index
% Form the evidence cell
evidence = cell(1,N);
evidence{gate} = pgm_gate_index; % [We dont add 1 because we take pgm_input data where 1 ia already added]
evidence{spot} = pgm_spot_index; % [We dont add 1 because we take pgm_input data where 1 ia already added]
evidence{actPushbackTime} = 1;
evidence{actSpotArrTime} = actSpotTime_current - actPushbackTime_current + 1; % In training, pushbackTime = 1; and
evidence{actSpotRelTime} = actSpotTime_current - actPushbackTime_current + 1; % spotTime = actSpotTime - actPushbackTime + 1.
                                                                                                                                             
evidence{actConcurrentGateReleases} = concurrentGateReleases_current+1;
evidence{actConcurrentSpotInflux} = concurrentSpotInflux_current+1;
evidence{actSpotPassagesInDepDir} = concurrentSpotPasseges_current+1;
evidence{actFloRateF010_depDir} = actFloRateF010_depDir_current+1;
evidence{actFloRateG003_depDir} = actFloRateG003_depDir_current+1;
% evidence{actFloRateB034_depDir} = actFloRateB034_depDir_current+1;
% evidence{actDepQueueSizeAtMergeNodeArrTime} = actDepQueueSizeAtMergeNodeArrTime_current+1;

% Enter the evidence into the engine and perform inference
[engine_test1, loglik] = enter_evidence(engine, evidence);
 mergeNodeArrivalTime_pmf = marginal_nodes(engine_test1, 10,1); % Merge Node Arrival Time 
 if(sum(mergeNodeArrivalTime_pmf.T) == 0)
     mergeNodeArrivalTime_pmf.T(8) = 1;
     disp('Zero merge pmf');
 end
 sampledGateToMergeNodeTransitTime = randomPick([0:timeBin_size:(length(mergeNodeArrivalTime_pmf.T)-1)*timeBin_size], mergeNodeArrivalTime_pmf.T);
actMergeArrTime = sampledGateToMergeNodeTransitTime;
end