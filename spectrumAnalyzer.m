% 
% Name: Adrian Tregonning
% ID: N15324885
% Net ID: at2454
%
% SPECTRUM ANALYZER
%
% [MAGS, PHASES] = spectrumAnalyzer(filename, winLength, overlapLength, window, fftlength)
%
%   Creates a spectrogram for an input WAV file using the STFT with a
%   window function chosen by user. The signal is plotted
%
% Inputs - 
%
%   filename:       name of .WAV file to be analyzed (in current directory)
%   winLength:      length of signal window (in samples)
%   overlapLength:  length of signal overlap (in samples)
%   window:         window type, one of the following strings
%                       - 'rect'
%                       - 'hamming'
%                       - 'hann'
%                       - 'blackman'
%                       - 'bartlett'
%   fftlength:      number of samples to be used in fft (default: winLength)
% 
% Outputs - 
%
%   MAGS:           a 2D matrix containing the normalized magnitudes of the 
%                   STFT in dB
%   PHASES:         a 2D matrix containing the phases

function [MAGS, PHASES] = spectrumAnalyzer(sig, winLength, overlapLength, window, fftlength)
    
    % Check number of arguments
    if nargin < 4
        error(['Error: at least 4 arguments required', ...
            '(filename, winlength, overlapLength, window)'])
    end
    
    %
    % Type and value check inputs
    %
    
    % winLength > 0
    if ~isnumeric(winLength)
        error('Error: winLength must be a number')
    elseif winLength <= 0
        error('Error: winLength must be > 0')
    end
    
    % 0 < overlapLength < winLength
    if ~isnumeric(overlapLength)
        error('Error: overlapLength must be a number')
    elseif overlapLength < 0
        error('Error: overlapLength must be >= 0')
    elseif overlapLength >= winLength
        error('Error: overlapLength must be < winLength')
    end
    
    % Note: window type is checked later
    if ~ischar(window)
        error(['Error: window must be a valid string - ',...
            'rect, hamming, hann, blackman, bartlett'])
    end
        
    % winLength < fftLength
    % If fftlength not present default (winLength) is used
    if nargin == 4
        warning('Default fftlength being used (= winlength)')
        fftlength = winLength;
    elseif fftlength < winLength
        error('Error: fftLength must be >= winLength')
    end
    
    % Choose the appropriate windowing function
    switch window
        case 'rect'
            windowFunc = ones(winLength,1);
        case 'hamming'
            windowFunc = hamming(winLength);
        case 'hann'
            windowFunc = hann(winLength);
        case 'blackman'
            windowFunc = blackman(winLength);
        case 'bartlett'
            windowFunc = bartlett(winLength);
        otherwise
            error(['Error: invalid window type - ',...
                 'choose from rect, hamming, hann, blackman, bartlett'])
    end
    
    % Split signal into windows
    buff = buffer(sig, winLength, overlapLength);
    
    [~, numWin] = size(buff);
    wins = repmat(windowFunc, 1, numWin);
    winSig = wins .* buff;
    
    % Convert to frequency domain
    WIN_SIG = fft(winSig, fftlength);
    
    % Get magnitudes and phases
    WIN_SIG_MAG = abs(WIN_SIG);
    PHASES = angle(WIN_SIG);
    
    % Normalize magnitudes, convert to dB
    WIN_SIG_MAG_NORM = WIN_SIG_MAG / (sum(windowFunc) / 2);
    MAGS = mag2db(WIN_SIG_MAG_NORM);    
        
end