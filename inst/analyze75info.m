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
%% @deftypefn {Function File} {@var{header} = } analyze75info(@var{filename})
%% Read the header of an Analyze file.
%%
%% FILENAME is a string (giving the filename).
%% @end deftypefn

function header = analyze75info(varargin);
%--------------------------------------------------------------------------

%--------------
% Check filename
%--------------

filename = varargin{1};

if exist('filename','var')==1 && exist(filename,'dir')==7
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
% Check the byteorder
%--------------

byteorder = 'ieee-le';

for loopN = 2:nargin-1
  if ischar(varargin{loopN}) && strcmpi(varargin{loopN})=='ByteOrder'
    if ischar(varargin{loopN+1}) && ( strcmpi(varargin{loopN+1})=='ieee-be' || strcmpi(varargin{loopN+1})=='b' )
      byteorder = 'ieee-be';
      disp('Code does not yet work for big-endian files.')
    else
      byteorder = 'ieee-le';
    end
  end
end

%--------------
% Read the file
%--------------

header = READ_hdr(fileprefix);


end %function
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function [header] = READ_hdr(fileprefix)

%----------------------------
% Gather the header info
%----------------------------

dirdata                 = dir([fileprefix,'.hdr']);

header.Filename         = [fileprefix,'.hdr'];
header.FileModDate      = dirdata.date;
header.Format           = 'Analyze';
header.FormatVersion    = '7.5';
header.ColorType        = 'grayscale';
header.ByteOrder        = 'ieee-le';

fidH                    = fopen([fileprefix,'.hdr']);

header.HdrFileSize      = fread(fidH,1,'int32');
header.HdrDataType      = char(fread(fidH,10,'char'))';
header.DatabaseName     = char(fread(fidH,18,'char'))';
header.Extents          = fread(fidH,1,'int32');
header.SessionError     = fread(fidH,1,'int16');
header.Regular          = char(fread(fidH,1,'char'));
unused                  = char(fread(fidH,1,'char'));
unused                  = fread(fidH,1,'int16');
header.Dimensions       = zeros(size(1,4));
header.Dimensions(1)    = fread(fidH,1,'int16');
header.Dimensions(2)    = fread(fidH,1,'int16');
header.Dimensions(3)    = fread(fidH,1,'int16');
header.Dimensions(4)    = fread(fidH,1,'int16');
unused                  = fread(fidH,3,'int16');
header.VoxelUnits       = char(fread(fidH,4,'char'))';
header.CalibrationUnits = char(fread(fidH,8,'char'))';
unused                  = fread(fidH,1,'int16');

datatype = fread(fidH,1,'int16');
if datatype==0 
  header.ImgDataType = 'DT_UNKNOWN';
elseif datatype==1
  header.ImgDataType = 'DT_BINARY';
elseif datatype==2
  header.ImgDataType = 'DT_UNSIGNED_CHAR';
elseif datatype==4
  header.ImgDataType = 'DT_SIGNED_SHORT';
elseif datatype==8
  header.ImgDataType = 'DT_SIGNED_INT';
elseif datatype==16
  header.ImgDataType = 'DT_FLOAT';
elseif datatype==32
  header.ImgDataType = 'DT_COMPLEX';
elseif datatype==64
  header.ImgDataType = 'DT_DOUBLE';
elseif datatype==128
  header.ImgDataType = 'DT_RGB';
elseif datatype==255
  header.ImgDataType = 'DT_ALL';
end

header.BitDepth           = fread(fidH,1,'int16');
unused                    = fread(fidH,1,'int16');
unused                    = fread(fidH,1,'float');
header.PixelDimensions    = zeros(1,3);
header.PixelDimensions(1) = fread(fidH,1,'float');
header.PixelDimensions(2) = fread(fidH,1,'float');
header.PixelDimensions(3) = fread(fidH,1,'float');
unused                    = fread(fidH,4,'float');
header.VoxelOffset        = fread(fidH,1,'float');
unused                    = fread(fidH,3,'float');
header.CalibrationMax     = fread(fidH,1,'float');
header.CalibrationMin     = fread(fidH,1,'float');
header.Compressed         = fread(fidH,1,'float');
header.Verified           = fread(fidH,1,'float');
header.GlobalMax          = fread(fidH,1,'int32');
header.GlobalMin          = fread(fidH,1,'int32');
header.Descriptor         = char(fread(fidH,80,'char'))';
header.AuxFile            = char(fread(fidH,24,'char'))';
header.Orientation        = char(fread(fidH,1,'char'))';
header.Originator         = char(fread(fidH,10,'char'))';
header.Generated          = char(fread(fidH,10,'char'))';
header.Scannumber         = char(fread(fidH,10,'char'))';
header.PatientID          = char(fread(fidH,10,'char'))';
header.ExposureDate       = char(fread(fidH,10,'char'))';
header.ExposureTime       = char(fread(fidH,10,'char'))';
unused                    = char(fread(fidH,3,'char'))';
header.Views              = fread(fidH,1,'int32');
header.VolumesAdded       = fread(fidH,1,'int32');
header.StartField         = fread(fidH,1,'int32');
header.FieldSkip          = fread(fidH,1,'int32');
header.OMax               = fread(fidH,1,'int32');
header.OMin               = fread(fidH,1,'int32');
header.SMax               = fread(fidH,1,'int32');
header.SMin               = fread(fidH,1,'int32');

header.Width              = header.Dimensions(1);
header.Height             = header.Dimensions(2);

fclose(fidH);

%----------------------------
% Check the img filesize
%----------------------------

fidI = fopen([fileprefix,'.img']);
fseek(fidI,0,1);
header.ImgFileSize = ftell(fidI);
fclose(fidI);

end %function
%--------------------------------------------------------------------------

