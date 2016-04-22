function pgm_input = convert_table_of_factors_to_pgm_input(tableOfFactors_data)

% Apparently, gate data may be repeated, so here a set of 
% unique is pulled out of the data. So, for instance, in one example, there
% are 8491 instances down to 7. -- MEP
[uniq_gates, ~, indexb] = unique(tableOfFactors_data.gate);

% I would appear that each spot has multiple gates and of course, multiple
% runways.



% [C,IA,IC] = unique(A) also returns index vectors IA and IC such that
% C = A(IA) and A = C(IC) (or A(:) = C(IC), if A is a matrix or array).
% Not sure the point of the indexb variable.  -- MEP  

PGM_Engines.gates = uniq_gates;  % Don't know what PGM_Engines are  -- MEP
pgm_input(1,:) = indexb;         % pgm_input stores the index of the unique
                                 % vector that recreates the original 
                                 % tableOfFactors_data...

% So, here we do the same here with spots
[uniq_spots, ~, indexb] = unique(tableOfFactors_data.spot);
PGM_Engines.spots = uniq_spots;
pgm_input(2,:) = indexb;


pushbacktimes = tableOfFactors_data.actPushbackTime;

% No idea what these variables do  -- MEP
tableOfFactors_data.act_floRateG003_depDir = tableOfFactors_data.pred_floRateG003_depDir;
tableOfFactors_data.act_floRateB034_depDir = tableOfFactors_data.act_floRateG003_depDir;
% tableOfFactors_data.actMergeNodeArrTime = round(tableOfFactors_data.actMergeNodeArrTime/60);

% It appears that these pgm inputs are all delta times from the pushback
% time -- MEP
pgm_input(3,:) = tableOfFactors_data.actPushbackTime - pushbacktimes;
pgm_input(4,:) = tableOfFactors_data.actSpotArrTime  - pushbacktimes;
pgm_input(5,:) = tableOfFactors_data.actSpotRelTime  - pushbacktimes;
pgm_input(6,:) = tableOfFactors_data.actRwyRelTime   - pushbacktimes;
pgm_input(7,:) = tableOfFactors_data.act_concurrentGateReleases;
pgm_input(8,:) = tableOfFactors_data.act_concurrentSpotInflux;
pgm_input(9,:) = tableOfFactors_data.act_spotPassagesInDepDir;
pgm_input(10,:) = tableOfFactors_data.actMergeNodeArrTime - pushbacktimes;
pgm_input(11,:) = tableOfFactors_data.act_floRateF010_depDir;
pgm_input(12,:) = tableOfFactors_data.act_floRateG003_depDir;
pgm_input(13,:) = tableOfFactors_data.act_floRateB034_depDir;
pgm_input(14,:) = tableOfFactors_data.act_depQueueSizeAtMergeNodeArrTime;


% DELETE ME: ANIRUDDHA
% pgm_input(6,:) = randi(3,size(pgm_input(6,:)))+10;
% pgm_input(6,:) = pgm_input(6,:)*0 + 10;
% pgm_input(10,:) = pgm_input(10,:)*0 + 9;
% pgm_input(4,:) = pgm_input(4,:)*0 + 8;


% NOTE: treating all the nodes as categorical variables. So, making values
% in pgm_input non-zero should not affect the results.
pgm_input = pgm_input + 1;  % Somewhat bizarre, but this adds a '1' to 
                            % every entry in this matrix. -- MEP

%  If 'temp_analysis' is turned off we get this error  ---                          
%  ------
%  Error using eval
%  Undefined function or variable 'unique_evidence_str_spot_F_010'.
% 
%  Error in sampleErlstSpotTime (line 32)
%  eval(['unique_evidence_str_spot = unique_evidence_str_spot_', thisDep_spot, ';']); % Then, select the correct unique evidence data based
%  on the spot
%  ------                           
%
%  temp_analysis is advertised as a post-process analysis tool, but it is
%  necessary to eliminate this error  --MEP

% CMU Folks -- I commented out the following line.  It is not needed
% to compute the input for PGM training.  But is needed to run the
% rest of PROCAST. -- Matt Stillerman

 %temp_analysis;    % Needs to be on for this to run.  -- MEP
                   % temp analysis creates the 'unique_evidence_str_spot'
                   % series of variables.  See the eval statements at the
                   % end. 
                   
% 
% disp('unique(pgm_input(1,:))')
% unique(pgm_input(1,:))
% 
% disp('unique(pgm_input(4,:))')
% unique(pgm_input(4,:))
% disp('unique(pgm_input(9,:))')
% unique(pgm_input(9,:))
% 
% disp('unique(pgm_input(11,:))')
% unique(pgm_input(11,:))
% 
% disp('unique(pgm_input(12,:))')
% unique(pgm_input(12,:))


                   
end