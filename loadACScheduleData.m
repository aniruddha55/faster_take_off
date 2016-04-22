% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by: Aditya Saraf
% Date: April 2012
% Project: Surface Traffic Management NRA

% Purpose: This script reads in the ACScheduleData.txt file and puts it in
% the acSchedule data structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
SpotMasterList = find(~cellfun('isempty',(cellfun(@(x)strfind(x,'SPOT_NODE'),...
    {nodeLinkData.node_type},'UniformOutput',0))))-1;

%% Read ACScheduleData.txt file and Insert into MATLAB variables
%acScheduleDataFile = getInputFile( 'Select ACScheduleData.txt', '.txt' );
if( isempty(acScheduleDataFile) )
    return
end
[schedulerPath, ~, ~] = fileparts(acScheduleDataFile);
fid = fopen(acScheduleDataFile,'r');
acScheduleData = textscan(fid,'%s','delimiter',' ','headerlines',8);
acScheduleData = acScheduleData{1};
fclose(fid);
clear acScheduleDataFile fid

% Get rid of all empty cells
delIndices = find(cellfun('isempty',acScheduleData));
acScheduleData(delIndices) = [];
clear delIndices

% Find all the aircraft indices
acScheduleData=regexprep(acScheduleData,'@',''); % Use # or @ based on what delimiter is used in the latest file
acIndices=find(cellfun('isempty',acScheduleData));
acIndices(end+1) = length(acScheduleData)+1;

% Determine the number of entries between each AC ID entry
numOfEntriesArr = [acIndices(2:end)-acIndices(1:end-1)-3]/5;

% Initialize the acSchedule structure
acSchedules = struct(...
    'flightNum', [], ...
    'callsign', {}, ...
    'opType', {}, ...
    'acType', {}, ...
    'gateNodeNum', [], ...
    'spotNodeNum', [], ...
    'runway', {}, ...
    'taxiRoute', [], ...
    'nomSchTimes', [], ...
    'actArrTimes', [], ...
    'actRelTimes', [], ...
    'schRelTimes', [], ...
    'nominalRampTaxiTime', [], ...
    'nominalMovAreaTaxiTime', [], ...
    'nominalTotalTaxiTime', [], ...
    'actualRampTaxiTime', [], ...
    'actualMovAreaTaxiTime', [], ...
    'actualTotalTaxiTime', [], ...
    'delayAtGate', [], ...
    'delayInRamp', [], ...
    'delayInMovArea', [], ...
    'delayTotal', [], ...
    'acData', []);

acCallsignMasterList = cell(length(acIndices)-1,1);

%% MAIN LOOP: For each flight, update the respective acSchedule structure

% record count of arrivals and departures
numDep = 0; numArr = 0;
for ind = 1:length(acIndices)-1
    
    if find(1:50:(length(acIndices)-1) == ind)
        disp('Processing...')
    end
    
    clear acId callSign nodeVector nomSchTimeVector actArrTimeVector actRelTimeVector schRelTimeVector
    numOfEntries = numOfEntriesArr(ind);
    
    % Create vectors
    acId = str2double(acScheduleData(acIndices(ind)+1));
    callSign = acScheduleData{acIndices(ind)+2};
    nodeVector = acScheduleData(acIndices(ind)+3:5:acIndices(ind+1)-1);
    nomSchTimeVector = acScheduleData(acIndices(ind)+4:5:acIndices(ind+1)-1);
    actArrTimeVector = acScheduleData(acIndices(ind)+5:5:acIndices(ind+1)-1);
    actRelTimeVector = acScheduleData(acIndices(ind)+6:5:acIndices(ind+1)-1);
    schRelTimeVector = acScheduleData(acIndices(ind)+7:5:acIndices(ind+1)-1);
    
    % AC flight number
    acSchedules(ind,1).flightNum = acId;
    
    % AC callsign
    acSchedules(ind,1).callsign = callSign;
    acCallsignMasterList{ind} = callSign;
    
    % AC operation type
    firstNode = str2num(nodeVector{1});
    firstNodeType = nodeLinkData(firstNode+1).node_type;
    if(strcmp(firstNodeType,'ARRIVAL_NODE'))
        acOperationType = 'ARR';
    else
        acOperationType = 'DEP';
    end
    acSchedules(ind,1).opType = acOperationType;
    clear firstNode firstNodeType
    
    % AC Taxi Route
    nodeVector_numeric = zeros(size(nodeVector));
    for ii = 1:length(nodeVector)
        nodeVector_numeric(ii) = str2num(nodeVector{ii});
    end
    acSchedules(ind,1).taxiRoute = nodeVector_numeric;
    clear ii
    
    % AC Gate and Runway
    if(strcmp(acOperationType,'DEP') == 1)
        numDep = numDep + 1;
        departureGate = nodeVector_numeric(1);
        acSchedules(ind,1).gateNodeNum = departureGate;
        
        depNode = nodeVector_numeric(end);
        acSchedules(ind,1).runway = strtok(nodeLinkData(depNode+1).name,'_');
    else
        numArr = numArr +1;
        arrNode = nodeVector_numeric(1);
        acSchedules(ind,1).runway = strtok(nodeLinkData(arrNode+1).name,'_');
        
        if strcmp(acSchedules(ind,1).runway,'5')
            acSchedules(ind,1).runway = '23';
        end
        
        arrivalGate = nodeVector_numeric(end);
        acSchedules(ind,1).gateNodeNum = arrivalGate;
    end
    clear departureGate depNode arrNode arrivalGate
    
    % AC Spot
    [spotUsed, spotIndexInTaxiRoute] = intersect(nodeVector_numeric,SpotMasterList);
    acSchedules(ind,1).spotNodeNum = spotUsed(1);
    clear spotUsed
    
    % Nominal Schedule Times
    nomSchTimeVector_numeric = zeros(size(nomSchTimeVector));
    actArrTimeVector_numeric = zeros(size(nomSchTimeVector));
    actRelTimeVector_numeric = zeros(size(nomSchTimeVector));
    schRelTimeVector_numeric = zeros(size(nomSchTimeVector));
    for ii = 1:length(nomSchTimeVector)
        nomSchTimeVector_numeric(ii) = str2num(nomSchTimeVector{ii});
        actArrTimeVector_numeric(ii) = str2num(actArrTimeVector{ii});
        actRelTimeVector_numeric(ii) = str2num(actRelTimeVector{ii});
        schRelTimeVector_numeric(ii) = str2num(schRelTimeVector{ii});
    end
    clear ii
    acSchedules(ind,1).nomSchTimes = nomSchTimeVector_numeric;
    acSchedules(ind,1).actArrTimes = actArrTimeVector_numeric;
    acSchedules(ind,1).actRelTimes = actRelTimeVector_numeric;
    acSchedules(ind,1).schRelTimes = schRelTimeVector_numeric;
    
    % Collect Gate/Spot/Runway times, and compute nominal taxi time, actual
    % taxi time, and delay metrics
    if(strcmp(acOperationType,'DEP') == 1) % DEP
        nomSchTimeGate = nomSchTimeVector_numeric(1);
        actArrTimeGate = actArrTimeVector_numeric(1);
        actRelTimeGate = actRelTimeVector_numeric(1);
        
        nomSchTimeSpot = nomSchTimeVector_numeric(spotIndexInTaxiRoute(1));
        actArrTimeSpot = actArrTimeVector_numeric(spotIndexInTaxiRoute(1));
        actRelTimeSpot = actRelTimeVector_numeric(spotIndexInTaxiRoute(1));
        
        nomSchTimeRwy = nomSchTimeVector_numeric(end);
        actArrTimeRwy = actArrTimeVector_numeric(end);
        actRelTimeRwy = actRelTimeVector_numeric(end);
        
        % Compute Nominal Taxi Time
        acSchedules(ind,1).nominalRampTaxiTime = (nomSchTimeSpot - nomSchTimeGate)/60;
        acSchedules(ind,1).nominalMovAreaTaxiTime = (nomSchTimeRwy - nomSchTimeSpot)/60;
        acSchedules(ind,1).nominalTotalTaxiTime = (nomSchTimeRwy - nomSchTimeGate)/60;
        
        % Compute Actual Taxi Time
        acSchedules(ind,1).actualRampTaxiTime = (actRelTimeSpot - actRelTimeGate)/60;
        acSchedules(ind,1).actualMovAreaTaxiTime = (actRelTimeRwy - actRelTimeSpot)/60;
        acSchedules(ind,1).actualTotalTaxiTime = (actRelTimeRwy - actRelTimeGate)/60;
        
        % Compute Delay
        acSchedules(ind,1).delayAtGate = isZero((actRelTimeGate - actArrTimeGate)/60, 0.5/60);
        acSchedules(ind,1).delayInRamp = isZero(acSchedules(ind,1).actualRampTaxiTime - acSchedules(ind,1).nominalRampTaxiTime, 0.5/60);
        acSchedules(ind,1).delayInMovArea  = isZero(acSchedules(ind,1).actualMovAreaTaxiTime - acSchedules(ind,1).nominalMovAreaTaxiTime, 0.5/60);
        acSchedules(ind,1).delayTotal = isZero(acSchedules(ind,1).actualTotalTaxiTime - acSchedules(ind,1).nominalTotalTaxiTime + acSchedules(ind,1).delayAtGate, 0.5/60);
        
    else % ARR
        nomSchTimeGate = nomSchTimeVector_numeric(end);
        actArrTimeGate = actArrTimeVector_numeric(end);
        actRelTimeGate = actRelTimeVector_numeric(end);
        
        nomSchTimeSpot = nomSchTimeVector_numeric(spotIndexInTaxiRoute(1));
        actArrTimeSpot = actArrTimeVector_numeric(spotIndexInTaxiRoute(1));
        actRelTimeSpot = actRelTimeVector_numeric(spotIndexInTaxiRoute(1));
        
        nomSchTimeRwy = nomSchTimeVector_numeric(1);
        % For arrivals, arrTime is at the upstream node but release is
        % from runway node, so assign the same number to both
        actArrTimeRwy = actRelTimeVector_numeric(1);
        actRelTimeRwy = actRelTimeVector_numeric(1);
        
        % Compute Nominal Taxi Time
        acSchedules(ind,1).nominalRampTaxiTime = (nomSchTimeGate - nomSchTimeSpot)/60;
        acSchedules(ind,1).nominalMovAreaTaxiTime = (nomSchTimeSpot - nomSchTimeRwy)/60;
        acSchedules(ind,1).nominalTotalTaxiTime = (nomSchTimeGate - nomSchTimeRwy)/60;
        
        % Compute Actual Taxi Time
        acSchedules(ind,1).actualRampTaxiTime = (actArrTimeGate - actArrTimeSpot)/60;
        acSchedules(ind,1).actualMovAreaTaxiTime = (actArrTimeSpot - actArrTimeRwy)/60;
        acSchedules(ind,1).actualTotalTaxiTime = (actArrTimeGate - actArrTimeRwy)/60;
        
        % Compute Delay
        acSchedules(ind,1).delayAtGate = isZero((actRelTimeGate - actArrTimeGate)/60, 0.5/60);
        acSchedules(ind,1).delayInRamp = isZero(acSchedules(ind,1).actualRampTaxiTime - acSchedules(ind,1).nominalRampTaxiTime, 0.5/60);
        acSchedules(ind,1).delayInMovArea = isZero(acSchedules(ind,1).actualMovAreaTaxiTime - acSchedules(ind,1).nominalMovAreaTaxiTime, 0.5/60);
        acSchedules(ind,1).delayTotal = isZero(acSchedules(ind,1).actualTotalTaxiTime - acSchedules(ind,1).nominalTotalTaxiTime + acSchedules(ind,1).delayAtGate, 0.5/60);
    end
    clear acOperationType spotIndexInTaxiRoute
    clear nomSchTimeGate actArrTimeGate actRelTimeGate
    clear nomSchTimeSpot actArrTimeSpot actRelTimeSpot
    clear nomSchTimeRwy actArrTimeRwy actRelTimeRwy
    
end
clear ind SpotMasterList acScheduleData numOfEntries numOfEntriesArr acIndices
clear acIdVector callSignVector nodeVector nomSchTimeVector actArrTimeVector actRelTimeVector schRelTimeVector
clear nodeVector_numeric nomSchTimeVector_numeric actArrTimeVector_numeric actRelTimeVector_numeric schRelTimeVector_numeric

totalNbrOfFlights = length(acSchedules);

disp('Done!')