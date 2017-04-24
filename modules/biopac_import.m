function [pspm_filename] = biopac_import(INFILENAME, OUTFILENAME)

global verbose

%% biopac_2_matlab
% import the biopac text files into a MATLAB table

if verbose
    tic
    fprintf('\nStep 1: Biopac Text file --> MATLAB...\n')
end
if ~exist(OUTFILENAME, 'file')
    datatable = biopactxt_2_matlab(INFILENAME);
end
if verbose
    toc
end

%% format data into pspm desired format

if ~exist(OUTFILENAME, 'file')
    data = cell(8, 1);

    % Physiology Data
    data{1} = datatable.CH1; % SCR
    data{2} = datatable.CH2; % ecg
    data{3} = datatable.CH3; % resp
    data{4} = datatable.CH4; % emg

    % Experiment Markers

    % sometimes the biopac marker channels have a leftover trigger in the first
    % few samples. This code removes that.
    channels = {'CH32' 'CH33' 'CH34' 'CH35'};
    for curChannel = channels
        % identify first 10 samples
        first_ten_samples = datatable.(curChannel{:})(1:10);
        % if any of the first 10 samples does NOT equal zero...
        if any(first_ten_samples ~= 0)
            datatable.(curChannel{:})(1:10) = 0;
        end
    end

    data{5} = datatable.CH32; % emo/shift
    data{6} = datatable.CH33; % emo/same
    data{7} = datatable.CH34; % neu/shift
    data{8} = datatable.CH35; % neu/same
    data{9} = datatable.CH32 + datatable.CH33 + datatable.CH34 + datatable.CH35; % All Events
end

%% write the pspm formatted data to a *.mat file
% write the data to a pspm formatted text file
if verbose
    tic
    fprintf('\nStep 2: MATLAB --> *.mat file...\n')
end
if ~exist(OUTFILENAME, 'file')
    save(OUTFILENAME, 'data');
end
if verbose
    toc
end

%% import *.mat file into pspm
% import data into PsPM. PsPM will create a .mat file of the data for
% further processing.

if verbose
    tic
    fprintf('\nStep 3: *.mat file --> PsPM *.mat file...\n')
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

function matlabbatch = set_pspmimport(matfile)
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = {matfile};
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.chan_nr.chan_nr_spec = 1;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.transfer.none = true;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{2}.ecg.chan_nr.chan_nr_spec = 2;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{2}.ecg.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{3}.resp.chan_nr.chan_nr_spec = 3;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{3}.resp.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{4}.emg.chan_nr.chan_nr_spec = 4;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{4}.emg.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{5}.marker.chan_nr.chan_nr_spec = 5;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{5}.marker.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{6}.marker.chan_nr.chan_nr_spec = 6;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{6}.marker.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{7}.marker.chan_nr.chan_nr_spec = 7;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{7}.marker.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{8}.marker.chan_nr.chan_nr_spec = 8;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{8}.marker.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{9}.marker.chan_nr.chan_nr_spec = 9;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{9}.marker.sample_rate = 1000;    
    matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = false;    
end

end