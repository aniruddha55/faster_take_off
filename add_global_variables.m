
global node_sizes_spots;

num_nodes_in_BN = 14;

tstart = 1;
tend = 8*60*60; % Six hours, converted to seconds
timeBin_size = 30; % seconds

% Define the nodes
gate = 1;
spot = 2;
actPushbackTime=3;
actSpotArrTime=4;
actSpotRelTime=5;
actRwyRelTime=6;
actConcurrentGateReleases=7;
actConcurrentSpotInflux=8;
actSpotPassagesInDepDir=9;
actMergeNodeArrTime=10;
actFloRateF010_depDir=11;
actFloRateG003_depDir=12;
actFloRateB034_depDir=13;
actDepQueueSizeAtMergeNodeArrTime=14;

