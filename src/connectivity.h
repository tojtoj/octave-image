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

#include <stdexcept>

#include <octave/oct.h>

namespace octave
{
  namespace image
  {
    class connectivity
    {
      public:
        connectivity ();

        //! Will throw if val is bad
        connectivity (const octave_value& val);
        connectivity (const boolNDArray& mask_arg);
        connectivity (const octave_idx_type& conn);
        connectivity (const octave_idx_type& ndims, const std::string& type);

        boolNDArray mask;

        // For a matrix of size `size', what are the offsets for all of its
        // connected elements (will have negative and positive values).
        Array<octave_idx_type> neighbourhood (const dim_vector& size) const;
        Array<octave_idx_type> deleted_neighbourhood (const dim_vector& size) const;
        Array<octave_idx_type> positive_neighbourhood (const dim_vector& size) const;
        Array<octave_idx_type> negative_neighbourhood (const dim_vector& size) const;

      private:
        void ctor (const boolNDArray& mask_arg);
        void ctor (const octave_idx_type& conn);

        //! Like octave_value::double_value() but actually checks if scalar.
        static double double_value (const octave_value& val);

        //! Like octave_value::bool_array_value() but actually checks if
        //! all values are zeros and one.
        static boolNDArray bool_array_value (const octave_value& val);

        //! Like Array::ndims() but will return 1 dimension for ColumnVector
        static octave_idx_type ndims (const dim_vector& d);
        template<class T>
        static octave_idx_type ndims (const Array<T>& a);
    };

    class invalid_conversion : public std::invalid_argument
    {
      public:
        invalid_conversion (const std::string& what_arg)
          : std::invalid_argument (what_arg) { }
    };

    class invalid_connectivity : public octave::image::invalid_conversion
    {
      public:
        invalid_connectivity (const std::string& what_arg)
          : octave::image::invalid_conversion (what_arg) { }
    };
  }
}

#endif
