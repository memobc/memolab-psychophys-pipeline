function MICE_scr_overview(task)
%%% A MICE Raw SCR Data Overview %%%

% harcoded parameters
datadir   = '/Volumes/memolab/MICE/MICE_fMRI/data';

datadirs  = cellstr(spm_select('FPList', datadir, 'dir', '^sub-s0(?!02|18|21|23|24|25|29|31)'));

names = regexp(datadirs, 'sub-s...', 'match');
names = unNest_cell_array(names);

output    = cellfun(@concatenate_sessions, datadirs, repmat({lower(task(1:3))}, length(datadirs), 1), 'UniformOutput', false);

output    = cellfun(@timeseries, output, ...
                    repmat({'Name'}, length(output), 1), names, ...
                    'UniformOutput', false);

% Remove outlying samples
% for i = 1:length(output)
%     outlierBool = output{i}.Data > (output{i}.mean + (7 * output{i}.std)); % more then 7 stdard deviations away from the mean
%     output{i}.Data(outlierBool) = NaN;
%     output{i}.Data = output{i}.Data - output{i}.mean;
% end
                
figure('Position', [0 0 1920 1920], 'Name', [task ' SCR Data']);

for i = 1:length(output)
    subplot(ceil(length(output)/2),2,i)
    plot(output{i})
end

function output = concatenate_sessions(directory, task)
    
    % identify data file names
    filenames = cellstr(spm_select('FPListRec', directory, ['^sub-.*' task '\.mat']));

    % load all of the data simultaneously
    data      = cellfun(@load, filenames, 'UniformOutput', false);

    % define a temporary function that:
    % - extracts
    % - removes the mean from and
    % - median filters
    % each RUN of the data
    ext       = @(x) medfilt1(x.data{1} - mean(x.data{1}), 10);

    % use the above defined function to extract, remove mean, and
    % median filter each run of the data
    data      = cellfun(ext, data, 'UniformOutput', false);

    % concatenate the runs
    output    = vertcat(data{:})';
    
end

end