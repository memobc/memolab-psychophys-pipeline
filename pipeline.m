%==========================================================================
%                   The MemoLab Psychophys Pipeline
%==========================================================================
% Welcome to the MemoLab's Psychophys Pipeline
% Written by Kyle Kurkela, kyleakurkela@gmail.com
% April-October 2017

%%
%==========================================================================
%                   Study Specific Parameters
%==========================================================================
% Define study and computer specific parameters

% Where does the data live on your computer?
rootdir  = '/Volumes/memolab/MICE/MICE_fMRI/data/';

% Subjects structure, with the fields:
%   .flag   = true if you want to grab subject IDs dynamically using a 
%             regular expression, false if you want to hardcode subject ids
%             into the .ids field. The regular expression method can be
%             useful if you simply want to run all available subjects and 
%             do not want to have to hardcode them all into the .ids field.
%   .ids    = a 1 x n cell array of subject ids strings to run. Note, when
%             running with the .flag field set to true, this field gets
%             overwritten with the id's identified using the regular
%             expression.
%   .regexp = a regular expression, used to grab subjects ids dynamically
Subjects.flag   = true;
Subjects.ids    = {'sub-s001','sub-s002','sub-s003','sub-s004','sub-s005',...
                   'sub-s006','sub-s007','sub-s008','sub-s009','sub-s010',...
                   'sub-s011','sub-s012','sub-s013','sub-s014','sub-s015',...
                   'sub-s016','sub-s017','sub-s018','sub-s019','sub-s020',...
                   'sub-s021','sub-s022','sub-s023','sub-s024','sub-s025',...
                   'sub-s026','sub-s027','sub-s028','sub-s029','sub-s030'...
                   'sub-s031'};
Subjects.regexp = '^sub-s0(?!02|15|18|21|23|24|25|29|31)'; % excludes subjects 2,15,18,21,23,24,25,29,31

% A 1 x n cell array of the different tasks to analyze (e.g., encoding,
% item retrieval, emotion retrieval). The scripts searches the functional
% run file names for this identifier. For example:
%
%   /sub01_round01_enc.txt
%   /sub01_round01_ret.txt
%
% The Task cell array should contain the identifier 'enc' for the Encoding
% task.
Tasks         = {'enc'};

% Rounds structure, with the fields:
%   .flag   = true if you want to grab round IDs dynamically using a 
%             regular expression, false if you want to hardcode round ids
%             into the .ids field. The regular expression method is useful
%             when you have subjects that have a different number of runs
%             for a particular task. Hardcoding the round IDs makes the
%             assumption that ALL subjects have those rounds, which may or
%             may not always be true.
%   .ids    = a 1 x n cell array of strings detailing the names of the
%             rounds
%   .regexp = a regular expression, used to dynamically figure out round
%             IDs from the biophys filenames. Google regular expressions,
%             see spm_select's filter option
Rounds.flag   = true;
Rounds.ids    = {'round01','round02','round03','round04','round05'...
                 'round06'};
Rounds.regexp = 'round0[^7]'; % grab all available runs EXCEPT round07

% Analysis structure, with the fileds:
%   .root = the root directory where this analysis will be saved
%   .name = name of the current analysis. A subfolder will be created
%           within .root with this name. The model .mat file will also have
%           this name.
%   .dir  = the directory holding this analysis, hardcoded here as a
%           subfolder within the root directory
Analysis.root = [pwd filesep 'models'];
Analysis.name = 'Valence_and_Noise'; % WhiteNoise_vs_AllOther; Emotional_vs_Neutral_Trials; Valence_and_Noise
Analysis.dir  = fullfile(Analysis.root, Analysis.name);

% Verbose. Do you want the pipeline to print text to the Command Window or
% run silently? TRUE = gives user various periodic updates. Defined as a
% global variable so that it is available for all functions and modules in
% the pipeline.
global verbose
verbose = false;

% visualize. Visually inspect and reject the raw data? True = yes, false =
% no.
visualize = false;

%%
%==========================================================================
%                   Pipeline Preperation
%==========================================================================
% Pipeline Prep. Things that need to be done before pipeline can be run.

