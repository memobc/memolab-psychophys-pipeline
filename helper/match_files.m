function [biopac_files, behav_files] = match_files(biopac_files, behav_files)
% returns the intersection of the files in the two input cell arrays of
% file names

%% Find the Intersection

% extract the round IDs from the filenames of the two file types
biopac_rounds    = find_round_ids(biopac_files);
multicond_rounds = find_round_ids(behav_files);

% find the round ids that have both a biopac file AND a behavioral file
theIntersection = intersect(biopac_rounds, multicond_rounds);

%% boolean matching

biopac_files = boolean_match(biopac_files, theIntersection);
behav_files  = boolean_match(behav_files, theIntersection);

%% subfunction(s)

function [rounds] = find_round_ids(files)
    % returns the round IDs extracted from the file names array "files"
    
    % assumes filenames have round##. if this is not the case, an
    % error will be thrown    
    rounds = regexp(files, 'round..', 'match'); 
    assert(~all(cellfun(@isempty, rounds)), 'round filename assumption failed')
    rounds = unNest_cell_array(rounds);
    
end

function [files] = boolean_match(files, regularExp_array)
    % returns files that match the regular expressions in it
    % regularExp_array
    
    grand_booleanVector = false(length(files), 1);
    for curRound = regularExp_array'
       cur_booleanVector   = ~cellfun(@isempty, regexp(files, curRound{:}));
       grand_booleanVector = grand_booleanVector | cur_booleanVector;
    end
    files = files(grand_booleanVector);    
    
end

end