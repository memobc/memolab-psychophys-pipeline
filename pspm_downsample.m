function downsample_pspm_data = pspm_downsample(filename)
% Function for downsampling the MICE SRC data    

    global verbose
    if verbose
        fprintf('\nStep 1: Downsampling data in PsPM...\n')
    end

    matlabbatch = set_downsample_batch(filename);
    scr_jobman('run', matlabbatch)
    
    [path,name,ext] = fileparts(filename);
    downsample_pspm_data = fullfile(path, ['d' name ext]);

    function matlabbatch = set_downsample_batch(filename)
        matlabbatch{1}.pspm{1}.tools{1}.downsample.datafile = {filename};
        matlabbatch{1}.pspm{1}.tools{1}.downsample.newfreq = 10;
        matlabbatch{1}.pspm{1}.tools{1}.downsample.chan.chan_vec = 1;
        matlabbatch{1}.pspm{1}.tools{1}.downsample.overwrite = false;
    end

end