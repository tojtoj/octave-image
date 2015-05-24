// Copyright (C) 2015 Carnë Draug <carandraug@octave.org>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <octave/error.h>

#include "connectivity.h"
using namespace octave::image;

DEFUN_DLD(watershed, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Function File} {} watershed (@var{im})\n\
@deftypefnx {Function File} {} watershed (@var{im}, @var{conn})\n\
Compute watershed transform.\n\
\n\
Computes by immersion\n\
\n\
Element connectivity @var{conn}, to define the size of objects, can be\n\
specified with a numeric scalar (number of elements in the neighborhood):\n\
\n\
@table @samp\n\
@item 4 or 8\n\
for 2 dimensional matrices;\n\
@item 6, 18 or 26\n\
for 3 dimensional matrices;\n\
@end table\n\
\n\
or with a binary matrix representing a connectivity array.  Defaults to\n\
@code{conndef (ndims (@var{bw}), \"maximal\")} which is equivalent to\n\
@var{conn} of 8 and 26 for 2 and 3 dimensional matrices respectively.\n\
\n\
@seealso{bwdist, bwlabeln, regionprops}\n\
@end deftypefn")
{
  const octave_idx_type nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return octave_value_list ();
    }

  connectivity conn;
  try
    {
      conn = (nargin > 1) ? connectivity (args(1)) :
                            connectivity (args(0).ndims (), "maximal");
    }
  catch (invalid_connectivity& e)
    {
      error ("bwconncomp: MASK %s", e.what ());
      return octave_value_list ();
    }

  return octave_value ();
}

