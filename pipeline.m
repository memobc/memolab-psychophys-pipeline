%%% Welcome to the MICE PsychoPhys Pipeline %%%
% Written by Kyle Kurkela, April 2017

%%
%%% Study Parameters
% Define study and computer specific parameters

% Where is the MICE Biopac data on your computer?
rootdir  = '/Volumes/memolab/MICE/MICE_fMRI/Data/';

% Subjects structure, with the fields:
%   .flag   = 1 if you want to specify the ids to run in the .ids field, 2
%             if you want to use a regular expression to grab subjects ids
%   .ids    = a 1 x n cell array of subject ids strings to run
%   .regexp = a regular expression, used to grab subjects ids
Subjects.flag   = 1;
Subjects.ids    = {'s001'};
Subjects.regexp = 's...';

% A 1 x n cell array of the different tasks to analyze (e.g., encoding,
% retrieval)
Tasks         = {'Ret'}; % Enc

% Rounds structure, with the fields:
%   .flag   = 1 if you want to specify the ids to run in the .ids field, 2
%             if you want to use a regular expression to grab subjects ids
%   .ids    = a 1 x n cell array of strings detailing the names of the
%             rounds
%   .regexp = a regular expression, used to grab individual task rounds
Rounds.flag   = 1;
Rounds.ids    = {'round01' 'round02' 'round03' 'round04' 'round05'};
Rounds.regexp = 'round..';

% Analysis structure, with the fileds:
Analysis.root = pwd;
Analysis.name = 'test';
Analysis.dir  = fullfile(Analysis.root, Analysis.name);

% Verbose. Do you want the pipeline to print text to the Command Window or
% run silently?
global verbose
verbose = true;

%%
%%% Pipeline Prep

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
    addpath(helper_subfolder);
end

%%
%%% Task 1: Importing

for curSubj = Subjects.ids
    
    if ~exist(fullfile(Analysis.dir, curSubj{:}), 'dir')
        mkdir(fullfile(Analysis.dir, curSubj{:}))
    end
    
    % The current subject's biopac directory
    curSubjBiopacDir = fullfile(rootdir, curSubj{:}, 'BioPac');    
    
    for curTask = Tasks
        for curRound = Rounds.ids

            % Update the user to let them know what is going on
            if verbose
                fprintf('\nTask 1: Importing Data ...\n') 
            end
            
            % Grab the biopac data txt file for this Subject/Round/Task
            % using spm_select and a regular expression
            filein  = kyles_spm_select('FPList', curSubjBiopacDir, ['.*' curRound{:} '.*' lower(curTask{:}) '\.txt']); %'sub_s001_round01_ret.txt'
            
            % Create the output filename
            fileout = fullfile(Analysis.dir, curSubj{:}, [curSubj{:} '_' curRound{:} '_' lower(curTask{:}) '.txt']);
            
            % Import the biopac data for this Subject/Round/Task
            pspm_filename.(curSubj{:}).(curTask{:}).(curRound{:}) = biopac_import(filein{:}, fileout);
            
        end
    end
end

%%
%%% Task 2: Visually inspect and reject sessions

for curSubj = Subjects.ids   
    for curTask = Tasks
        for curRound = Rounds.ids

            if verbose
                fprintf('\nTask 2: Visual Inspection...\n') 
            end
            pspm_inspect(pspm_filename.(curSubj{:}).(curTask{:}).(curRound{:}));

            STR = input('Accept Session? y/n: ', 's');
            if strcmp(STR, 'y')
            elseif strcmp(STR, 'n')
                pspm_filename.(curSubj{:}).(curTask{:}) = rmfield(pspm_filename.(curSubj{:}).(curTask{:}), curRound{:});
            end

        end
    end
end

%%
%%% Task 3: Specify Model

for curSubj = Subjects.ids
    for curTask = Tasks
        
        if verbose
            fprintf('\nTask 3: Specifying Model...\n')
        end
        behav_data = fullfile(rootdir, curSubj{:}, curTask{:});
        modelfiles.(curSubj{:}).(curTask{:}) = pspm_specify(behav_data, curSubj{:}, Analysis);
        
    end
end

%%
%%% Task 4: Estimate Model
for curSubj = Subjects.ids
    for curTask = Tasks
        
        if verbose
            fprintf('\nTask 4: Modeling...\n')
        end
        
        datafiles      = struct2cell(pspm_filename.(curSubj{:}).(curTask{:}));
        multicondfiles = modelfiles.(curSubj{:}).(curTask{:});
        
        estimate_pspm_model(datafiles, multicondfiles, Analysis);
        
    end
end