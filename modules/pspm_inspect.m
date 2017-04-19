function pspm_inspect(datafile)
% Function designed to visually inspect scr data using pspm v3.1
% Written by Kyle Kurkela, April 2017

    global verbose
    if verbose
        fprintf('\nStep 1: Displaying Data in PsPM...\n')
    end

    matlabbatch = set_inspect_batch(datafile);
    scr_jobman('run', matlabbatch)

    function matlabbatch = set_inspect_batch(datafile)
        matlabbatch{1}.pspm{1}.tools{1}.display.datafile = {datafile};
    end

end