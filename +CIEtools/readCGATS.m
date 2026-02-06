function cgats = readCGATS(filename, etp)
%READCGATS Read an ASCII CGATS data file
%   cgats = readCGATS(filename)
%   cgats = readCGATS(filename, expected_type)
%  cgats structure will have the following format
%  cgats.fmt = array of strings containing the data formats
%  cgats.headers = unparsed lines of the file before BEGIN_DATA
%  There will also be a property named after each format string
%    which is a column vector of data
%
%  For IDMS v1.3+ files, additional fields are returned:
%  cgats.IDMS13 = true/false indicating IDMS v1.3+ format
%  cgats.display = 'EMISSIVE' or 'REFLECTIVE' (for IDMS v1.3+ files)
%
%  expected_type (optional) - For IDMS files, validate against this type
%    (e.g., 'CGE_MEASUREMENT' or 'CGE_ENVELOPE')

% some constants for IDMS v1.3+ support
VER = 'IDMS_VERSION';
TPS = {'CGE_MEASUREMENT','CGE_ENVELOPE'};

%open and read all lines of the file to a cell array
f = fopen(filename);
s = textscan(f,'%s','Delimiter','\n');
fclose(f);

% strip whitespace and remove empty lines
s = strtrim(s{1});
s = s(~cellfun(@isempty,s));

% check mandatory headers:
% - the CGATS version number - must be in the first line of the file.
i = find(strncmp(s,'CGATS',5));
if isempty(i)
    error('Invalid file, missing "CGATS" header');
end
if i(1)>1
    error('Invalid file, the "CGATS" header MUST be on the first line');
end
ver = sscanf(s{i(1)},'CGATS.%d');
if isempty(ver) || ~any(ver == 17)
    error('Invalid CGATS version, must be CGATS.17');
end

% check for IDMS version header, assume 1.0 if not present
i = find(strncmp(s,VER,12));
if ~isempty(i)
    idms_ver = sscanf(s{i(1)},'IDMS_VERSION %f');
else
    idms_ver = 1.0;
end
is_IDMS13 = idms_ver >= 1.3;

if is_IDMS13
    % IDMS v1.3+ files have additional mandatory headers

    % - the format version.  Must equal 2
    i = find(strncmp(s,'FORMAT_VERSION',14));
    if isempty(i)
        error('Error in CGATS file, missing header FORMAT_VERSION');
    end
    fmt_ver = sscanf(s{i(1)},'FORMAT_VERSION %d');
    if fmt_ver ~= 2
        error('Error in CGATS file, FORMAT_VERSION should equal 2');
    end

    % must have a file type that matches requirements
    i = find(strncmp(s,'IDMS_FILE_TYPE',14));
    if isempty(i)
        error('Error in CGATS file, missing header IDMS_FILE_TYPE');
    end
    itp = i(1);
    tp = sscanf(s{itp},'IDMS_FILE_TYPE %s');
    if ~any(strcmp(tp, TPS))
        error('Error in CGATS file, IDMS_FILE_TYPE should be CGE_MEASUREMENT or CGE_ENVELOPE');
    end
    if nargin>1 && ~strcmp(tp, etp)
        error(['wrong type of file, should be ',etp]);
    end

    % the display type must be stated
    i = find(strncmp(s,'CGV_DISPLAY_TYPE',16));
    if isempty(i)
        error('Error in CGATS file, missing header CGV_DISPLAY_TYPE');
    end
    d_tp = sscanf(s{i(1)},'CGV_DISPLAY_TYPE %s');
    if ~any(strcmp(d_tp, {'EMISSIVE','REFLECTIVE'}))
        error('Error in CGATS file, CGV_DISPLAY_TYPE should be EMISSIVE or REFLECTIVE');
    end
else
    % for IDMS versions < 1.3 (or no IDMS_VERSION header), only emissive is supported
    d_tp = 'EMISSIVE';
    itp=0;
end

%find the important headers which will be needed later
bdf = find(strcmp(s,'BEGIN_DATA_FORMAT'));
edf = find(strcmp(s,'END_DATA_FORMAT'));
bd = find(strcmp(s,'BEGIN_DATA'));
ed = find(strcmp(s,'END_DATA'));
if any(cellfun(@isempty,{bdf,edf,bd,ed}))
    error('invalid CGATS file, missing required data section headers');
end

%get the data set count and check it against the data rows in the file
i = find(strncmp(s,'NUMBER_OF_SETS',14));
if isempty(i)
    error('Error in CGATS file, missing header NUMBER_OF_SETS');
end
nos = i(1);
N = sscanf(s{nos},'NUMBER_OF_SETS %d');

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
cgats.IDMS13=is_IDMS13;
cgats.display=d_tp;
hdrs=[1:bdf-1,edf+1:bd-1];
cgats.headers=s(hdrs(hdrs~=nos & hdrs~=itp));
cgats.filename=filename;

end