% Check to see if PsPM is on the search path; throw and error if pspm is 
% not on the path
pspmcheck = which('pspm');
if isempty(pspmcheck)
    error('Please add PsPM to the MATLAB search path')
end
[pspmpath, ~, ~]   = fileparts(pspmcheck);

% Check to see if the helper subfolder is on the matlab search path; if it
% isn't, add it to the matlabsearchpath
pipeline_path    = fileparts(mfilename('fullpath'));
helper_subfolder = fullfile(pipeline_path, 'helper');
matlabsearchpath = path;
matches          = strfind(matlabsearchpath, helper_subfolder);
if isempty(matches)
    fprintf('\nAdding helper subfolder to the MATLAB search path...\n')
    addpath(helper_subfolder);
end

% Check to see if the helper subfolder is on the matlab search path; if it
% isn't, add it to the matlabsearchpath
pipeline_path     = fileparts(mfilename('fullpath'));
modules_subfolder = fullfile(pipeline_path, 'modules');
matlabsearchpath  = path;
matches           = strfind(matlabsearchpath, modules_subfolder);
if isempty(matches)
    fprintf('\nAdding modules subfolder to the MATLAB search path...\n')
    addpath(modules_subfolder);
end

% Grab subject IDs using a regular expression
if Subjects.flag
    Subjects.ids = kyles_spm_select('List', rootdir, 'dir', Subjects.regexp)';
    assert(~isempty(Subjects.ids), 'Could not find any subject subfolders with the regular expression')
end

%%
%==========================================================================
%                           Importing
%==========================================================================
% Import the raw SCR data into MATLAB

for curSubj = Subjects.ids
    
    % current subject ID without the BIDS 'sub-'
    clean_curSubj = regexprep(curSubj, 'sub-', '');
    
    % If the analysis directory doesn't have a subject subfolder, create it
    if ~exist(fullfile(Analysis.dir, curSubj{:}), 'dir')
        mkdir(fullfile(Analysis.dir, curSubj{:}))
    end
    
    % The current subject's biopac directory
    curSubjBiopacDir = fullfile(rootdir, curSubj{:}, 'BioPac'); 
    
    for curTask = Tasks
        
        % If using the Rounds regular expression option, figure out the number
        % of rounds this participant has for this task from the bio_phys
        % filenames
        if Rounds.flag
            
            % Biophys files for this task
            biophys_files   = cellstr(kyles_spm_select('List', curSubjBiopacDir, [lower(curTask{:}) '\.txt$']));
            
            % Round ids extracted from the filenames
            Rounds.ids      = regexp(biophys_files, Rounds.regexp, 'match')';
            
            % This must be true, otherwise either one of the regular
            % expressions is wrong
            assert(~isempty(Rounds.ids), 'Could not find any rounds with the specified regular expression')
            
            % "Unnesting" the resulting cell array from regexp function.
            % See unNest_cell_array.m
            Rounds.ids      = unNest_cell_array(Rounds.ids);
            
            % Sort the Round IDs so that they are in order
            Rounds.ids      = sort(Rounds.ids);
            
        end
        
        for curRound = Rounds.ids

            % Update the user to let them know what is going on
            if verbose
                fprintf('\nTask 1: Importing Data ...\n') 
            end
            
            % Grab the biopac data txt file for this Subject/Round/Task using kyles_spm_select and a regular expression
            filein  = kyles_spm_select('FPList', curSubjBiopacDir, ['.*' curRound{:} '.*' lower(curTask{:}) '\.txt$']);
            
            % Create the output file directory
            if ~exist(fullfile(curSubjBiopacDir, 'processed'), 'dir')
                mkdir(fullfile(curSubjBiopacDir, 'processed'))
            end
            % Output file name
            fileout = fullfile(curSubjBiopacDir, 'processed', [curSubj{:} '_' curRound{:} '_' lower(curTask{:}) '.mat']);
            
            % Import the biopac data for this Subject/Round/Task. Store it
            % in a structure pspm_filename
            pspm_filename.(clean_curSubj{:}).(curTask{:}).(curRound{:}) = biopac_import(filein{:}, fileout);
            
        end
    end
end

