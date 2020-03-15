function cgats = readCGATS(filename)
%READCGATS Read an ASCII CGATS data file
%   [RGB,XYZ,title] = readCGATS(filename)
%       read the file, parse the contents and return the data and

% This is a VERY simplistic implementation, it will be improved to properly
% parse the data file.
% For now it just looks for data lines with seven numbers and goes from
% there.
file = fopen(filename);
Data={[]};
while(isempty(Data{1}))
    fgetl(file);
    Data = textscan(file,'%d %f %f %f %f %f %f');
end
fclose(file);
cgats=[];
cgats.RGB=[Data{2} Data{3} Data{4}];                  
cgats.XYZ=[Data{5} Data{6} Data{7}];
[~,title,~]=fileparts(filename);
title=char(title);
title(title<32 | title>127)='-';
cgats.title=title;
end

