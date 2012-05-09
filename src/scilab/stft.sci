function [stftMatrix] = stft(timeSignal, ftLength, windowLength, timeDivLength)
// stftMatrix = stft(timeSignal, fftLength, windowLength, timeDivLength)    Short-time Fourier transform.
//    Returns some frames of short-term Fourier transform of timeSignal.  Each 
//	column of the result is one ftLength ft (default 256); each
//	successive frame is offset by hopLength points (windowLength/2) until timeSignal is exhausted.  
//      Data is hann-windowed at windowLength pts (ftLength), or rectangular if windowLength=0
//    modified version of Dan Ellis' stft.m from http://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/

[numOutputs, numInputs] = argn(0);
if numInputs < 2;  ftLength = 256; end
if numInputs < 3;  windowLength = ftLength; end
if numInputs < 4;  timeDivLength = 0; end

// expect timeSignal as a row
if size(timeSignal,1) > 1
  timeSignal = timeSignal';
end

timeSignalLength = length(timeSignal);

if length(windowLength) == 1
  if windowLength == 0
    // special case: rectangular window
    windowMags = ones(1,ftLength);
  else
    if modulo(windowLength, 2) == 0   // force window to be odd-len
      windowLength = windowLength + 1;
    end
    halfWindowLen = (windowLength-1)/2;
    halfFTLen = ftLength/2;
    windowMidPoint = halfFTLen + 1; 
    windowMagsRHS = 0.5 * ( 1 + cos( %pi * (0:halfWindowLen)/halfWindowLen));
    windowMags = zeros(1, ftLength);
    actHalfLen = min(halfFTLen, halfWindowLen);
    windowMags(windowMidPoint:(halfFTLen+actHalfLen)) = windowMagsRHS(1:actHalfLen);
    windowMags(windowMidPoint:-1:(halfFTLen-actHalfLen+2)) = windowMagsRHS(1:actHalfLen);
  end
else
  windowMags = windowLength;
end

windowLength = length(windowMags);
// now can set default hop
if timeDivLength == 0
  timeDivLength = floor(windowLength/2);
end

// pre-allocate output array
numberOfFFTs = fix((timeSignalLength-ftLength)/timeDivLength) + 1;
//lengthOfEachSTFT = 1+fftLength/2;
lengthOfEachSTFT = ftLength;
stftMatrix = zeros(lengthOfEachSTFT,numberOfFFTs);

currFFTIndx = 1;
for currTimeIndx = 0:timeDivLength:(timeSignalLength-ftLength)
  windowedTimeSignal = windowMags.*timeSignal((currTimeIndx+1):(currTimeIndx+ftLength));
  windowedFFT = fft(windowedTimeSignal);
  //stftMatrix(:,currFFTIndx) = windowedFFT(1:(1+fftLength/2))';
  stftMatrix(:,currFFTIndx) = windowedFFT';
  currFFTIndx = currFFTIndx+1;
end
endfunction