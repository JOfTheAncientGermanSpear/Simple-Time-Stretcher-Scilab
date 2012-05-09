A simple Time Stretcher in Scilab that uses STFT-based phase vocoding.

This is almost the same as the phase vocoder code created by Dan Ellis:
http://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/

With the following 3 changes
1) Code converted to Scilab from Matlab
2) Variable names changed to make code more readable
3) File/Function name changes
	a) pvoc changed to timeStretch
	b) pvsample changed to stftInterpolate