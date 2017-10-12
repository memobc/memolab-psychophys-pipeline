function pspm_contrasts(modelname, modelfile)
% function for batch running contrasts in PsPM

%% 
%==========================================================================
%                   User Defined Contrasts
%==========================================================================
% User Defined Contrasts

% Inialize nContrasts to 0
nContrasts = 0;

switch modelname
    
    case 'Valence_and_Noise'

        % White Noise
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'White-Noise'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'WhiteNoise, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

        % Negative-Trials
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Negative-Trials'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Negative_Trials, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

        % Neutral-Tone
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Neutral-Tone'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'NeutralTone, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

        % Neutral-Trials
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Neutral-Trials'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Neutral_Trials, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)
        
    case 'Valence_and_Noise2'
        
        % White-Noise
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'White-Noise'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'White-Noise, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

        % Negative-Trials-in-a-White-Noise-MiniBlock
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Negative-Trials-in-a-White-Noise-MiniBlock'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Negative-Trials-in-a-White-Noise-MiniBlock, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

        % Negative-Trials
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Negative-Trials'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Negative-Trials, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

        % Neutral-Tone
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Neutral-Tone'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Neutral-Tone, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)
        
        % Neutral-Trials-in-a-Neutral-Tone-MiniBlock
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Neutral-Trials-in-a-Neutral-Tone-MiniBlock'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Neutral-Trials-in-a-Neutral-Tone-MiniBlock, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)
        
        % Neutral-Trials
        nContrasts = nContrasts + 1;
        Contrasts(nContrasts).name     = 'Neutral-Trials'; % arbitrary name of contrast
        Contrasts(nContrasts).positive = { 'Neutral-Trials, bf 1' }; % Parameters to be included in contrast (+)
        Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)        
        
end

% Build appropriate contrast vectors, weighting everything so that it adds
% up to 1 and -1
Contrasts  = BuildContrastVectors(modelfile, Contrasts);

% set pspm parameters
matlabbatch = set_contrast_params(modelfile, Contrasts);

% run/interactive
scr_jobman('run', matlabbatch)

%%

function matlabbatch = set_contrast_params(file, contrasts)
    % set PsPM contrast parameters
    %
    % file      = model file
    % contrasts = structure array with contrast names and vectors
    
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.modelfile = {file};
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.datatype  = 'param';
    for nC = 1:length(contrasts)
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(nC).conname = contrasts(nC).name;
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(nC).convec  = contrasts(nC).vec;
    end
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.deletecon = true;
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.zscored   = false;
end

function contrasts = BuildContrastVectors(file, contrasts)
   % build appropriate contrast vectors for each specified contrast

   % load the PsPM model file `file`
   glm = [];
   load(file)

   % for each specified contrast in the `contrasts` structure array...
   for nC = 1:length(contrasts)

       % positiveFilt = boolean vector with 1's where there are matches
       % between the specified positive parameters and actual
       % parameters
       % 
       % negativeFilt = boolean vector with 1's where there are matches
       % between the specified negative parameters and actual
       % parameters
       positiveFilt = ismember(glm.names, contrasts(nC).positive)';
       negativeFilt = ismember(glm.names, contrasts(nC).negative)';

       % PositiveMatchesExist = boolean, detemines if any of the
       % specified positive parameters exist in the model
       %
       % NegativeMatchesExist = boolean, determines if any of the
       % specified negative parameters exist in the model
       PositiveMatchesExist = ~isempty(find(positiveFilt, 1));
       NegativeMatchesExist = ~isempty(find(negativeFilt, 1));

       % Build contrast vectors, weighting eveything so equally so that
       % they add up to 1 and -1
       if PositiveMatchesExist && NegativeMatchesExist
            contrasts(nC).vec = positiveFilt / length(find(positiveFilt)) - negativeFilt / length(find(negativeFilt));
       elseif ~PositiveMatchesExist
            contrasts(nC).vec = -1 * negativeFilt / length(find(negativeFilt));
       elseif ~NegativeMatchesExist
            contrasts(nC).vec = positiveFilt / length(find(positiveFilt));
       end

   end

end

end