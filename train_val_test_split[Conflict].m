function train_val_test_split(data_directory, input_dir)
% Randomly shuffles the files and copies the partitioned files 
% into three separate directories train-{timestamp}, test-{timestamp} 
% and val-{timestamp}

if ~exist('data_directory', 'var')
    data_directory = '~/Google Drive/NASA-ATC/procast/eval_framework/data';
    if ispc
        data_directory = '\data';
    end
end
if ~exist('input_dir', 'var')
    input_dir = [data_directory  '/acschedules-txt-10-temp'];
    if ispc
        data_directory = '\acschedules-txt-10-temp';
    end
end

d = dir(strcat(input_dir,'/*.txt'));
if ispc
        d = dir(strcat(input_dir,'\*.txt'));
end
fileNames = {d.name};
n = numel(fileNames);

shuffleidx = randperm(length(fileNames));

% Divide files in train:val:test ratio (3:1:1)
len_train = floor(3/5*n);
len_val = floor(1/5*n);
len_train = 2;
len_val = 2;

s = datestr(datetime('now'));

mkdir(data_directory, strcat('train-',s))
mkdir(data_directory, strcat('val-',s)) 
mkdir(data_directory, strcat('test-',s)) 

train_dir = strcat(data_directory, strcat('/train-',s));
val_dir = strcat(data_directory, strcat('/val-',s));
test_dir = strcat(data_directory, strcat('/test-',s));
if ispc
    train_dir = strcat(data_directory, strcat('\train-',s));
    val_dir = strcat(data_directory, strcat('\val-',s));
    test_dir = strcat(data_directory, strcat('\test-',s));
end

for K = 1 : length(shuffleidx)
  thisfile = fileNames{shuffleidx(K)}
  
  if K < len_train
      dest_dir = train_dir
      
  elseif K >= len_train && K < len_val + len_train
      dest_dir = val_dir
  
  else
      dest_dir = test_dir
  end
  
  copyfile([input_dir '/' thisfile], dest_dir);
end

% for each set loadACSchedule and prepare tableOfFactors
create_table_of_factors(train_dir, 'train', data_directory);
create_table_of_factors(val_dir, 'val', data_directory);
create_table_of_factors(test_dir, 'test', data_directory);

end

