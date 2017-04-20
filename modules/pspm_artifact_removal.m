function [] = pspm_artifact_removal(datafile)
% Function designed to remove artifacts from data using pspm v3.1
% Written by Kyle Kurkela, April 2017

    global verbose
    if verbose
        fprintf('\nStep 1: Removing Artifacts in PsPM...\n')
    end

    matlabbatch = set_inspect_batch(datafile);
    scr_jobman('run', matlabbatch)

    function matlabbatch = set_inspect_batch(datafile)
        matlabbatch{1}.pspm{1}.tools{1}.artefact_rm.datafile = {datafile};
        matlabbatch{1}.pspm{1}.tools{1}.artefact_rm.chan_nr = 1;
        matlabbatch{1}.pspm{1}.tools{1}.artefact_rm.filtertype.median.nr_time_pt = 60;
        matlabbatch{1}.pspm{1}.tools{1}.artefact_rm.overwrite = true;
    end
end