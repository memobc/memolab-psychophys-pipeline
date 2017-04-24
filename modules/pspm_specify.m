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

behav_data_files = kyles_spm_select('FPList', behav_data_dir, '.*round0[0-4].*\.csv');

numTrialTypes    = 2;
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
        
        switch Analysis.name
            
            case 'EmoTrials_vs_NeuTrials_Model'
        
                if regexp(data.Condition{curTrial}, 'neut', 'ONCE')

                    trial_type_id = 1;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'Neutral_Trials';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0;

                elseif regexp(data.Condition{curTrial}, 'neg', 'ONCE')

                    trial_type_id = 2;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'Negative_Trials';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0;     

                end
                
            case 'WhiteNoiseTrials_vs_AllOtherTrials_Model'
        
                if data.Noise(curTrial) == 1

                    trial_type_id = 1;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'WhiteNoise_Trials';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0;

                else

                    trial_type_id = 2;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'AllOther_Trials';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0;     

                end                
                
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

modelfiles = kyles_spm_select('FPList', fullfile(Analysis.dir, curSubj), '^Round.*\.mat');

end