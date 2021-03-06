function pspm_estimate_model(datafile, modelfile, Analysis, currentSubjectID, modelType)
% Function for specifying a GLM for modeling MICE's scr data

    % Verbosity (i.e., tell the user what the hell is going on)
    global verbose
    if verbose
        fprintf('\nStep 1: Estimating the SCR GLM in PsPM...\n')
    end

    % set the matlabbatch structure (see subfunction below)
    matlabbatch = set_model_batch(datafile, modelfile, [currentSubjectID '_' modelType], fullfile(Analysis.dir, currentSubjectID));
    
    % run this job through pspm's version of the SPM job manager
    scr_jobman('run', matlabbatch)

%% Sub Functions
    
function matlabbatch = set_model_batch(filename, modelfile, name, dir)
    
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.modelfile                         = name;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.outdir                            = {dir};
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.chan.chan_def                     = 0;    % assume first SCR channel has data
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.timeunits.seconds                 = 'seconds';
    for curSess = 1:length(modelfile)
        matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.session(curSess).datafile             = filename(curSess);
        matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.session(curSess).missing.no_epochs    = 0;    % no epochs to remove
        matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.session(curSess).data_design.condfile = modelfile(curSess);
        matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.session(curSess).nuisancefile         = {''}; % no nuisance regressors
    end
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.scrf1                          = 1;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.norm                              = true; % z normalize data    
    
    switch name
        
        case '001_filters_off'
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.lowpass.disable = 0;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.highpass.disable = 0;
        case '002_lowpass_only'
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.lowpass.enable.freq = 5;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.lowpass.enable.order = 1;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.highpass.disable = 0;
        case '003_highpass_only'
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.lowpass.disable = 0;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.highpass.enable.freq = 0.05;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.highpass.enable.order = 1;            
        case '004_filters_on'
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.lowpass.enable.freq   = 5;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.lowpass.enable.order  = 1;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.highpass.enable.freq  = 0.05;
            matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.highpass.enable.order = 1;
    end
    
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.down                  = 10;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.edit.direction             = 'uni';
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm_scr.overwrite                         = true;    

end

end