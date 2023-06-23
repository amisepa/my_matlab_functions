function [EEG, badChan, badData] = clean_eeg(EEG,thresh,usegpu,vis)

if length(size(EEG.data)) == 2
    dataType = 'continuous';
elseif length(size(EEG.data)) == 3
    dataType = 'epoched';
end

if isfield(EEG.etc, 'clean_channel_mask')
    EEG.etc = rmfield(EEG.etc, 'clean_channel_mask');
end
if isfield(EEG.etc, 'clean_sample_mask')
    EEG.etc = rmfield(EEG.etc, 'clean_sample_mask');
end

oriEEG = EEG;

% Remove bad channels
EEG = pop_clean_rawdata(EEG,'FlatlineCriterion',5,'ChannelCriterion',.85, ...
    'LineNoiseCriterion',5,'Highpass','off', 'BurstCriterion','off', ...
    'WindowCriterion','off','BurstRejection','off','Distance','off');
badChan = {oriEEG.chanlocs( ~contains({oriEEG.chanlocs.labels}, {EEG.chanlocs.labels}) ).labels};

if vis
    vis_artifacts(EEG,oriEEG);
    figure; topoplot([],EEG.chanlocs,'style','blank', 'electrodes','labelpoint','chaninfo',EEG.chaninfo);
end

% Interpolate bad channels
EEG = pop_interp(EEG, oriEEG.chanlocs, 'spherical');
if isfield(EEG.etc, 'clean_channel_mask')
    EEG.etc = rmfield(EEG.etc, 'clean_channel_mask');
end

% Remove artifacts
switch dataType
    case 'continuous'

        oriEEG = EEG;

        % Run ASR
        TMPEEG = clean_asr(EEG,thresh,[],[],[],[],[],[],usegpu,0,[]);

        % Bad segments
        mask = sum(abs(EEG.data-TMPEEG.data),1) > 1e-8;
        badData = reshape(find(diff([false mask false])),2,[])';
        badData(:,2) = badData(:,2)-1;

        % remove very short segments (<5 samples)
        if ~isempty(badData)
            smallSeg = diff(badData')' < 5;
            % update mask
            for i = 1:length(smallSeg)
                if smallSeg(i)
                    mask(badData(smallSeg(i),1):badData(smallSeg(i),2)) = false;
                end
            end
            % remove
            badData(smallSeg,:) = [];
        end
        
        % Remove and store mask
        EEG = pop_select(EEG,'nopoint',badData);
        EEG.etc.clean_sample_mask = ~mask;

        if vis
            vis_artifacts(EEG,oriEEG);
        end

        % Remove them
        fprintf('%g %% of data were considered to be artifacts and were removed. \n', round( (1-EEG.xmax/oriEEG.xmax)*100,1))

    case 'epoched'

        disp('Detecting bad trials...')
        b = design_fir(100,[2*[0 45 50]/EEG.srate 1],[1 1 0 0]);
        sigRMS = nan(1,size(EEG.data,3));
        snr = nan(1,size(EEG.data,3));
        for iEpoch = 1:size(EEG.data,3)
            sigRMS(:,iEpoch) = rms(rms(squeeze(EEG.data(:,:,iEpoch)),2));
            tmp = filtfilt_fast(b,1, squeeze(EEG.data(:,:,iEpoch))');
            snr(:,iEpoch) = rms(mad(squeeze(EEG.data(:,:,iEpoch)) - tmp'));
        end
        badRMS = isoutlier(sigRMS,method);
        badSNR = isoutlier(snr,method);
        badTrials = unique([find(badRMS) find(badSNR)]);

        if vis
            eegplot(EEG.data(:,:,badTrials),'srate',EEG.srate,'events',EEG.event);
        end

        fprintf('Trials detected: %g \n', length(badTrials));

        badData = badTrials;
end

