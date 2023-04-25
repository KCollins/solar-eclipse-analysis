% Script to take eclipse wav data and convert to tall timetables
% Kristina Collins KD8OXT, 31 January 2021, kvc2@case.edu

close all; clear all; clc
datetime.setDefaultFormats('default','yyyy-MM-dd''T''HH:mmXXX')


% List of filenames in folder
files = dir('*.wav')

% filename= 'AB4EJ_R__2020-10-31_12-50-10.wav'
tic
for i=1:size(files, 1)
    filename = string(files(i).name);
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
% y = decimate(y, 10000);
% if y >10000
%     y = y(1:10000)
% end % just look at the beginning of the file so I don't drive myself crazy
audio = timetable(y, 'SampleRate', Fs);
ifq = timetable(instfreq(y, Fs), 'SampleRate', Fs);
audio.Properties.StartTime = START; 
ifq.Properties.StartTime = START;


% make an FFT:
% Fs = 8000;            % Sampling frequency (already set above)            
T = 1/Fs;             % Sampling period       
L = size(audio, 1);   % Length of signal
t = (0:L-1)*T;        % Time vector


Y = fft(audio.y);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
% figure, 
plot(f,P1) 
title(strcat("Single-Sided Amplitude Spectrum for ", Call))
xlabel('f (Hz)')
ylabel('|P1(f)|')

% Create a big ol' timetable with all our audio data: 
audio.Properties.VariableNames=Call;
if exist('data') ==1
    if any(strcmp(Call, data.Properties.VariableNames))
        fprintf('We already have some data from this station...')
        audio = vertcat(audio, timetable(data.Time, data{:, Call}, 'VariableNames', Call));
        data=removevars(data, Call); %delete the duplicate
    end
    data = synchronize(data, audio);
else
    data = tall(audio);
end

% Do some frequency estimation here
ifq.Properties.VariableNames=Call;
if exist('freqtable') ==1
    if any(strcmp(Call, freqtable.Properties.VariableNames))
        fprintf('We already have a frequency estimate from this station...')
        ifq = vertcat(ifq, timetable(freqtable.Time, freqtable{:, Call}, 'VariableNames', Call));
        freqtable=removevars(freqtable, Call); %delete the duplicate
    end
    freqtable = synchronize(freqtable, ifq);
else
    freqtable = tall(ifq);
end

end
toc
%% Saving timetable - takes FOREVER
 write("talltable\", data);
ds = datastore("talltable\"); 
% %later, to reconstruct, use 
% data = tall(ds);
% summary(data)


% figure, subplot(1, 2, 1), stackedplot(data(:, 1:19))
% subplot(1, 2, 2), stackedplot(data(:, 20:37))
quux = string(data.Properties.VariableNames);
strcat(quux(:), ',')

% Pull data and make plots


