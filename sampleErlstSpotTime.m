function actSpotArrTime = sampleErlstSpotTime(index, flight_trajectory, engine, engine_data)
% This script accesses the airport transit times PGM, conditions it on the
% earliest gate arrival time, extracts the conditional PMF of spot arrival
% times, and randomly samples a spot arrival time from that distribution

%% First, calculate the values of all "measured" nodes in the PGM

% ~~ The below variables are computed from functions that use acSchedules_temp
% thisDep_actPushbackTime
% concurrentGateReleases_current
% concurrentSpotInflux_current
% actFloRateF010_depDir_current
% actFloRateG003_depDir_current

N = 14; 
timeBin_size = 1;
actPushbackTime_current = 1; %pgm_input takes actPushbackTime = 1
concurrentGateReleases_current = flight_trajectory.act_concurrentGateReleases(index);
concurrentSpotInflux_current = flight_trajectory.act_concurrentSpotInflux(index); %0;


%% Condition the PGM on the observed nodes, and obtain the spotArrivalTime PMF
% Define the PGM nodes
gate=1;
spot=2;
actPushbackTime=3;
actConcurrentGateReleases=7;
actConcurrentSpotInflux=8;

% Get the indicies of Gate and Spot
pgm_gate_index=engine_data.samples(1,index); % 1 - is the gate node
pgm_spot_index=engine_data.samples(2,index); % 2 - is the spot index

% Form the evidence cell
evidence = cell(1,N);
evidence{gate} = pgm_gate_index; % [We dont add 1 because we take pgm_input data where 1 ia already added]
evidence{spot} = pgm_spot_index; % [We dont add 1 because we take pgm_input data where 1 ia already added]
evidence{actPushbackTime} =  actPushbackTime_current;
evidence{actConcurrentGateReleases} = concurrentGateReleases_current+1;
evidence{actConcurrentSpotInflux} = concurrentSpotInflux_current+1;

% Enter the evidence into the engine and perform inference
[engine_test1, loglik] = enter_evidence(engine, evidence);
spotArrivalTime_pmf = marginal_nodes(engine_test1, 4,1); % Spot Arrival Time


if(sum(spotArrivalTime_pmf.T) == 0)
    spotArrivalTime_pmf.T(3) = 1;
    disp('Zero spot pmf');
end

sampledGateToSpotTransitTime = randomPick([0:timeBin_size:(length(spotArrivalTime_pmf.T)-1)*timeBin_size], spotArrivalTime_pmf.T);

actSpotArrTime = sampledGateToSpotTransitTime; % check, may be added to the actPushBackTime

end