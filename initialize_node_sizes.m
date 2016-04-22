
function node_sizes_spots = initialize_node_sizes(all_dep_spots)

add_global_variables;
num_spots = numel(all_dep_spots);
node_sizes_spots = containers.Map(all_dep_spots, ...
    eval(['{' repmat('zeros(1,num_nodes_in_BN),',1,num_spots-1) ...
    'zeros(1,num_nodes_in_BN)}']));

end