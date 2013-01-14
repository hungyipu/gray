// Copyright (C) 2012 Chi-kwan Chan
// Copyright (C) 2012 Steward Observatory
//
// This file is part of geode.
//
// Geode is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Geode is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
// License for more details.
//
// You should have received a copy of the GNU General Public License
// along with geode.  If not, see <http://www.gnu.org/licenses/>.

#ifndef PARA_H
#define PARA_H

#define DT_DUMP     (-1)          // default dump time
#define R_OBS       10            // observer radius in GM/c^2
#define THETA_OBS   30            // observer theta in degrees
#define A_SPIN      ((real)0.999) // dimensionless spin J/Mc
#define DT_MIN      1.0e-2        // minimal dt in getdt()
#define STEP_FACTOR 32            // extra factor in getdt()

#endif // PARA_H