%%
%==========================================================================
%                  Visually inspect and reject
%==========================================================================
% Visually inspect and reject bad runs of data for each Subject/Task/Round,
% if desired.

% only perform is desired
if visualize
    
    for curSubj = Subjects.ids

        % current subject ID without the BIDS 'sub-'
        clean_curSubj = regexprep(curSubj, 'sub-', '');    

        % The current subject's biopac directory
        curSubjBiopacDir = fullfile(rootdir, curSubj{:}, 'BioPac');     

        for curTask = Tasks        

            % If using the Rounds regular expression option, figure out the number
            % of rounds this participant has for this task from the bio_phys
            % filenames
            if Rounds.flag
                % Biophys files for this task
                biophys_files   = cellstr(kyles_spm_select('List', curSubjBiopacDir, [lower(curTask{:}) '\.txt$']));
                % Round ids extracted from the filenames
                Rounds.ids      = regexp(biophys_files, Rounds.regexp, 'match')';
                % "Unnesting" the resulting cell array from regexp function.
                % See unNest_cell_array.m
                Rounds.ids      = unNest_cell_array(Rounds.ids);
                % Sort the Round IDs so that they are in order
                Rounds.ids      = sort(Rounds.ids);
            end

            for curRound = Rounds.ids

                if verbose
                    fprintf('\nTask 2: Visual Inspection...\n')
                end
                pspm_inspect(pspm_filename.(clean_curSubj{:}).(curTask{:}).(curRound{:}));

                STR = input('Accept Session? y/n: ', 's');
                if strcmp(STR, 'y')
                elseif strcmp(STR, 'n')
                    fprintf('\nRemoving %s...\n', curRound{:})
                    pspm_filename.(clean_curSubj{:}).(curTask{:}) = rmfield(pspm_filename.(clean_curSubj{:}).(curTask{:}), curRound{:});
                end

            end
        end
    end
end

%%
%==========================================================================
%                           Specify Model
%==========================================================================
% Specify Model for each subject/task

for curSubj = Subjects.ids
    
    % current subject ID without the BIDS 'sub-'
    clean_curSubj = regexprep(curSubj, 'sub-', '');
    
    for curTask = Tasks
        
        if verbose
            fprintf('\nTask 5: Specifying Model...\n')
        end
        behav_data_dir = fullfile(rootdir, curSubj{:}, curTask{:});
        modelfiles.(clean_curSubj{:}).(curTask{:}) = pspm_specify(behav_data_dir, curSubj{:}, Analysis, Rounds.regexp);
        
    end
end

%%
%==========================================================================
%                         Estimate Model
%==========================================================================
% Estimate Model for each subject/task

for curSubj = Subjects.ids
    
    % current subject ID without the BIDS 'sub-'
    clean_curSubj = regexprep(curSubj, 'sub-', '');
    
    for curTask = Tasks
        
        if verbose
            fprintf('\nTask 6: Estimating Model...\n')
        end
        
        datafiles      = struct2cell(pspm_filename.(clean_curSubj{:}).(curTask{:}));
        multicondfiles = modelfiles.(clean_curSubj{:}).(curTask{:});
        
        if length(datafiles) ~= length(multicondfiles)
           % This is the case where there are more behavioral files then
           % biopac files or visa-versa. If this is the case, we can only
           % model the files that we have.
           
            [datafiles, multicondfiles] = match_files(datafiles, multicondfiles);
           
        end
        
        modelTypes     = {'001_filters_off' '002_lowpass_only' '003_highpass_only' '004_filters_on'};
        
        for curType = modelTypes
            
            pspm_estimate_model(datafiles, multicondfiles, Analysis, curSubj{:}, curType{:});
            
        end
        
    end
end

%%
%==========================================================================
%                         Define Contrasts
%==========================================================================
% Define contrasts for each subject/model

% for each subject...
for curSubj = Subjects.ids
    
    % current subject ID without the BIDS 'sub-'
    clean_curSubj = regexprep(curSubj, 'sub-', '');
    
    % for each task..
    for curTask = Tasks
        
        if verbose
            fprintf('\nTask 7: Running Contrasts...\n')
        end
        
        pspm_constrasts(modelfiles.(clean_curSubj{:}).(curTask{:}));
        
    end
end