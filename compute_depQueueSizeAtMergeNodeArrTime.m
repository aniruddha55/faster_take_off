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

function [pred_depQueueSizeAtMergeNodeArrTime, act_depQueueSizeAtMergeNodeArrTime] = ...
    compute_depQueueSizeAtMergeNodeArrTime(thisFlight_callsign, acSchedules, concurrencyIdentificationTimeLimit, mergeNodeNum)

alternate_mergeNodeNum = 112;

pred_depQueueSizeAtMergeNodeArrTime = 0;
act_depQueueSizeAtMergeNodeArrTime = 0;

all_callsigns = {acSchedules.callsign};
all_optypes = {acSchedules.opType};


%% Get thisFlight's taxi route and times (ownship prediction)
thisFlight_index = strmatch(thisFlight_callsign, all_callsigns, 'exact');
index_of_mergeNode_in_taxiRoute = find(acSchedules(thisFlight_index).taxiRoute == mergeNodeNum);
if(isempty(index_of_mergeNode_in_taxiRoute))
    index_of_mergeNode_in_taxiRoute = find(acSchedules(thisFlight_index).taxiRoute == alternate_mergeNodeNum);
end
thisFlight_predTimeAtMergeNode = acSchedules(thisFlight_index).nomSchTimes(index_of_mergeNode_in_taxiRoute);
thisFlight_actTimeAtMergeNode = acSchedules(thisFlight_index).actArrTimes(index_of_mergeNode_in_taxiRoute);

%% FOR each other departure flight find if it has crossed the merge node but not taken off at the time when the ownship reaches the merge node. This defines the queue length

depIndices = strmatch('DEP', all_optypes, 'exact');

for dep_cter = 1:length(depIndices)
    otherFlight_index = depIndices(dep_cter); % otherFlight_index can be interchangeably used for acSchedules and acStateHistory because both contain flights in the same order
    otherFlight_callsign = all_callsigns(otherFlight_index);
    
    if(strcmp(otherFlight_callsign, thisFlight_callsign) ~= 1) % Only check for flights other than ownship                   
        index_of_mergeNode_in_taxiRoute = find(acSchedules(otherFlight_index).taxiRoute == mergeNodeNum);
        if(isempty(index_of_mergeNode_in_taxiRoute))
            alternativeMergeNodeNum = 112;
            index_of_mergeNode_in_taxiRoute = find(acSchedules(otherFlight_index).taxiRoute == alternativeMergeNodeNum);
        end
        
        otherFlight_predTimeAtMergeNode = acSchedules(otherFlight_index).nomSchTimes(index_of_mergeNode_in_taxiRoute);
        otherFlight_actTimeAtMergeNode = acSchedules(otherFlight_index).actArrTimes(index_of_mergeNode_in_taxiRoute);
        
        otherFlight_predRwyReleaseTime = acSchedules(otherFlight_index).nomSchTimes(end);
        otherFlight_actRwyReleaseTime = acSchedules(otherFlight_index).actRelTimes(end);
        
        % If the other flight has crossed the merge node earlier than
        % this flight, AND the other flight has not taken off prior to this
        % flight's merge node crossing node, then count this flight in
        % the departure queue 
        if((otherFlight_predTimeAtMergeNode < thisFlight_predTimeAtMergeNode) && (otherFlight_predRwyReleaseTime > thisFlight_predTimeAtMergeNode))
            pred_depQueueSizeAtMergeNodeArrTime = pred_depQueueSizeAtMergeNodeArrTime + 1;
        end
        
        if((otherFlight_actTimeAtMergeNode < thisFlight_actTimeAtMergeNode) && (otherFlight_actRwyReleaseTime > thisFlight_actTimeAtMergeNode))
            act_depQueueSizeAtMergeNodeArrTime = act_depQueueSizeAtMergeNodeArrTime + 1;
        end
    end
end  



return;




