% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by: Aditya Saraf
% Date: April, 2014
% Project: NASA LEARN MDO project - Year 1

% Purpose: This script processes acSchedules data for each Monte Carlo
% iteration and creates data-fields necessary for generating the CPDs. This
% script is called from within the Monte Carlo loop in the generate_cpds
% script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define parameters
% spot_of_interest = 'DA_015';
mergeNodeNum = 65; % A_035
mergeNodeNum_alternate = 112; % B_034
concurrencyIdentificationTimeLimit = 120;
mergeIdentificationTimeLimit = 120;
Tbefore = 120;
Tafter = 30;
rwyRelTimeBuffer = 60;
boundaryNode_location = 112;

%% Down-select departures
all_optypes = {acSchedules.opType};
dep_indices = strmatch('DEP', all_optypes, 'exact');

all_spot_nodeNums = [acSchedules.spotNodeNum];
all_spots = {nodeLinkData(all_spot_nodeNums+1).name};
spotOfInterest_indices = strmatch(spot_of_interest, all_spots, 'exact');

flightIndices_ofInterest = intersect(dep_indices, spotOfInterest_indices);

nbr_of_deps = length(flightIndices_ofInterest);

%% Main loop: For each departure, calculate each variable and populate it in the master struct
for ii = 1:nbr_of_deps
    master_depFlt_counter = master_depFlt_counter + 1;
    dep_index = flightIndices_ofInterest(ii);
    
    thisDep_callsign = acSchedules(dep_index).callsign;
        
    thisDep_gateNodeNum = acSchedules(dep_index).gateNodeNum;
    thisDep_spotNodeNum = acSchedules(dep_index).spotNodeNum;
    thisDep_runway = acSchedules(dep_index).runway;
    thisDep_taxiRoute = acSchedules(dep_index).taxiRoute;
    
    tableOfFactors_data(1).callsign{master_depFlt_counter} = thisDep_callsign;
    tableOfFactors_data.gate{master_depFlt_counter} = nodeLinkData(thisDep_gateNodeNum+1).name;
    tableOfFactors_data.spot{master_depFlt_counter} = nodeLinkData(thisDep_spotNodeNum+1).name;
    tableOfFactors_data.runway{master_depFlt_counter} = thisDep_runway;
    
    
    % Gate Times
    tableOfFactors_data.schPushbackTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).nomSchTimes(1), timeBin_startTimes, timeBin_endTimes);
    tableOfFactors_data.actPushbackTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).actRelTimes(1), timeBin_startTimes, timeBin_endTimes);
    
    % Spot Times
    spot_index = find(acSchedules(dep_index).taxiRoute == acSchedules(dep_index).spotNodeNum);
    tableOfFactors_data.schSpotArrTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).nomSchTimes(spot_index), timeBin_startTimes, timeBin_endTimes);
    tableOfFactors_data.actSpotArrTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).actArrTimes(spot_index), timeBin_startTimes, timeBin_endTimes);
    
    tableOfFactors_data.schSpotRelTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).nomSchTimes(spot_index), timeBin_startTimes, timeBin_endTimes);
    tableOfFactors_data.actSpotRelTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).actRelTimes(spot_index), timeBin_startTimes, timeBin_endTimes);
    
    % Runway Times
    tableOfFactors_data.schRwyArrTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).nomSchTimes(end), timeBin_startTimes, timeBin_endTimes);
    tableOfFactors_data.actRwyArrTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).actArrTimes(end), timeBin_startTimes, timeBin_endTimes);
    
    tableOfFactors_data.schRwyRelTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).nomSchTimes(end), timeBin_startTimes, timeBin_endTimes);
    tableOfFactors_data.actRwyRelTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).actRelTimes(end), timeBin_startTimes, timeBin_endTimes);
    
    % Delays
    tableOfFactors_data.pushbackDelay(master_depFlt_counter) = floor(acSchedules(dep_index).actRelTimes(1) - acSchedules(dep_index).nomSchTimes(1));
    
    rampTime_nominal = acSchedules(dep_index).nomSchTimes(spot_index) - acSchedules(dep_index).nomSchTimes(1);
    rampTime_actual = acSchedules(dep_index).actArrTimes(spot_index) - acSchedules(dep_index).actRelTimes(1);
    tableOfFactors_data.rampDelay(master_depFlt_counter) = floor(rampTime_actual - rampTime_nominal);
    
    tableOfFactors_data.spotDelay(master_depFlt_counter) = floor(acSchedules(dep_index).actRelTimes(spot_index) - acSchedules(dep_index).actArrTimes(spot_index));

    movAreaTime_nominal = acSchedules(dep_index).nomSchTimes(end) - acSchedules(dep_index).nomSchTimes(spot_index);
    movAreaTime_actual = acSchedules(dep_index).actArrTimes(end) - acSchedules(dep_index).actRelTimes(spot_index);
    tableOfFactors_data.movAreaDelay(master_depFlt_counter) = floor(movAreaTime_actual - movAreaTime_nominal);
    
    tableOfFactors_data.runwayDelay(master_depFlt_counter) = floor(acSchedules(dep_index).actRelTimes(end) - acSchedules(dep_index).actArrTimes(end));   
    
    % Influencing factors
    
    % Predicted/actual number of gate releases from the same gate-area in X minutes prior to the actual gate release time
    [temp_pred, temp_act] = compute_nbrOfConcurrentGateReleases(thisDep_callsign, acSchedules, concurrencyIdentificationTimeLimit);
    tableOfFactors_data.pred_concurrentGateReleases(master_depFlt_counter) = temp_pred;
    tableOfFactors_data.act_concurrentGateReleases(master_depFlt_counter) = temp_act;
    
    % Predicted/actual number of spot crossings by arrivals into the same gate/ramp area in X minutes prior to the actual gate release time
    [temp_pred, temp_act] = compute_concurrentSpotInflux(thisDep_callsign, acSchedules, concurrencyIdentificationTimeLimit);
    tableOfFactors_data.pred_concurrentSpotInflux(master_depFlt_counter) = temp_pred;
    tableOfFactors_data.act_concurrentSpotInflux(master_depFlt_counter) = temp_act;
    
    % Predicted/actual number of spot passages in the same departure direction in X minutes prior to the actual spot arrival time
    timeOfComputation_pred = acSchedules(dep_index).nomSchTimes(spot_index);
    timeOfComputation_act = acSchedules(dep_index).actArrTimes(spot_index);
    segment_startNode = 56;
    segment_middleNode = 57;
    segment_endNode = 58;
    [temp_pred, temp_act] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    tableOfFactors_data.pred_spotPassagesInDepDir(master_depFlt_counter) = temp_pred;
    tableOfFactors_data.act_spotPassagesInDepDir(master_depFlt_counter) = temp_act;
    
    % Actual merge-node arrival time ('actMergeNodeArrTime')
    mergeNode_index = find(thisDep_taxiRoute == mergeNodeNum);
    if(isempty(mergeNode_index))
        mergeNode_index = find(thisDep_taxiRoute == mergeNodeNum_alternate);
    end
    tableOfFactors_data.actMergeNodeArrTime(master_depFlt_counter) = calculateTimeBinNbr(acSchedules(dep_index).actArrTimes(mergeNode_index), timeBin_startTimes, timeBin_endTimes);
    
    % Departure queue-size at the actual merge-node arrival time ('depQueueSizeAtMergeNodeArrTime')
    [temp_pred, temp_act] = compute_depQueueSizeAtMergeNodeArrTime(thisDep_callsign, acSchedules, concurrencyIdentificationTimeLimit, mergeNodeNum);
    tableOfFactors_data.pred_depQueueSizeAtMergeNodeArrTime(master_depFlt_counter) = temp_pred;
    tableOfFactors_data.act_depQueueSizeAtMergeNodeArrTime(master_depFlt_counter) = temp_act;
    
     % Predicted/actual flow-rate across the first "intermediate-spot" (F_010 for the initial test) in the same direction as the departure flow ('act_floRateF010_depDir')
    timeOfComputation_pred = acSchedules(dep_index).nomSchTimes(spot_index);
    timeOfComputation_act = acSchedules(dep_index).actArrTimes(spot_index);
    segment_startNode = 62; % Flow passing across the ramp entry
    segment_middleNode = 63;
    segment_endNode = 64;
    [temp_pred1, temp_act1] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    segment_startNode = 205; % Flow coming from the F-ramp
    segment_middleNode = 63;
    segment_endNode = 64;
    [temp_pred2, temp_act2] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    tableOfFactors_data.pred_floRateF010_depDir(master_depFlt_counter) = temp_pred1+temp_pred2;
    tableOfFactors_data.act_floRateF010_depDir(master_depFlt_counter) = temp_act1+temp_act2;
    
    % Predicted/actual flow-rate across the second "intermediate-spot" (G_003 for the initial test) in the same direction as the departure flow ('pred_floRateG003_depDir')
    timeOfComputation_pred = acSchedules(dep_index).nomSchTimes(spot_index);
    timeOfComputation_act = acSchedules(dep_index).actArrTimes(spot_index);
    segment_startNode = 64; % Flow passing across the ramp entry
    segment_middleNode = 65;
    segment_endNode = 112;
    [temp_pred1, temp_act1] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    segment_startNode = 219; % Flow coming from the F-ramp
    segment_middleNode = 65;
    segment_endNode = 112;
    [temp_pred2, temp_act2] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    tableOfFactors_data.pred_floRateG003_depDir(master_depFlt_counter) = temp_pred1+temp_pred2;
    tableOfFactors_data.act_floRateG003_depDir(master_depFlt_counter) = temp_act1+temp_act2;
    
    
    % Predicted flow-rate across the merging onto final queue node (B_034 for the initial test) in the same direction as the departure flow ('pred_floRateB034_depDir')
    timeOfComputation_pred = acSchedules(dep_index).nomSchTimes(spot_index);
    timeOfComputation_act = acSchedules(dep_index).actArrTimes(spot_index);
    segment_startNode = 113; % Flow merging onto the final single-lane departure queueing area
    segment_middleNode = 112;
    segment_endNode = 221;
    [temp_pred1, temp_act1] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    segment_startNode = 113; % Flow crossing the departure-flow in the opposite direction
    segment_middleNode = 112;
    segment_endNode = 111;
    [temp_pred2, temp_act2] = ...
        compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit);
    
    tableOfFactors_data.pred_floRateB034_depDir(master_depFlt_counter) = temp_pred1+temp_pred2;
    tableOfFactors_data.act_floRateB034_depDir(master_depFlt_counter) = temp_act1+temp_act2;
    
end

    
    
    
    