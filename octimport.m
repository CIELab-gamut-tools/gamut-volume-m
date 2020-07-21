function octimport(varargin) 
 narginchk(1, inf); 
 for i=1:nargin 
   [names, funcs] = import1(varargin{i}); 
   for j=1:length(names) 
     assignin("caller", names{j}, funcs{j}); 
   end
 end
end

function [names, funcs] = import1(pkgname) 
 pkgname_parts = strsplit(pkgname, "."); 
 if length(pkgname_parts) > 2 
   error("invalid package name: %s", pkgname); 
 end
 pkgpath = locatepkg(pkgname_parts{1}); 
 unwind_protect 
   cwd = pwd; 
   cd(pkgpath); 
   names = what(pwd); 
   names = [names.m(:)', names.mex(:)', names.oct(:)']; 
   names = cellfun(@stripExtension, names, "UniformOutput", false); 
   if length(pkgname_parts) == 2 
     if any(strcmp(pkgname_parts{2}, names)) 
       names = pkgname_parts(2); 
     else 
       error("function `%s' not found in package `%s'", ... 
         pkgname_parts{2}, pkgname_parts{1}); 
     end
   end
   funcs = cellfun(@str2func, names, "UniformOutput", false); 
 unwind_protect_cleanup 
   cd(cwd); 
 end_unwind_protect 
end

function pkgpath = locatepkg(pkgname) 
 pathdirs = strsplit(path, pathsep); 
 for iPath=1:length(pathdirs) 
   pkgpath = [pathdirs{iPath} filesep "+" pkgname]; 
   if exist(pkgpath, "dir") 
     return; 
   end
 end
 error("package `%s' cannot be located in the path", pkgname); 
end

function fileName = stripExtension(fileName) 
 dotIndices = strfind(fileName, "."); 
 fileName = fileName(1:(dotIndices(end)-1)); 
end
