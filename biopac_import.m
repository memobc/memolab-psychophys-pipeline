function [] = biopac_import(INFILENAME, OUTFILENAME)

%% biopac_2_matlab
% import the biopac text files into a MATLAB table
data = biopactxt_2_matlab(INFILENAME);

%% write a pspm formatted text file
% write the data to a pspm formatted text file
writetable(data, OUTFILENAME, 'Delimiter', '\t');

%% import into pspm
% import data into PsPM. PsPM will create a .mat file of the data for
% further processing.
matlabbatch = set_pspmimport(OUTFILENAME);
scr_jobman('interactive', matlabbatch);

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