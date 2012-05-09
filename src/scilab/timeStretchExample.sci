
//load files
currentDirec = pwd();
exec(currentDirec + '\stftInterpolate.sci', -1);
exec(currentDirec + '\timeStretch.sci', -1);
exec(currentDirec + '\angle.sci', -1);
exec(currentDirec + '\istft.sci', -1);
exec(currentDirec + '\stft.sci', -1);


stacksize('max'); //allows big files to be opened

recordingFile = 'your sound file.wav';

[recording, waveInfo] = loadwave(recordingFile);
fs = waveInfo(3);

threeSecondSample = recording(1:fs*3);

stretchFactor = 3;

ftLength = 1024;

nineSecondSample = timeStretch(threeSecondSample, stretchFactor, ftLength);

sound(threeSecondSample, fs);

//same pitch as original but time-length is three times as long
sound(nineSecondSample, fs);

//same time-length as original but three times as high a pitch
sound(nineSecondSample, fs*3)