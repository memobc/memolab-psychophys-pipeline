function [modelfiles] = pspm_specify(behav_data_dir, curSubj, Analysis)

global verbose

% Kyles Note:
% Use spm_select function to grab the MICE behavioral data making the
% following assumptions:
%
% 1.) The behavioral data are labeled in such a way as to make filenames 
%     sort in order of round
% 2.) The only .*.csv files that are in the behav_data_dir are the
%     behavioral data files

pspmdir = which('pspm');
[path, ~, ~] = fileparts(pspmdir);

addpath(fullfile(path, 'SPM'))
behav_data_files = cellstr(spm_select('FPList', behav_data_dir, '.*\.csv'));
rmpath(fullfile(path, 'SPM'))

numTrialTypes    = 4;
round            = 0;

for curDataFile = behav_data_files'
    
    round = round + 1;
    
    if verbose
        fprintf('\nReading in %s...\n', curDataFile{:})
    end
    
    % read in behav data
    data = readtable(curDataFile{:});
    
    %%%%%%% sort the behavioral data into trial types
    
    % initalize
    counter   = zeros(numTrialTypes, 1);
    names     = cell(numTrialTypes, 1);
    onsets    = cell(numTrialTypes, 1);
    durations = cell(numTrialTypes, 1);
    
    if verbose
        fprintf('\nSorting trials...\n')
    end
    
    % for each trial...
    for curTrial = 1:height(data)
        
        if strcmp(data.Condition{curTrial}, 'neut/same')
            
            trial_type_id = 1;
            counter(trial_type_id)                           = counter(trial_type_id) + 1;
            names{trial_type_id}                             = 'neut-same';
            onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
            durations{trial_type_id}(counter(trial_type_id)) = 0;
            
        elseif strcmp(data.Condition{curTrial}, 'neut/shift')
            
            trial_type_id = 2;
            counter(trial_type_id)                           = counter(trial_type_id) + 1;
            names{trial_type_id}                             = 'neut-shift';
            onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
            durations{trial_type_id}(counter(trial_type_id)) = 0;     
            
        elseif strcmp(data.Condition{curTrial}, 'neg/same')
            
            trial_type_id = 3;
            counter(trial_type_id)                           = counter(trial_type_id) + 1;
            names{trial_type_id}                             = 'neg-same';
            onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
            durations{trial_type_id}(counter(trial_type_id)) = 0;   
            
        elseif strcmp(data.Condition{curTrial}, 'neg/shift')
            
            trial_type_id = 4;
            counter(trial_type_id)                           = counter(trial_type_id) + 1;
            names{trial_type_id}                             = 'neg-shift';
            onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
            durations{trial_type_id}(counter(trial_type_id)) = 0;  
            
        end
        
    end
    
    % write multiple conditions file
    if verbose
        fprintf('\nWriting Multiple Conditions File ...\n')
    end

    if ~exist(fullfile(Analysis.dir, curSubj), 'dir')
        mkdir(Analysis.dir, curSubj)
    end    
    
    save(fullfile(Analysis.dir, curSubj, ['Round' num2str(round) '_multiple_conditions.mat']), 'names', 'onsets', 'durations')            

end

addpath(fullfile(path, 'SPM'))
modelfiles = cellstr(spm_select('FPList', fullfile(Analysis.dir, curSubj), '^Round.*\.mat'));

end