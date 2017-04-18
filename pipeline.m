%%% Welcome to the MICE PsychoPhys Pipeline %%%
% Written by Kyle Kurkela, April 2017

%%
%%% Study Parameters

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
%%% Step 1: Importing

filein = fullfile(rootdir, Subjects.ids{1}, 'BioPac', 'sub_s001_round01_ret.txt');
fileout = fullfile(pwd, 'output.txt');

biopac_import(filein, fileout);

%%
%%% Step 2: