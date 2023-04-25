% spectrogram generator
tic
files = dir('*.wav')
filename = string(files(1).name);
audioinfo(filename)
parameters = regexp(erase(filename, '.wav'), '_', 'split');
parameters = parameters(~cellfun('isempty',parameters))

% get callsign from filename:
Call = string(parameters{1})
% Get timeslip and start time from filename:
qux = [1:9 -70 1:3 -12:0];
slipnum = double(char(parameters{2})) - 64; 
slip = qux(slipnum);
foo = convertCharsToStrings(regexp(parameters{3}, '-', 'split')); bar = convertCharsToStrings(regexp(parameters{4}, '-', 'split'));
SHIFT = hours(slip);
START = datetime([double(foo) double(bar)]) + SHIFT;


[y,Fs] = audioread(filename);

instfreq(y, Fs, 'FrequencyLimits', [995 1005]); %show spectrogram with estimated freq

est=instfreq(y, Fs, 'FrequencyLimits', [995 1005]); %record estimated freq
min(est)
max(est)
toc