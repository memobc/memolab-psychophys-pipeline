function [modelfiles] = pspm_specify(behav_data_dir, curSubj, Analysis, RE)

global verbose

% Kyles Note:
% Use spm_select function to grab the MICE behavioral data making the
% following assumptions:
%
% 1.) The behavioral data are labeled in such a way as to make filenames 
%     sort in order of round
% 2.) The only .*.csv files that are in the behav_data_dir are the
%     behavioral data files

behav_data_files = kyles_spm_select('FPList', behav_data_dir, [RE '.*\.csv']);

switch Analysis.name
    
    case 'Emotional_vs_Neutral_Trials'
        numTrialTypes    = 2;
    case 'WhiteNoise_vs_AllOther'
        numTrialTypes    = 2;
    case 'Valence_and_Noise'
        numTrialTypes    = 4;
end
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
            
            case 'Emotional_vs_Neutral_Trials'
        
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
                
            case 'WhiteNoise_vs_AllOther'
        
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
                
            case 'Valence_and_Noise'
                
                if ~isempty(regexp(data.Condition{curTrial}, 'neg', 'ONCE')) && data.Noise(curTrial) == 1

                    trial_type_id = 1;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'WhiteNoise';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0;

                elseif ~isempty(regexp(data.Condition{curTrial}, 'neg', 'ONCE')) && data.Noise(curTrial) ~= 1

                    trial_type_id = 2;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'Negative_Trials';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0; 
                    
                elseif ~isempty(regexp(data.Condition{curTrial}, 'neu', 'ONCE')) && data.Noise(curTrial) == 3

                    trial_type_id = 3;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'NeutralTone';
                    onsets{trial_type_id}(counter(trial_type_id))    = data.onset(curTrial); 
                    durations{trial_type_id}(counter(trial_type_id)) = 0; 
                    
                elseif ~isempty(regexp(data.Condition{curTrial}, 'neu', 'ONCE')) && data.Noise(curTrial) ~= 1

                    trial_type_id = 4;
                    counter(trial_type_id)                           = counter(trial_type_id) + 1;
                    names{trial_type_id}                             = 'Neutral_Trials';
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
    
    save(fullfile(Analysis.dir, curSubj, ['round' num2str(round, '%02d') '_multiple_conditions.mat']), 'names', 'onsets', 'durations')            

end

modelfiles = kyles_spm_select('FPList', fullfile(Analysis.dir, curSubj), '^round.*\.mat');

end