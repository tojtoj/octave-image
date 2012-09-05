// Copyright (C) 2011 Jordi Gutiérrez Hermoso <jordigh@octave.org>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

// union-find.h++

#include <vector>

struct voxel{
  octave_idx_type rank;
  octave_idx_type parent;
};

class union_find
{

private:
  std::vector<voxel*> voxels;

public:

  union_find (octave_idx_type s) : voxels (s, NULL) {};

  ~union_find ()
  {
    for (auto v = voxels.begin(); v != voxels.end(); v++)
      delete *v;
  }

  //Give the root representative id for this object, or insert into a
  //new set if none is found
  octave_idx_type find (octave_idx_type idx)
  {

    //Insert new element if not found
    auto v = voxels[idx];
    if (!v)
      {
        voxel* new_voxel = new voxel;
        new_voxel->rank = 0;
        new_voxel->parent = idx;
        voxels[idx] = new_voxel;
        return idx;
      }

    voxel* elt = v;
    if (elt->parent != idx)
      elt->parent = find (elt->parent);

    return elt->parent;
  }

  //Given two objects, unite the sets to which they belong
  void unite (octave_idx_type idx1, octave_idx_type idx2)
  {
    octave_idx_type root1 = find (idx1), root2 = find (idx2);

    //Check if any union needs to be done, maybe they already are
    //in the same set.
    voxel *v1 = voxels[root1], *v2 = voxels[root2];
    if (root1 != root2)
      {
        if ( v1->rank > v2->rank)
          v1->parent = root2;
        else if (v1->rank < v2->rank)
          v2->parent = root1;
        else
          {
            v2->parent = root1;
            v1->rank++;
          }
      }
  }

  std::vector<octave_idx_type> get_ids()
  {
    std::vector<octave_idx_type> ids;

    for (size_t i = 0; i < voxels.size (); i++)
      if (voxels[i])
        ids.push_back (i);

    return ids;
  };

};
