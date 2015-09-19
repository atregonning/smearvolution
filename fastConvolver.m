% Name:     Adrian Tregonning
% ID:       N15324885
% Net ID:   at2454
% 
% DST II Final project
%
% y = fastConvolver(sig, ir, wet, dry)
%
%   Fast convolution implementation. A normalized mix of the original and convolved
%   signal are returned with the wet/dry balance determined by the input arguments.
%
% Inputs - 
%
%   sig:    Column vector containing the first signal
%           (stereo or mono) to be convolved
%   ir:     Column vector containing the second signal
%           (stereo or mono) to be convolved
%   wet:    The amount of convolved signal in the output
%   dry:    The amount of dry signal in the output
% 
% Outputs -
%
%   y:        The processed signal

function y = fastConvolver(sig, ir, wetAmt, dryAmt)

    [lenSig, chanSig] = size(sig);
    [lenIR, chanIR] = size(ir);
    
    % Ensure both signals have same number of channels
    if chanSig ~= chanIR
        if chanSig == 2 && chanIR == 1  % Make impulse stereo
            ir = [ir, ir];
        elseif chanSig == 1 && chanIR == 2 % Make impulse mono
            ir = mean(ir, 2);
        end
    end
    
    % Zero pad signals to correct length
%     convLength = lenSig + lenIR - 1;
    sig = [sig; zeros(lenIR - 1, chanSig)];
    ir = [ir; zeros(lenSig - 1, chanSig)];
    
    % Fast convolution
    SIG = fft(sig);
    IR = fft(ir);
    
    wetSig = ifft(SIG .* IR);
    wetSig = wetSig / max(abs(wetSig));
    
    % Create wet/dry mix and normalize
    y = (wetAmt * wetSig) + (dryAmt * sig);
    y = y / max(abs(y));
      
end