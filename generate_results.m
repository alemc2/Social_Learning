function restruct = generate_results(result_dir,mapping)
%Function to generate results as an array of structs which can be stored as
%csv if needed.
%result_dir is the directory where results are located
%mapping is a nx3 cell where n is the number of experiments run and the 1st
%column is the learning mat file, 2nd column is the test mat file and the
%third column is a boolean indicating if its a social learning round.

%If mapping not provided thought I can scan directory but no matching
%between social and non-social. So not doing it.
% if nargin < 2
%     
% end

restruct = [];

num_experiments = size(mapping,1);
for i=1:num_experiments
    individual_restruct = PresentLearning([result_dir,filesep,mapping{i,1}],[result_dir,filesep,mapping{i,2}],mapping{i,3},true,true);
    restruct = [restruct;individual_restruct];
end
end