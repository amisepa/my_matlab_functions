%% Compute power spectral density (PSD) or power for each EEG channel using
% MATLAB's pwelch method.  Defaults are Hamming taper on a 2-s window with
% 50% overlap, outputting the power spectral density (PSD).
% 
% Usage:
% [psd, freqs] = get_psd(eeg_data,winSize,taperM,overlap,nfft,Fs,freqRange,type);
% [psd, freqs] = get_psd(EEG.data,EEG.srate*2,'hamming',50,[],EEG.srate,[1 50],'psd');
% 
% - eeg_data with channels in 1st dimension and data in 2nd dimension (default = EEG.data)
% - window size in frames (default = 2 s window).
% - taper method: hamming (default), hann, blackman, rectwin.
% - overlap in percent (default = 50)
% - Fs: sample rate in Hz (default = EEG.srate)
% - freqRange is frequecnies of interest to compute (default = 1:100)
% - type: returns power spectral density ('psd'; default) or returns
%           'power' (scales each estimate of the PSD by the equivalent noise 
%           bandwidth of the window (in hertz): i.e. power estimate at each frequency).
% 
% Cedric Cannard, 2021

function [pxx, f] = get_psd(eegData,winSize,taperM,overlap,nfft,Fs,fRange,type)

%error if no sampling rate provided
if ~exist('Fs', 'var') || isempty(Fs)
    errordlg('You need to provide the sampling rate Fs to use this function.'); return;
end

%Window size
if ~exist('winSize', 'var') || isempty(winSize) 
    disp('Window size not provided: 2-s windows');
    winSize = Fs*2;
end

%Tapering
if ~exist('taperM', 'var') || isempty(taperM) 
    taperM = 'hamming'; %hamming (default); hann; blackman; rectwin
end
fh = str2func(taperM);

% Overlap
if ~exist('overlap', 'var') || isempty(overlap)
    overlap = 50;
end
overlap = winSize/(100/overlap); %get overlap in samples

% Frequency range default
if ~exist('fRange', 'var') || isempty(fRange)
    fRange = [0 Fs/2];     %1 Hz for the min and Nyquist (srate/2) for the max. 
end

% % Power type default
% if ~exist('type', 'var') || isempty(type)
%     type = 'psd';     %1 Hz for the min and Nyquist (srate/2) for the max. 
% end

%nfft
if ~exist('nfft', 'var') 
    nfft = [];
end

% %Detrend data
% if size(eegData,3) > 1
%     for iTrial = 1:size(eegData,3)
%         eegData(:,:,iTrial) = detrend(eegData(:,:,iTrial)')';
%     end
% else
%     eegData = detrend(eegData')';
% end

%Power spectral density (PSD)
% disp('computing power spectral density (PSD) for each channel...');
for iChan = 1:size(eegData,1)
    [pxx(iChan,:), f] = pwelch(eegData(iChan,:),fh(winSize),overlap,nfft,Fs,type);
%     [pxx(:,iChan), f, c] = pwelch(eegData(iChan,:), window, overlap, [], Fs, type);
end

%Calculate frequency resolution
% exp_tlen = nextpow2(tlen);
% fres = Fs/2.^exp_tlen;

% Truncate PSD to frequency range of interest (ignore freq 0)
freq = dsearchn(f,fRange(1)):dsearchn(f, fRange(2));
f = f(freq(2:end));
pxx = pxx(:,freq(2:end));     
f = f';

%Normalize to deciBels (dB)
pxx = 10*log10(pxx);
disp('Power spectrum normalized to dB!')

end
