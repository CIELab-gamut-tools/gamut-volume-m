function cgats = readCGATS(filename)
%READCGATS Read an ASCII CGATS data file
%   cgats = readCGATS(filename)
%  cgats structure will have the following format
%  cgats.fmt = array of strings containing the data formats
%  cgats.headers = unparsed lines of the file before BEGIN_DATA
%  There will also be a property named after each format string
%    which is a column vector of data

%open and read all lines of the file to a cell array
f = fopen(filename);
s = textscan(f,'%s','Delimiter','\n');
s = s{1};
fclose(f);

%check the version number - must be in the first line of the file.
ver = sscanf(s{1},'CGATS.%d\n',1);
if isempty(ver) || ver<17
    error('unsuported file format');
end

%find the important headers which will be needed later
bdf = find(strcmp(s,'BEGIN_DATA_FORMAT'));
edf = find(strcmp(s,'END_DATA_FORMAT'));
bd = find(strcmp(s,'BEGIN_DATA'));
ed = find(strcmp(s,'END_DATA'));
nos = find(~cellfun('isempty',strfind(s,'NUMBER_OF_SETS')));
if any(cellfun(@isempty,{bdf,edf,bd,ed,nos})), error('invalid CGATS file'); end

%get the data set count and check it against the data rows in the file
N = sscanf(s{nos},'NUMBER_OF_SETS %d',1);
if ed-bd-1 ~= N, error('NUMER_OF_SETS does not match the data count'); end

%get all of the format strings in a cell array and the count of them
fmt = strsplit(strjoin(s(bdf+1:edf-1)));
M = length(fmt);

%read all the data into one matrix
try
    data = zeros(N, M);
    for n=1:N
        data(n,:)=sscanf(s{bd+n},'%g')';
    end
catch
    error('Error reading data table - unexpected entry or column count');
end

%build an array of data properties
flds = [fmt; mat2cell(data,N,ones(1,M))];

%check for format strings of the form ABC_A, e.g. RGB_R
%if present, combine them into ABC properties
i=cellfun(@(s) ~isempty(regexp(s,'[A-Z]{3}_[A-Z]','ONCE')),fmt);
keys=cell2mat(fmt(i)');
umkeys=unique(keys(:,1:3),'rows');
K=size(umkeys,1);
nflds = cell(2,K);
for k=1:K
   d=zeros(N,3);
   for m=1:3
       key=[umkeys(k,:) '_' umkeys(k,m)];
       d(:,m)=data(:,strcmp(fmt,key));
   end
   nflds(:,k) = {umkeys(k,:),d};
end
%remote the source fields and add in the composite ones
flds=[flds(:,~i),nflds];

%then build the cgats structure to return
cgats=struct(flds{:});
cgats.fmt=fmt;
hdrs=[1:bdf-1,edf+1:bd-1];
cgats.headers=s(hdrs(hdrs~=nos));
cgats.filename=filename;

end


