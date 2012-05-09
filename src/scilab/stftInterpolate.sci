function interpolatedSTFTMatrix = stftInterpolate(stftMatrix, interpolateLocations, hop)
// interpolatedSTFTMatrix = stftInterpolate(stftMatrix, interpolateLocations, hop)   Interpolate an STFT array according to the 'phase vocoder'
//     stftMatrix is an STFT matrix.
//     For each value of interpolateLocations, 
//     the spectral magnitudes in the columns of stftMatrix are interpolated, and 
//     the phase difference between the successive columns of stftMatrix is 
//     calculated; a new column is created in the output array that 
//     preserves this per-step phase advance in each bin.
//     hop is the STFT hop size, defaults to N/2, where N is the FFT size
//     and b has N/2+1 rows.  hop is needed to calculate the 'null' phase 
//     advance expected in each bin.
//     Note: interpolateLocations is defined relative to a zero origin, so 0.1 is 90% of 
//     the first column of stftMatrix, plus 10% of the second.
//     modified version of Dan Ellis' pvsample.m from http://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/

[numOutputs, nargin] = argn(0);

[lenOfEachFt,numOfFts] = size(stftMatrix);

N = 2*(lenOfEachFt-1);

if nargin < 3
  hop = N/2;
end

// Empty output array
interpolatedSTFTMatrix = zeros(lenOfEachFt, length(t));

// Expected phase advance in each bin
expectedPhaseAdvance = zeros(1,N/2+1);
expectedPhaseAdvance(2:(1 + N/2)) = (2*%pi*hop)./(N./(1:(N/2)));

// Phase accumulator
// Preset to phase of first frame for perfect reconstruction
// in case of 1:1 time scaling
//ph = angle(b(:,1));
phase = angle(stftMatrix(:,1));

// Append a 'safety' column on to the end of stftMatrix to avoid problems 
// taking *exactly* the last frame (i.e. 1*stftMatrix(:,cols)+0*stftMatrix(:,cols+1))
stftMatrix = [stftMatrix,zeros(rows,1)];

interpolatedFFTIndx = 1;
for interpolateLocation = interpolateLocations
  // Grab the two columns of stftMatrix
  leftAndRightFFT = stftMatrix(:,floor(interpolateLocation)+[1 2]);
  rightFTWeight = interpolateLocation - floor(interpolateLocation);
  interpolatedFFTMag = (1-rightFTWeight)*abs(leftAndRightFFT(:,1)) + rightFTWeight*(abs(leftAndRightFFT(:,2)));
  interpolatedSTFTMatrix(:,interpolatedFFTIndx) = interpolatedFFTMag .* exp(%i*phase);
  interpolatedFFTIndx = interpolatedFFTIndx+1;
  
  // calculate phase advance
  phaseAdvance = angle(leftAndRightFFT(:,2)) - angle(leftAndRightFFT(:,1)) - expectedPhaseAdvance';
  // Reduce to -pi:pi range
  phaseAdvanceNormalized = phaseAdvance - 2 * %pi * round(phaseAdvance/(2*%pi));
  // Cumulate phase, ready for next frame
  phase = phase + expectedPhaseAdvance' + phaseAdvanceNormalized;
end
