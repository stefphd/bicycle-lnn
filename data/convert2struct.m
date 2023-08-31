clc

files = dir('*.mat');

for k = 1 : numel(files)
    file = files(k);
    filedata = load([file.folder filesep file.name]);
    if ~isfield(filedata, "testinfo")
        continue;
    end
    datatable = filedata.testinfo.data;
    fprintf("Converting file %s...", file.name)
    datastruct = table2struct(datatable, "ToScalar",true);
    fprintf("Done\n")
    fprintf("Saving file %s...", file.name)
    save([file.folder filesep file.name], '-struct', 'datastruct');
    fprintf("Done\n")
end