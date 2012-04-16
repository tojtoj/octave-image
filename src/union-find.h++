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

#include <unordered_map>
#include <list>

using std::unordered_map;
using std::list;

// T - type of object we're union-finding for
// H - hash for the map
template <typename T, typename H = std::hash<T> >
class union_find
{

//Dramatis personae
private:

  //Each root has rank.
  unordered_map<octave_idx_type, octave_idx_type, H> num_ranks;

  //Each object points to its parent, possibly itself.
  unordered_map<octave_idx_type, octave_idx_type, H> parent_pointers;

  //Represent each object by a number and vice versa.
  unordered_map<octave_idx_type, T, H>      num_to_objects;
  unordered_map<T, octave_idx_type, H>      objects_to_num;

// Act 1
public:

  //Insert a collection of objects
  void insert_objects (const list<T>& objects)
  {
    for (auto i = objects.begin (); i != objects.end (); i++)
      {
        find (*i);
      }
  }


  //Give the root representative id for this object, or insert into a
  //new set if none is found
  octave_idx_type find_id (const T& object)
  {

    //Insert new element if not found
    if (objects_to_num.find (object) == objects_to_num.end () )
      {
        //Assign number serially to objects
        octave_idx_type obj_num = objects_to_num.size ()+1;

        num_ranks[obj_num] = 0;
        objects_to_num[object] = obj_num;
        num_to_objects[obj_num] = object;
        parent_pointers[obj_num] = obj_num;
        return obj_num;
      }

    //Path from this element to its root, we'll build it.
    list<octave_idx_type> path (1, objects_to_num[object]);
    octave_idx_type par = parent_pointers[path.back ()];
    while ( par != path.back () )
      {
        path.push_back (par);
        par = parent_pointers[par];
      }

    //Update everything we've seen to point to the root.
    for (auto i = path.begin (); i != path.end (); i++)
      {
        parent_pointers[*i] = par;
      }

    return par;
  }

  T find( const T& object)
  {
    return num_to_objects[find_id (object)];
  }

  //Given two objects, unite the sets to which they belong
  void unite (const T& obj1, const T& obj2)
  {
    octave_idx_type on1 = find_id(obj1), on2 = find_id(obj2);

    //Check if any union needs to be done, maybe they already are
    //in the same set.
    if (on1 != on2)
      {
        octave_idx_type r1 = num_ranks[on1], r2 = num_ranks[on2];

        if ( r1 < r2)
          {
            parent_pointers[on1] = on2;
            num_ranks.erase (on1); //Only root nodes need a rank
          }
        else if (r2 > r1)
          {
            parent_pointers[on2] = on1;
            num_ranks.erase (on2);
          }
        else
          {
            parent_pointers[on2] = on1;
            num_ranks.erase (on2);
            num_ranks[on1]++;
          }
      }
  }

  const unordered_map<T, octave_idx_type, H>& get_objects()
  {
    return objects_to_num;
  };

};
