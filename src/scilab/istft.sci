function timeSignal = istft(stftMatrix, windowLen, hop)
// timeSignal = istft(stftMatrix, windowLen, hop)                   Inverse short-time Fourier transform.
//	Performs overlap-add resynthesis from the short-time Fourier transform 
//	data in stftMatrix.  Each column of stftMatrix is taken as the result of an F-point 
//	fft; each successive frame was offset by hop points (default
//	windowLen/2, or F/2 if windowLen==0). Data is hann-windowed at windowLen pts, or 
//       windowLen = 0 gives a rectangular window (default); 
//    modified version of Dan Ellis' istft.m from http://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/

[numOutputs, nargin] = argn(0);
[ftLen, numOfFTs] = size(stftMatrix);
//if nargin < 2; ftlen = lenOfEachFt; end //2*(lenOfEachFt-1); end
if nargin < 2; windowLen = 0; end
if nargin < 3; hop = 0; end  // will become winlen/2 later

//if lenOfEachFt ~= (ftsize/2)+1
//  error('number of rows should be fftsize/2+1')
//end
 
if length(windowLen) == 1
  if windowLen == 0
    // special case: rectangular window
    win = ones(1,ftLen);
  else
    if modulo(windowLen, 2) == 0   // force window to be odd-len
      windowLen = windowLen + 1;
    end
    halflen = (windowLen-1)/2;
    halff = ftLen/2;
    halfwin = 0.5 * ( 1 + cos( %pi * (0:halflen)/halflen));
    win = zeros(1, ftLen);
    acthalflen = min(halff, halflen);
    win((halff+1):(halff+acthalflen)) = halfwin(1:acthalflen);
    win((halff+1):-1:(halff-acthalflen+2)) = halfwin(1:acthalflen);
    // 2009-01-06: Make stft-istft loop be identity for 25// hop
    win = 2/3*win;
  end
else
  win = windowLen;
end

windowLen = length(win);
// now can set default hop
if hop == 0 
  hop = floor(windowLen/2);
end

timeSignalLen = ftLen + (numOfFTs-1)*hop;
timeSignal = zeros(1,timeSignalLen);

for currTimeStart = 0:hop:(hop*(numOfFTs-1))
  currFT = stftMatrix(:,1+currTimeStart/hop)';
  //currFT = [currFT, conj(currFT([((ftsize/2)):-1:2]))];
  currIFT = real(ifft(currFT));
  timeSignal((currTimeStart+1):(currTimeStart+ftLen)) = timeSignal((currTimeStart+1):(currTimeStart+ftLen))+currIFT.*win;
end;
endfunction