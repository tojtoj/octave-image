%% Copyright (C) 2012 Adam H Aitkenhead <adamaitkenhead@hotmail.com>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{image} = } analyze75read(@var{filename})
%% @deftypefnx {Function File} {@var{image} = } analyze75read(@var{structure})
%% Read the image data contained in an Analyze file.
%%
%% FILENAME is a string (giving the filename).
%% Alternatively, STRUCTURE is a structure containing a field `Filename'
%% (such as returned by `analyze75info').
%% @end deftypefn

function data = analyze75read(varargin);
%--------------------------------------------------------------------------

%--------------
% Check filename
%--------------

filename = varargin{1};

if isstruct(filename)==1 && isfield(filename,'Filename')==1
  header   = filename;
  filename = header.Filename;
elseif exist('filename','var')==1 && exist(filename,'dir')==7
  filelist = dir([filename,filesep,'*.hdr']);
  if numel(filelist)==1
    filename = [filename,filesep,filelist.name];
  else
    [filename,filepath] = uigetfile([filename,filesep,'*.hdr'],'Select the input file');
    filename = [filepath,filename];
  end
elseif ( exist('filename','var')==1 && exist(filename,'file')==0 ) || exist('filename','var')==0
  [filename,filepath] = uigetfile('*.hdr','Select the input file');
  filename = [filepath,filename];
end

% Strip the filename of the extension

fileextH = strfind(filename,'.hdr');
fileextI = strfind(filename,'.img');
if isempty(fileextH)==0
  fileprefix = filename(1:fileextH-1);
elseif isempty(fileextI)==0
  fileprefix = filename(1:fileextI-1);
else
  fileprefix = filename;
end

%--------------
% Read the file
%--------------

if exist('header','var')==0
  header = analyze75info(filename);
end

data = READ_img(fileprefix,header);

end %function
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function [data] = READ_img(fileprefix,header)

%----------------------------
% Read the .img file
%----------------------------

fidI = fopen([fileprefix,'.img']);

fseek(fidI,0,-1);

if strcmp(header.ImgDataType,'DT_FLOAT')==1
  datatype = 'single';
else
  datatype = 'double';
end

data    = zeros(header.Dimensions,datatype);
data(:) = fread(fidI,datatype,header.ByteOrder);

fclose(fidI);

%----------------------------
% Rearrange the data
%----------------------------

data = permute(data,[2,1,3]);

end %function
%--------------------------------------------------------------------------


