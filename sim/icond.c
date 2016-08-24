/*
 * Copyright (C) 2016 Chi-kwan Chan
 * Copyright (C) 2016 Steward Observatory
 *
 * This file is part of GRay2.
 *
 * GRay2 is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * GRay2 is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GRay2.  If not, see <http://www.gnu.org/licenses/>.
 */
#include "gray.h"

void
icond(Lux_job *ego)
{
	Lux_opencl *ocl = EGO->ocl;

	struct icond *i = &EGO->icond;
	struct param *p = &EGO->param;

	const size_t shape[] = {p->h_rays, p->w_rays};

	Lux_opencl_kernel *icond;

	lux_debug("GRay2: executing job %p\n", ego);

	icond = ocl->mkkern(ocl, "icond_drv");

	ocl->setM(ocl, icond, 0, EGO->data);
	ocl->setM(ocl, icond, 1, EGO->info);
	ocl->setR(ocl, icond, 2, i->w_img);
	ocl->setR(ocl, icond, 3, i->h_img);
	ocl->setR(ocl, icond, 4, i->r_obs);
	ocl->setR(ocl, icond, 5, i->i_obs);
	ocl->setR(ocl, icond, 6, i->j_obs);
	ocl->exec(ocl, icond, 2, shape);

	ocl->rmkern(ocl, icond);
}