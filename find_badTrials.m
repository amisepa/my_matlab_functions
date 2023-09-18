%% Scan data to find bad trials using amplitude and high-frequency power
%
% INPUT:
%   EEG - EEG stucture (EEGLAB)
%   method  - 'grubbs' (default, more aggressive), 'mean' (more lax)
%
% OUTPUT:
%   badTrials
%
% Cedric Cannard, Dec 2022

function badTrials = find_badTrials(EEG,method,vis)

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
    eegplot(EEG.data(:,:,badTrials),'srate',EEG.srate,'events',EEG.event,'spacing',50);
end

fprintf('Trials detected: %g \n', length(badTrials));
