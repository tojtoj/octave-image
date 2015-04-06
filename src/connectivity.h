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

#include <string>
#include <stdexcept>

#include <octave/oct.h>
#include <lo-ieee.h>  // octave_Inf

namespace octave
{
  namespace image
  {
    class connectivity
    {
      public:
        connectivity () = default;

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

        template<class T, class P>
        T create_padded (const T& image, const P& val) const;

        template<class T>
        void unpad (T& image) const;

        template<class P>
        static P min_value (void);

        static Array<octave_idx_type> padding_lengths (const dim_vector& size,
                                                       const dim_vector& padded_size);

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

// Templated methods

template<class T, class P>
T
octave::image::connectivity::create_padded (const T& image, const P& val) const
{
  const octave_idx_type pad_ndims = std::min (mask.ndims (), image.ndims ());

  Array<octave_idx_type> idx (dim_vector (image.ndims (), 1), 0);
  dim_vector padded_size = image.dims ();
  for (octave_idx_type i = 0; i < pad_ndims; i++)
    {
      padded_size(i) += 2;
      idx(i) = 1;
    }

  T padded (padded_size, val);

  // padded(2:end-1, 2:end-1, ..., 2:end-1) = BW
  padded.insert (image, idx);
  return padded;
}

template<class T>
void
octave::image::connectivity::unpad (T& image) const
{
  const octave_idx_type pad_ndims = std::min (mask.ndims (), image.ndims ());
  const dim_vector padded_size = image.dims ();

  Array<idx_vector> inner_slice (dim_vector (image.ndims (), 1));
  for (octave_idx_type i = 0; i < pad_ndims ; i++)
    inner_slice(i) = idx_vector (1, padded_size(i) - 1);
  for (octave_idx_type i = pad_ndims; i < image.ndims (); i++)
    inner_slice(i) = idx_vector (0, padded_size(i));

  image = image.index (inner_slice);
  return;
}

template<class P>
P
octave::image::connectivity::min_value (void)
{
  if (typeid (P) == typeid (bool))
    return false;
  else
    return P(-octave_Inf);
}

#endif
