% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by: Aditya Saraf
% Date: April 2012
% Project: Surface Traffic Management NRA

% Purpose: This function computes the predicted and actual number of spot
% passages in the departure direction around the time the subject departure
% flight's spot arrival time. This function will be used by  PGM-building
% scripts to   compute the data required for one conditioning random
% variable. This script is called from the
% processData_and_updateTableOfFactors.m script
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [flowRate_pred, flowRate_act] = ...
    compute_flowAlongARouteSegment(timeOfComputation_pred, timeOfComputation_act, segment_startNode, segment_middleNode, segment_endNode, acSchedules, concurrencyIdentificationTimeLimit)

flowRate_pred = 0;
flowRate_act = 0;

all_callsigns = {acSchedules.callsign};
all_spots = [acSchedules.spotNodeNum];
all_optypes = {acSchedules.opType};

%% Find all flights passing through the segment in the correct direction

allFlightsUsingTaxiNode_indices = [];
for ii = 1:length(acSchedules)
    fltTaxiRoute = acSchedules(ii).taxiRoute;
    middleNodeIndex_in_route = find(fltTaxiRoute == segment_middleNode);
    if(~isempty(middleNodeIndex_in_route)) % Condition 1: flight passes through the segment_middleNode
        if((fltTaxiRoute(middleNodeIndex_in_route-1) == segment_startNode) && (fltTaxiRoute(middleNodeIndex_in_route+1) == segment_endNode)) % Condition 2: If the prior and next node are the correct ones in the correct direction
            pred_timeOfMiddleNodeCrossing = acSchedules(ii).nomSchTimes(middleNodeIndex_in_route);
            act_timeOfMiddleNodeCrossing = acSchedules(ii).actArrTimes(middleNodeIndex_in_route);
            
            if((pred_timeOfMiddleNodeCrossing >= timeOfComputation_pred - concurrencyIdentificationTimeLimit) && ...
                    (pred_timeOfMiddleNodeCrossing <= timeOfComputation_pred + concurrencyIdentificationTimeLimit)) % Condition 3: pred_spotXing time is within +/- concurrencyIdentificationTimeLimit of this flight's time
                flowRate_pred = flowRate_pred + 1;
            end
            
            if((act_timeOfMiddleNodeCrossing >= timeOfComputation_act - concurrencyIdentificationTimeLimit) && ...
                    (act_timeOfMiddleNodeCrossing <= timeOfComputation_act + concurrencyIdentificationTimeLimit)) % Condition 3: pred_spotXing time is within +/- concurrencyIdentificationTimeLimit of this flight's time
                flowRate_act = flowRate_act + 1;
            end
            
        end
    end        
end


return;




