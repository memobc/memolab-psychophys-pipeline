function [files] = kyles_spm_select(flag, varargin)
% Custom function written by Kyle to mimic the function of the spm_select
% function without using the actual spm_select function. The major
% difference is that the fullpathlist is returned as a cell array of full
% path strings instead of a character array.
%
% Author: Kyle Kurkela, kyleakurkela@gmail.com
% Data: April, 2017
%
% usage: [files] = kyles_spm_select('FPList', directory, regularExpression);
%
% 'FPList' --> tells kyles_spm_select function which type of output you are
% looking for. In this case, the Full Path List of files within dir the
% match regexp
%
% directory --> directory to search
%
% regularExpression --> regular expression to match
%
% See also spm_select, dir

switch flag
    case 'FPList'
        
        % Expand input arguments
        directory         = varargin{1};
        regularExpression = varargin{2};
        
        %%% Algorithm %%%
        
        % Step 1: Find all files in the directory
        
            files_structure = dir(directory);                                   % see dir documentation
            files_structure = files_structure(~vertcat(files_structure.isdir)); % remove all of the subdirectories, leaving only files
            file_names      = {files_structure.name}';                          % create a cell array of just the filenames
        
        % Step 2: Find all files that match the regularExpression
        
            % use MATLAB's regexp to find matches of the regular expression
            regexp_matches           = regexp(file_names, regularExpression);
            
            % convert the messy regexp_matches cell array to a logical
            % vector (i.e., a 'filter')
            regularExpression_filter = ~cellfun(@isempty, regexp_matches);

            % use the above filter to grab just the matching filenames
            matched_file_names       = file_names(regularExpression_filter);
        
        % Step 3: Return all of the matches files as a character array with
        % the directory appended to the beginning to create a full path 
        % to that file. See spm_select
        
            % append directory to matched_file_names
            files = strcat(directory, filesep, matched_file_names);
        
end