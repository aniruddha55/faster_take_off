% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by: Aditya Saraf
% Date: April, 2014
% Project: NASA LEARN MDO project - Year 1

% Purpose: This function computes the time-bin number given a time (in
% seconds) and the corresponding time-bin start and end times ( also in
% seconds)
%%%%%%%%%%%%%%%%%%%%%%%%%%%


function timeBin_number = calculateTimeBinNbr(time_in_seconds, timeBin_startTimes, timeBin_endTimes)

% % NO BINNING
timeBin_number = time_in_seconds;
return;

if(time_in_seconds == 0)
    timeBin_number = 1;
    return;
end

t1 = find(timeBin_startTimes <= time_in_seconds);
timeBin_number = t1(end);

return;