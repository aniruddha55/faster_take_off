% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by: Aditya Saraf
% Date: April 2012
% Project: Surface Traffic Management NRA

% Purpose: This function computes the predicted and actual number of spot
% crossings by arrivals into the same gate-area as the subject departure
% flight around the departure flight's predicted/actual pushback time. This
% function will be used by  PGM-building scripts to   compute the data
% required for one conditioning random variable. This script is called from
% the processData_and_updateTableOfFactors.m script 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pred_concurrentSpotInflux, act_concurrentSpotInflux] = compute_concurrentSpotInflux(thisFlight_callsign, acSchedules, concurrencyIdentificationTimeLimit)

pred_concurrentSpotInflux = 0;
act_concurrentSpotInflux = 0;

all_callsigns = {acSchedules.callsign};
all_spots = [acSchedules.spotNodeNum];
all_optypes = {acSchedules.opType};


%% Find flights that pushed back from the same terminal-gate area (i.e., used the same spot)
thisFlight_index = strmatch(thisFlight_callsign, all_callsigns, 'exact');
thisFlight_gate = acSchedules(thisFlight_index).gateNodeNum;
thisFlight_spot = acSchedules(thisFlight_index).spotNodeNum;

allFlightsUsingSameSpot_indices = find(all_spots == thisFlight_spot);
allArrIndices = strmatch('ARR', all_optypes, 'exact');
allArrsUsingSameSpot_indices = intersect(allFlightsUsingSameSpot_indices, allArrIndices);


%% Now find how many of these flights were predicted to pushback around the predicted/actual time of pushback of this flight
predSpotCrossingTimes = zeros(length(allArrsUsingSameSpot_indices),1);
actSpotCrossingTimes = zeros(length(allArrsUsingSameSpot_indices),1);
for ii = 1:length(allArrsUsingSameSpot_indices)
    flt_index = allArrsUsingSameSpot_indices(ii);    
    spotNodeNum = acSchedules(flt_index).spotNodeNum;
    spotIndexInRoute = find(acSchedules(flt_index).taxiRoute == spotNodeNum);
    
    predSpotCrossingTimes(ii) = acSchedules(flt_index).nomSchTimes(spotIndexInRoute);
    actSpotCrossingTimes(ii) = acSchedules(flt_index).actRelTimes(spotIndexInRoute);
end

thisFlight_predGateReleaseTime = acSchedules(thisFlight_index).nomSchTimes(1);
temp1 = find(predSpotCrossingTimes >= (thisFlight_predGateReleaseTime - concurrencyIdentificationTimeLimit));
temp2 = find(predSpotCrossingTimes <= (thisFlight_predGateReleaseTime + concurrencyIdentificationTimeLimit));
pred_concurrentSpotInflux = length(intersect(temp1,temp2));

thisFlight_actGateReleaseTime = acSchedules(thisFlight_index).actRelTimes(1);
temp1 = find(actSpotCrossingTimes >= (thisFlight_actGateReleaseTime - concurrencyIdentificationTimeLimit));
temp2 = find(actSpotCrossingTimes <= (thisFlight_actGateReleaseTime + concurrencyIdentificationTimeLimit));
act_concurrentSpotInflux = length(intersect(temp1,temp2));

return;




