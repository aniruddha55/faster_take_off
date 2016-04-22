function [nodeLinkData, aircraftTypes] = load_static_data(data_path)

% Load nodeLinkData
disp('Loading nodeLinkData.mat...')

nodeLinkData_filename = [data_path, '/nodeLinkData_JFK.mat'];
if( isempty(nodeLinkData_filename) )
    return
else
    load(nodeLinkData_filename)
end


% Load aircraft types database
disp('Loading aircraftTypes.mat...')
% aircraftTypes_filename = getInputFile( 'Select aircraftTypes.mat', '.mat' );
aircraftTypes_filename = [data_path, '/aircraftTypes.mat'];

if( isempty(aircraftTypes_filename) )
    return
else
    load(aircraftTypes_filename)
end

end