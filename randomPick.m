function randomChoice = randomPick(pmf_binCenters, pmf_binProbabs)

cmf_binProbabs = zeros(size(pmf_binProbabs));
cmf_binProbabs(1) = pmf_binProbabs(1);

for ii = 2:length(pmf_binProbabs)
    cmf_binProbabs(ii) = cmf_binProbabs(ii-1)+ pmf_binProbabs(ii);
end

x = rand(1);
index1 = find(cmf_binProbabs > x);


randomChoice = pmf_binCenters(index1(1));






% % TEST CODE:
% x = [1 2 3 4];
% prob_x = [0.4 0 0.01 0.59];
% num_samples = 1e3;
% y = zeros(1, num_samples);
% for i = 1:num_samples
%     y(i) = randomPick(x, prob_x);
% end
% hist(y); grid on;