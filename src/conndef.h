// Copyright (C) 2014 Carnë Draug <carandraug@octave.org>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see
// <http://www.gnu.org/licenses/>.

#ifndef OCTAVE_IMAGE_CONNDEF
#define OCTAVE_IMAGE_CONNDEF

#include <octave/oct.h>

namespace octave
{
  namespace image
  {
    class connectivity
    {
      public:
        connectivity ();
        connectivity (const octave_idx_type& conn);
        connectivity (const octave_idx_type& ndims, const std::string& type);

        boolNDArray mask;

        // For a matrix of size `size', what are the offsets for all of its
        // connected elements (will have negative and positive values).
        Array<octave_idx_type> offsets (const dim_vector& size) const;

        static bool validate (const boolNDArray& mask);
        static bool validate (const double& conn);
    };
  }
}

#endif