/*
## Some simple tests that will check the multiple ways to measure
## distances (comes to light on plateus)
%!test
%! ex = tril (ones (50), -1) + triu (repmat (2, [50 50]), 2);
%! ex(1, 1) = 1;
%! ex(end, end) = 1;
%!
%! in = ones (50);
%! in(end,1) = 0;
%! in(1,end) = 0;
%! assert (watershed (in), ex)

%!test
%! ex = tril (ones (49), -1) + triu (repmat (2, [49 49]), 2);
%! ex(1, 1) = 1;
%! ex(end, end) = 1;
%!
%! in = ones (49);
%! in(end,1) = 0;
%! in(1,end) = 0;
%! assert (watershed (in), ex)
%!
%! c = (fspecial ('disk', 5) > 0) + 1;
%! in(20:30,20:30) = c;
%! c = (fspecial ('disk', 4) > 0) + 2;
%! in(21:29,21:29) = c;
%! assert (watershed (in), ex)

%!test
%! ex = tril (ones (49), -1) + triu (repmat (2, [49 49]), 2);
%! ex(1:28,1:28) = (tril (ones (28) ,7) + triu (repmat (2, [28 28]), 10));
%! ex(1,9) = 1;
%! ex(end,end) = 1;
%! ex(20:29, 29) = 0;
%!
%! in = ones (49);
%! in(end,1) = 0;
%! in(1,end) = 0;
%! c = (fspecial ("disk", 5) > 0) + 1;
%! in(1:11,38:48) = c;
%!
%! assert (watershed (in), ex)

## See http://perso.esiee.fr/~info/tw/index.html for a page on topological
## watershed.  The following test cases were taken from a powerpoint
## presentation there http://perso.esiee.fr/~info/tw/isis03b.ppt
## "A topological approach to watersheds". Presentation made by Gilles Bertrand
## at the ISIS Workshop on Mathematical Morphology in Paris, France, 2003.
##
## From that presentation, the algorithm we must implement for Matlab
## compatibility is named "Meyer".

%!test
%! im = [
%!     3     4     5     6     0
%!     2     3     4     5     6
%!     1     2     3     4     5
%!     0     1     2     3     4
%!     1     0     1     2     3];
%!
%! labeled8 = [
%!     1     1     1     0     2
%!     1     1     1     0     0
%!     1     1     1     1     1
%!     1     1     1     1     1
%!     1     1     1     1     1];
%! labeled4 = [
%!     1     1     1     0     3
%!     1     1     1     0     0
%!     1     1     0     2     2
%!     1     0     2     2     2
%!     0     2     2     2     2];
%! labeled_weird = [
%!     1     1     1     0     2
%!     1     1     1     1     0
%!     1     1     1     1     1
%!     1     1     1     1     1
%!     1     1     1     1     1];
%!
%! assert (watershed (im), labeled8);
%! assert (watershed (im, 8), labeled8);
%! assert (watershed (im, 4), labeled4);
%! assert (watershed (im, [1 1 0; 1 1 1; 0 1 1]), labeled_weird);

%!test
%! im = [
%!     2     3    30     2
%!     3    30     3    30
%!   255    31    30     4
%!     2   255    31    30
%!     1     2   255     5];
%!
%! labeled8 = [
%!     1     1     0     3
%!     1     1     0     3
%!     0     0     0     0
%!     2     2     0     4
%!     2     2     0     4];
%! labeled4 = [
%!     1     1     0     4
%!     1     0     3     0
%!     0     2     0     5
%!     2     2     2     0
%!     2     2     0     6];
%! labeled_weird = [
%!     1     1     0     3
%!     1     1     1     0
%!     0     1     1     1
%!     2     0     0     0
%!     2     2     0     4];
%!
%! assert (watershed (im), labeled8);
%! assert (watershed (im, 8), labeled8);
%! assert (watershed (im, 4), labeled4);
%! assert (watershed (im, [1 1 0; 1 1 1; 0 1 1]), labeled_weird);

%!test
%! im = [
%!    2    2    2    2    2    2    2
%!    2    2   30   30   30    2    2
%!    2   30   20   20   20   30    2
%!   40   40   20   20   20   40   40
%!    1   40   20   20   20   40    0
%!    1    1   40   20   40    0    0
%!    1    1    1   20    0    0    0];
%!
%! labeled8 = [
%!    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1
%!    0    0    0    0    0    0    0
%!    2    2    2    0    3    3    3
%!    2    2    2    0    3    3    3
%!    2    2    2    0    3    3    3];
%! labeled4 = [
%!    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1
%!    0    1    1    1    1    1    0
%!    2    0    1    1    1    0    3
%!    2    2    0    1    0    3    3
%!    2    2    2    0    3    3    3];
%! labeled_weird = [
%!    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1
%!    0    1    1    0    0    0    0
%!    2    0    0    0    3    3    3
%!    2    2    0    3    3    3    3
%!    2    2    2    0    3    3    3];
%!
%! assert (watershed (im), labeled8);
%! assert (watershed (im, 8), labeled8);
%! assert (watershed (im, 4), labeled4);
%! assert (watershed (im, [1 1 0; 1 1 1; 0 1 1]), labeled_weird);

%!test
%! im = [
%!   40   40   40   40   40   40   40   40   40   40   40   40   40
%!   40    3    3    5    5    5   10   10   10   10   15   20   40
%!   40    3    3    5    5   30   30   30   10   15   15   20   40
%!   40    3    3    5   30   20   20   20   30   15   15   20   40
%!   40   40   40   40   40   20   20   20   40   40   40   40   40
%!   40   10   10   10   40   20   20   20   40   10   10   10   40
%!   40    5    5    5   10   40   20   40   10   10    5    5   40
%!   40    1    3    5   10   15   20   15   10    5    1    0   40
%!   40    1    3    5   10   15   20   15   10    5    1    0   40
%!   40   40   40   40   40   40   40   40   40   40   40   40   40];
%!
%! labeled8 = [
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    0    0    0    0    0    0    0    0    0    0    0    0    0
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3];
%! labeled4 = [
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    0    0    0    0    1    1    1    1    1    0    0    0    0
%!    2    2    2    2    0    1    1    1    0    3    3    3    3
%!    2    2    2    2    2    0    1    0    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3];
%! labeled_weird = [
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    1    1    1    1    1    1    1    1    1    1    1    1    1
%!    0    0    0    0    1    1    0    0    0    0    0    0    0
%!    2    2    2    2    0    0    0    3    3    3    3    3    3
%!    2    2    2    2    2    0    3    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3
%!    2    2    2    2    2    2    0    3    3    3    3    3    3];
%!
%! assert (watershed (im), labeled8);
%! assert (watershed (im, 8), labeled8);
%! assert (watershed (im, 4), labeled4);
%! assert (watershed (im, [1 1 0; 1 1 1; 0 1 1]), labeled_weird);
*/
