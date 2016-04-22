% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by: Aditya Saraf
% Date: April 2012
% Project: Surface Traffic Management NRA

% Purpose: This function computes the predicted and actual number of gate
% releases from the same gate-area in X minutes prior to the actual gate
% release time This function will be used by  PGM-building scripts to
% compute the data required for one conditioning random variable. This
% script is called from the processData_and_updateTableOfFactors.m script
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pred_concurrentGateReleases, act_concurrentGateReleases] = compute_nbrOfConcurrentGateReleases(thisFlight_callsign, acSchedules, concurrencyIdentificationTimeLimit)

pred_concurrentGateReleases = 0;
act_concurrentGateReleases = 0;

all_callsigns = {acSchedules.callsign};
all_spots = [acSchedules.spotNodeNum];
all_optypes = {acSchedules.opType};


%% Find flights that pushed back from the same terminal-gate area (i.e., used the same spot)
thisFlight_index = strmatch(thisFlight_callsign, all_callsigns, 'exact');
thisFlight_gate = acSchedules(thisFlight_index).gateNodeNum;
thisFlight_spot = acSchedules(thisFlight_index).spotNodeNum;

allFlightsUsingSameSpot_indices = find(all_spots == thisFlight_spot);
allDepIndices = strmatch('DEP', all_optypes, 'exact');
allDepsUsingSameSpot_indices = intersect(allFlightsUsingSameSpot_indices, allDepIndices);

allDepsUsingSameSpot_indices = setdiff(allDepsUsingSameSpot_indices, thisFlight_index);

%% Now find how many of these flights were predicted to pushback around the predicted/actual time of pushback of this flight
predPushbackTimes = zeros(length(allDepsUsingSameSpot_indices),1);
actPushbackTimes = zeros(length(allDepsUsingSameSpot_indices),1);
for ii = 1:length(allDepsUsingSameSpot_indices)
    predPushbackTimes(ii) = acSchedules(allDepsUsingSameSpot_indices(ii)).nomSchTimes(1);
    actPushbackTimes(ii) = acSchedules(allDepsUsingSameSpot_indices(ii)).actRelTimes(1);
end

thisFlight_predGateReleaseTime = acSchedules(thisFlight_index).nomSchTimes(1);
temp1 = find(predPushbackTimes >= (thisFlight_predGateReleaseTime - concurrencyIdentificationTimeLimit));
temp2 = find(predPushbackTimes <= (thisFlight_predGateReleaseTime + concurrencyIdentificationTimeLimit));
pred_concurrentGateReleases = length(intersect(temp1,temp2));

thisFlight_actGateReleaseTime = acSchedules(thisFlight_index).actRelTimes(1);
temp1 = find(actPushbackTimes >= (thisFlight_actGateReleaseTime - concurrencyIdentificationTimeLimit));
temp2 = find(actPushbackTimes <= (thisFlight_actGateReleaseTime + concurrencyIdentificationTimeLimit));
act_concurrentGateReleases = length(intersect(temp1,temp2));

return;




