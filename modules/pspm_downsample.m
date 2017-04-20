function [downsampled_datafile] = pspm_downsample(datafile)
% Function designed to remove artifacts from data using pspm v3.1
% Written by Kyle Kurkela, April 2017

    global verbose
    if verbose
        fprintf('\nStep 1: Downsampling in PsPM...\n')
    end

    matlabbatch = set_inspect_batch(datafile);
    scr_jobman('run', matlabbatch);
    
    [filepath,name,ext]  = fileparts(datafile);
    downsampled_datafile = fullfile(filepath, ['d' name ext]);

    function matlabbatch = set_inspect_batch(datafile)
        matlabbatch{1}.pspm{1}.tools{1}.downsample.datafile = {datafile};
        matlabbatch{1}.pspm{1}.tools{1}.downsample.newfreq = 10;
        matlabbatch{1}.pspm{1}.tools{1}.downsample.chan.chan_vec = 1;
        matlabbatch{1}.pspm{1}.tools{1}.downsample.overwrite = true;
    end
end