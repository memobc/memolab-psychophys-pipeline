function [pspm_filename] = biopac_import(INFILENAME, OUTFILENAME)

global verbose
%% biopac_2_matlab
% import the biopac text files into a MATLAB table

if verbose
    tic
    fprintf('\nStep 1: Biopac Text file --> MATLAB...\n')
end
if ~exist(OUTFILENAME, 'file')
    data = biopactxt_2_matlab(INFILENAME);
end
if verbose
    toc
end

%% write a pspm formatted text file
% write the data to a pspm formatted text file
if verbose
    tic
    fprintf('\nStep 2: MATLAB --> Simple Text File...\n')
end
if ~exist(OUTFILENAME, 'file')
    writetable(data, OUTFILENAME, 'Delimiter', '\t');
end
if verbose
    toc
end

%% import into pspm
% import data into PsPM. PsPM will create a .mat file of the data for
% further processing.

if verbose
    tic
    fprintf('\nStep 3: Simple Text File --> PsPM .mat file...\n')
end
[path,filename,~] = fileparts(OUTFILENAME);
pspm_filename = fullfile(path, ['scr_' filename '.mat']);
if ~exist(pspm_filename, 'file')
    matlabbatch = set_pspmimport(OUTFILENAME);
    scr_jobman('run', matlabbatch);
end
if verbose
    toc
end

%% subfunctions

function matlabbatch = set_pspmimport(textfile)
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.datafile = {textfile};
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{1}.scr.chan_nr.chan_nr_spec = 2;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{1}.scr.sample_rate = 1000;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{1}.scr.transfer.none = true;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{2}.ecg.chan_nr.chan_nr_spec = 3;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{2}.ecg.sample_rate = 1000;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{3}.resp.chan_nr.chan_nr_spec = 4;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{3}.resp.sample_rate = 1000;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{4}.emg.chan_nr.chan_nr_spec = 5;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.txt.importtype{4}.emg.sample_rate = 1000;
        matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = false;
end

end