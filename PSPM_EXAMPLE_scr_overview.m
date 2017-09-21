function PSPM_EXAMPLE_scr_overview()
%%% A MICE Raw SCR Data Overview %%%

% harcoded parameters
datadir   = '/Users/kylekurkela/Documents/datasets';

datadirs  = cellstr(spm_select('FPList', datadir, 'dir', '^PsPM'));

names = regexp(datadirs, 'SCRV.', 'match');
names = unNest_cell_array(names);

trims = {1:180, 1:45, 1:20}; 

for iData = 1:length(datadirs)
    
    trimL     = trims(iData);

    output    = concatenate_sessions(datadirs{iData});
    
    iNames      = repmat(names(iData), length(output), 1);
    ndash       = repmat({'-'}, length(output), 1);
    subjectNums = cellstr(num2str( (1:length(output))', '%02d' ));
    
    iNames    = strcat(iNames,  ndash, subjectNums);

    output    = cellfun(@timeseries, output, ...
                        repmat({'Name'}, length(output), 1), iNames, ...
                        'UniformOutput', false);
                    
    output    = cellfun(@trim, output, ...
                        repmat(trimL, length(output), 1), ...
                        'UniformOutput', false);
                    
    %output    = cellfun(@meancenter, output, 'UniformOutput', false);

    figure('Position', [0 0 1920 1920], 'Name', names{iData});

    for i = 1:length(output)
        subplot(ceil(length(output)/2),2,i)
        plot(output{i})
    end

end

    function data = concatenate_sessions(directory)
    
        % load sessions and concatenate
        filenames = cellstr(spm_select('FPList', directory, '.*spike.*\.mat'));

        data      = cellfun(@load, filenames, 'UniformOutput', false);

        ext       = @(x) vertcat(x.data{1}.data, x.data{2}.data);

        data      = cellfun(ext, data, 'UniformOutput', false);
            
    end

    function y = trim(y, trimL)
        
        y = delsample(y, 'Index', trimL);
        
    end

    function l = meancenter(l)
        
       l.Data = l.Data - l.mean;
        
    end

end