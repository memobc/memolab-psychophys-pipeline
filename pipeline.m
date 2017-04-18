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
Subjects.flag   = 2;
Subjects.ids    = {'s001'};
Subjects.regexp = 's...';

% A 1 x n cell array of the different tasks to analyze (e.g., encoding,
% retrieval)
Tasks         = {'enc', 'ret'};

% Rounds structure, with the fields:
%   .flag   = 1 if you want to specify the ids to run in the .ids field, 2
%             if you want to use a regular expression to grab subjects ids
%   .ids    = a 1 x n cell array of strings detailing the names of the
%             rounds
%   .regexp = a regular expression, used to grab individual task rounds
Rounds.flag   = 2;
Rounds.ids    = {'round01' 'round02' 'round03' 'round04' 'round05' 'round06'};
Rounds.regexp = 'round..';


% Verbose. Do you want the pipeline to print text to the Command Window or
% run silently?
global verbose
verbose = true;

%%
%%% Checking
% Check to see if spm is on the MATLAB search path; if so remove it
% from the search path; then check to see if PsPM is on the search
% path; throw and error if pspm is not on the path

spmcheck = which('spm');
if ~isempty(spmcheck)
    [spmpath,~,~] = fileparts(spmcheck);
    rmpath(genpath(spmpath));
end

pspmcheck = which('pspm');
if isempty(pspmcheck)
    error('Please add PsPM to the MATLAB search path')
end

%%
%%% Task 1: Importing

if verbose
    fprintf('Task 1: Importing Data ...\n') 
end
filein  = fullfile(rootdir, Subjects.ids{1}, 'BioPac', 'sub_s001_round01_ret.txt');
fileout = fullfile(pwd, 'output.txt'); % change to something with subject name, round, and task
pspm_filename = biopac_import(filein, fileout);

%%
%%% Task 2: Visually inspect and reject

if verbose
    fprintf('\nTask 2: Visual Inspection...\n') 
end
pspm_inspect(pspm_filename);

STR = input('Accept Participant? y/n: ', 's');
if strcmp(STR, 'y') || isempty(STR)
    
elseif strcmp(STR, 'n')
    %continue
end

%%
%%% Task 3: 
if verbose
    fprintf('\nTask 3: Downsample...\n') 
end
pspm_downsample(pspm_filename);

%%
%%% Task 4:
