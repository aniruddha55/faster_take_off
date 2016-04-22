function new_node_sizes = increase_node_sizes(old_node_sizes,tof)
add_global_variables;

pgm_input = convert_table_of_factors_to_pgm_input(tof);
node_sizes = max(pgm_input') + 1;

new_node_sizes = max(old_node_sizes, node_sizes);

old_node_sizes
new_node_sizes
end