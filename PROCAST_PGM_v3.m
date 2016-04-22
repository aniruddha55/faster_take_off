% PGM for PROCAST tool
% 
% 
% 19 Mar 2014, Kris R and Aditya S, Saab Sensis STC
% ---------------------------------------------------------------
function [engine] = PROCAST_PGM_v3(pgm_input, spot_of_interest)

add_global_variables;

% Define an adjacency matrix which represents the Bayes network graph
N = 14; 
dag = zeros(N,N);

% Define the node-connections
dag(gate, actSpotArrTime) = 1;
dag(actPushbackTime, actSpotArrTime) = 1;
dag(spot, actSpotArrTime) = 1;
dag(actConcurrentGateReleases, actSpotArrTime) = 1;
dag(actConcurrentSpotInflux, actSpotArrTime) = 1;
dag(actSpotArrTime, actSpotRelTime) = 1;
dag(actSpotPassagesInDepDir, actSpotRelTime) = 1;
dag(actSpotPassagesInDepDir, actMergeNodeArrTime) = 1;
dag(actSpotRelTime, actMergeNodeArrTime) = 1;
dag(actFloRateF010_depDir, actMergeNodeArrTime) = 1;
dag(actFloRateG003_depDir, actMergeNodeArrTime) = 1;
dag(actMergeNodeArrTime, actRwyRelTime) = 1;
dag(actFloRateB034_depDir, actRwyRelTime) = 1;
dag(actDepQueueSizeAtMergeNodeArrTime, actRwyRelTime) = 1;

% Build the nodes and node-sizes
discrete_nodes = 1:N;
node_sizes = max(pgm_input')+1;
% node_sizes = range(pgm_input')+1;

node_sizes = node_sizes_spots(spot_of_interest);

node_sizes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%disp('--------------------------');
node_sizes(actSpotArrTime);
min(pgm_input(actSpotArrTime,:));

node_sizes(actMergeNodeArrTime);
min(pgm_input(actMergeNodeArrTime,:));

node_sizes(actRwyRelTime);
min(pgm_input(actRwyRelTime,:));
%disp('--------------------------');

% Create a BayesNet shell
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes);

% Obtain sample data
samples = pgm_input;

for k = 1:N
    bnet.CPD{k} = tabular_CPD(bnet, k);
end

[bnet] = learn_params(bnet, samples);

% for k = 1:N
%     bnet.CPD{k}
%     get_field(bnet.CPD{k},'cpt')
% end
% Inference - To perform inference, first create an inference engine
% (algorithm that will be used to perform inference). Junction tree seems
% the popular for exact inference.
engine = jtree_inf_engine(bnet);
eval([sprintf(['engine_', spot_of_interest]) '=engine']);

%cd([svn_root_directory, '/trunk/PGMs/Model/Output/'])
% save PGMEngine.mat bnet engine;
% eval(['save engine_', spot_of_interest, '.mat bnet engine_', spot_of_interest]);
%cd([svn_root_directory, '/trunk/PGMs/Model/'])



























