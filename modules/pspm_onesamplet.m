function pspm_onesamplet(modelfiles, outdir)
% run one sample t tests on all first level contrasts

matlabbatch = set_onesamplet_params(modelfiles, outdir);
scr_jobman('run', matlabbatch)

function  matlabbatch = set_onesamplet_params(modelfiles, outdir)
   % set one sample T test parameters for PsPM
    matlabbatch{1}.pspm{1}.second_level{1}.contrast.testtype.one_sample.modelfile = cellstr(modelfiles);
    matlabbatch{1}.pspm{1}.second_level{1}.contrast.outdir                        = {outdir};
    matlabbatch{1}.pspm{1}.second_level{1}.contrast.filename                      = 'onesample-t-tests';
    matlabbatch{1}.pspm{1}.second_level{1}.contrast.def_con_name.file.con_all     = 'all';
    matlabbatch{1}.pspm{1}.second_level{1}.contrast.overwrite                     = true;

end
end