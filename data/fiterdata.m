clc
clear

files = dir('*.mat');
passband_freq = 10; %passband frequency (Hz)
sampling_freq = 1000; %data sampling frequency (Hz)
decimation = 10; %decimation
excludedVars = {'time', 'sample'}; %do not filter these

%design filder
digital_filter = designfilt('lowpassfir',...                         % finite-impulse-response low-pass digital filter: suitable for offline processing
                           'PassbandFrequency',passband_freq,...    % passband at which the filter gain is roughly 0dB
                           'StopbandFrequency',2*passband_freq,...  % frequency at which the filter gain is -60dB
                           'PassbandRipple',0.1, ...                % ripple in the passband in dB
                           'DesignMethod','kaiserwin',...           % design method for the filter: nice b/c i the passband the gain is constant and decreases quickly after the passband frequency
                           'SampleRate', sampling_freq);           % sampling rate of raw data
% You can use 'fvtool(digital_filter)' to plot the filter response

% filterig and decimation
for k = 1 : numel(files)
    file = files(k);
    filedata = load([file.folder filesep file.name]);
    if ~isfield(filedata, "time")
        continue;
    end
    fprintf("Filtering and decimating file %s...", file.name)
    datafiltered = filter_and_decimate(filedata, digital_filter, decimation, excludedVars);
    fprintf("Done\n")
    fprintf("Saving file %s...", file.name)
    [fpath, fname, fext] = fileparts([file.folder filesep file.name]);
    save([fpath filesep fname '-filt' fext], '-struct', 'datafiltered');
    fprintf("Done\n")
end

%function
function dataout = filter_and_decimate(data, digital_filter, decimation, excludedVars)
    vars = fieldnames(data);
    % filtering
    for k = 1 : numel(vars)
        var = data.(vars{k});
        if any(strcmp(vars{k}, excludedVars)) %skip excludedVars
            dataout.(vars{k}) = var;
            continue;
        end
        dataout.(vars{k}) = filtfilt(digital_filter, var);
    end
    %decimation
    for k = 1 : numel(vars)
        dataout.(vars{k}) = dataout.(vars{k})(1:decimation:end,:);
    end
end




