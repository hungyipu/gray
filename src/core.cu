// Copyright (C) 2012--2014 Chi-kwan Chan
// Copyright (C) 2012--2014 Steward Observatory
//
// This file is part of GRay.
//
// GRay is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// GRay is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
// License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GRay.  If not, see <http://www.gnu.org/licenses/>.

#include "gray.h"

static __device__ __constant__ size_t *count = NULL;

cudaError_t core::sync(size_t *p)
{
  debug("core::sync(%p)\n", p);
  return cudaMemcpyToSymbol(count, &p, sizeof(size_t *));
}

static __device__ __constant__ Const c = {};

cudaError_t core::sync(Const *p)
{
  debug("core::sync(%p)\n", p);
  return cudaMemcpyToSymbol(c, p, sizeof(Const));
}

#include <ic.h> // define device function ic()

static __global__ void kernel(State *s, const size_t n, const real t)
{
  const size_t i = blockIdx.x * blockDim.x + threadIdx.x;
  if(i < n)
    s[i] = ic(i, n, t);
}

cudaError_t Data::init(double t)
{
  debug("Data::init(%f)\n", t);

  kernel<<<gsz, bsz>>>(device(), n, t);

  cudaError_t err = cudaDeviceSynchronize();
  deactivate();
  return err;
}

#include <rhs.h>   // define device function rhs()
#include <getdt.h> // define device function getdt()

#define GET(s)  ((real *)&(s))[index]
#define EACH(s) for(int index = 0; index < NVAR; ++index) GET(s)
#  include <fixup.h>      // define device function fixup()
#  include "scheme/rk4.h" // define device function scheme()
#undef GET
#undef EACH

#ifdef PARTICLE_TIME
#  define GET_TIME (t = shared[threadIdx.x].PARTICLE_TIME)
#else
#  define GET_TIME t
#endif
#  include "scheme/driver.h" // define global kernel function driver()
#undef GET_TIME

cudaError_t Data::evolve(double t0, double t1)
{
  debug("Data::evolve(%g,%g)\n", t0, t1);

  driver<<<gsz, bsz, bsz * sizeof(State)>>>(device(), n, t0, t1);

  cudaError_t err = cudaDeviceSynchronize();
  deactivate();
  return err;
}
