/* Automatically generated, do not edit */
inline real GRAY_SQUARE (real x) { return x*x; };
inline real GRAY_CUBE (real x) { return x*x*x; };
inline real GRAY_FOUR (real x) { return x*x*x*x; };
inline real GRAY_SQRT (real x) { return sqrt(x); };
inline real GRAY_SQRT_CUBE (real x) { return sqrt(x*x*x); };

real16 matrix_product(real16 a, real16 b){

  real4 a_row0 = a.s0123;
  real4 a_row1 = a.s4567;
  real4 a_row2 = a.s89ab;
  real4 a_row3 = a.scdef;
  real4 b_col0 = b.s048c;
  real4 b_col1 = b.s159d;
  real4 b_col2 = b.s26ae;
  real4 b_col3 = b.s37bf;

  return (real16){dot(a_row0, b_col0), dot(a_row0, b_col1),
  dot(a_row0, b_col2), dot(a_row0, b_col3),
  dot(a_row1, b_col0), dot(a_row1, b_col1),
  dot(a_row1, b_col2), dot(a_row1, b_col3),
  dot(a_row2, b_col0), dot(a_row2, b_col1),
  dot(a_row2, b_col2), dot(a_row2, b_col3),
  dot(a_row3, b_col0), dot(a_row3, b_col1),
  dot(a_row3, b_col2), dot(a_row3, b_col3)};
};

real4 matrix_vector_product(real16 a, real4 b){

  return (real4){dot(a.s0123, b),
  dot(a.s4567, b),
  dot(a.s89ab, b),
  dot(a.scdef, b)};
};

real
getuu(real4 q, /**< Spacetime event "location" */
      real4 u) /**< The vector being squared   */
{
  real t = q.s0;
  real x = q.s1;
  real y = q.s2;
  real z = q.s3;

  return 0;

  /*   return (real4){dot(u, matrix_vector_product(g, u)), */
  /* fabs(dot(g.s0123, u) * u.s0) + */
  /* fabs(dot(g.s4567, u) * u.s1) + */
  /* fabs(dot(g.s89ab, u) * u.s2) + */
  /* fabs(dot(g.scdef, u) * u.s3), */
  /* K(0.0), K(0.0)}; */
}

real8
icond(real r_obs, /**< Distance of the observer from the black hole */
      real i_obs, /**< Inclination angle of the observer in degrees */
      real j_obs, /**< Azimuthal   angle of the observer in degrees */
      real alpha, /**< One of the local Cartesian coordinates       */
      real beta)  /**< The other  local Cartesian coordinate        */
{

  real  deg2rad = K(3.14159265358979323846264338327950288) / K(180.0);
  real  ci, si  = sincos(deg2rad * i_obs, &ci);
  real  cj, sj  = sincos(deg2rad * j_obs, &cj);

  real  R0 = r_obs * si - beta  * ci;
  real  z  = r_obs * ci + beta  * si;
  real  y  = R0    * sj - alpha * cj;
  real  x  = R0    * cj + alpha * sj;

  real4 q = (real4){K(0.0), x, y, z};
  real4 u = (real4){K(1.0), si * cj, si * sj, ci};

  return (real8){q, u};
}

real4 physical_coords_to_unnormalized_coords(real4 xyz, real8 bounding_box, int4 num_points){

  const real x = xyz.s1;
  const real y = xyz.s2;
  const real z = xyz.s3;
  const real xmin = bounding_box.s1;
  const real xmax = bounding_box.s5;
  const real ymin = bounding_box.s2;
  const real ymax = bounding_box.s6;
  const real zmin = bounding_box.s3;
  const real zmax = bounding_box.s7;

  /* The 0.5 is very important because OpenCL uses a pixel offset of 0.5 */

  /* read_imagef ignores the 4th coordinate, so here we have to put xyz in
   * the first three slots */
  return (real4){K(0.5) + (x - xmin)/(xmax - xmin) * num_points.x,
                 K(0.5) + (y - ymin)/(ymax - ymin) * num_points.y,
                 K(0.5) + (z - zmin)/(zmax - zmin) * num_points.z,
                  0};
}

inline real space_interpolate(real4 xyz, real8 bounding_box, int4 num_points, __read_only image3d_t var){

  sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_LINEAR;

  return read_imagef(var,
                     sampler,
                     physical_coords_to_unnormalized_coords(xyz, bounding_box, num_points)).x;
}

inline real interpolate(real4 q,
                        real8 bounding_box,
                        int4 num_points,
                        __read_only image3d_t var_t1,
                        __read_only image3d_t var_t2){

  real t1 = bounding_box.s0;
  real t2 = bounding_box.s4;

  if (t1 == t2)
    return space_interpolate(q, bounding_box, num_points, var_t1);

  /* y(t) = y_1 + (t - t_1) / (t2 - t1) * (y_2 - y_1) */

  real y1 = space_interpolate(q, bounding_box, num_points, var_t1);
  real y2 = space_interpolate(q, bounding_box, num_points, var_t2);

  return y1 + (q.s0 - t1) / (t2 - t1) * (y2 - y1);
}

real8
rhs(real8 s,
    const    real8 bounding_box, /**< Max spacetime coordinates of the grid */
        const    int4 num_points, /**< Number of points on the grid    */
		   __read_only image3d_t Gamma_ttt_t1,
		   __read_only image3d_t Gamma_ttx_t1,
		   __read_only image3d_t Gamma_tty_t1,
		   __read_only image3d_t Gamma_ttz_t1,
		   __read_only image3d_t Gamma_txx_t1,
		   __read_only image3d_t Gamma_txy_t1,
		   __read_only image3d_t Gamma_txz_t1,
		   __read_only image3d_t Gamma_tyy_t1,
		   __read_only image3d_t Gamma_tyz_t1,
		   __read_only image3d_t Gamma_tzz_t1,
		   __read_only image3d_t Gamma_xtt_t1,
		   __read_only image3d_t Gamma_xtx_t1,
		   __read_only image3d_t Gamma_xty_t1,
		   __read_only image3d_t Gamma_xtz_t1,
		   __read_only image3d_t Gamma_xxx_t1,
		   __read_only image3d_t Gamma_xxy_t1,
		   __read_only image3d_t Gamma_xxz_t1,
		   __read_only image3d_t Gamma_xyy_t1,
		   __read_only image3d_t Gamma_xyz_t1,
		   __read_only image3d_t Gamma_xzz_t1,
		   __read_only image3d_t Gamma_ytt_t1,
		   __read_only image3d_t Gamma_ytx_t1,
		   __read_only image3d_t Gamma_yty_t1,
		   __read_only image3d_t Gamma_ytz_t1,
		   __read_only image3d_t Gamma_yxx_t1,
		   __read_only image3d_t Gamma_yxy_t1,
		   __read_only image3d_t Gamma_yxz_t1,
		   __read_only image3d_t Gamma_yyy_t1,
		   __read_only image3d_t Gamma_yyz_t1,
		   __read_only image3d_t Gamma_yzz_t1,
		   __read_only image3d_t Gamma_ztt_t1,
		   __read_only image3d_t Gamma_ztx_t1,
		   __read_only image3d_t Gamma_zty_t1,
		   __read_only image3d_t Gamma_ztz_t1,
		   __read_only image3d_t Gamma_zxx_t1,
		   __read_only image3d_t Gamma_zxy_t1,
		   __read_only image3d_t Gamma_zxz_t1,
		   __read_only image3d_t Gamma_zyy_t1,
		   __read_only image3d_t Gamma_zyz_t1,
		   __read_only image3d_t Gamma_zzz_t1, /* 2 */
		   __read_only image3d_t Gamma_ttt_t2,
		   __read_only image3d_t Gamma_ttx_t2,
		   __read_only image3d_t Gamma_tty_t2,
		   __read_only image3d_t Gamma_ttz_t2,
		   __read_only image3d_t Gamma_txx_t2,
		   __read_only image3d_t Gamma_txy_t2,
		   __read_only image3d_t Gamma_txz_t2,
		   __read_only image3d_t Gamma_tyy_t2,
		   __read_only image3d_t Gamma_tyz_t2,
		   __read_only image3d_t Gamma_tzz_t2,
		   __read_only image3d_t Gamma_xtt_t2,
		   __read_only image3d_t Gamma_xtx_t2,
		   __read_only image3d_t Gamma_xty_t2,
		   __read_only image3d_t Gamma_xtz_t2,
		   __read_only image3d_t Gamma_xxx_t2,
		   __read_only image3d_t Gamma_xxy_t2,
		   __read_only image3d_t Gamma_xxz_t2,
		   __read_only image3d_t Gamma_xyy_t2,
		   __read_only image3d_t Gamma_xyz_t2,
		   __read_only image3d_t Gamma_xzz_t2,
		   __read_only image3d_t Gamma_ytt_t2,
		   __read_only image3d_t Gamma_ytx_t2,
		   __read_only image3d_t Gamma_yty_t2,
		   __read_only image3d_t Gamma_ytz_t2,
		   __read_only image3d_t Gamma_yxx_t2,
		   __read_only image3d_t Gamma_yxy_t2,
		   __read_only image3d_t Gamma_yxz_t2,
		   __read_only image3d_t Gamma_yyy_t2,
		   __read_only image3d_t Gamma_yyz_t2,
		   __read_only image3d_t Gamma_yzz_t2,
		   __read_only image3d_t Gamma_ztt_t2,
		   __read_only image3d_t Gamma_ztx_t2,
		   __read_only image3d_t Gamma_zty_t2,
		   __read_only image3d_t Gamma_ztz_t2,
		   __read_only image3d_t Gamma_zxx_t2,
		   __read_only image3d_t Gamma_zxy_t2,
		   __read_only image3d_t Gamma_zxz_t2,
		   __read_only image3d_t Gamma_zyy_t2,
		   __read_only image3d_t Gamma_zyz_t2,
		   __read_only image3d_t Gamma_zzz_t2)
{
  real4 q = s.s0123;
  real4 u = s.s4567;

  real16 GammaUPt, GammaUPx, GammaUPy, GammaUPz;

  /* We compute the commented ones in one shot */
  GammaUPt.s0 = interpolate(q, bounding_box, num_points, Gamma_ttt_t1, Gamma_ttt_t2);
  GammaUPt.s1 = interpolate(q, bounding_box, num_points, Gamma_ttx_t1, Gamma_ttx_t2);
  GammaUPt.s2 = interpolate(q, bounding_box, num_points, Gamma_tty_t1, Gamma_tty_t2);
  GammaUPt.s3 = interpolate(q, bounding_box, num_points, Gamma_ttz_t1, Gamma_ttz_t2);
  /* GammaUPt.s4 = GammaUPt.s1; */
  GammaUPt.s5 = interpolate(q, bounding_box, num_points, Gamma_txx_t1, Gamma_txx_t2);
  GammaUPt.s6 = interpolate(q, bounding_box, num_points, Gamma_txy_t1, Gamma_txy_t2);
  GammaUPt.s7 = interpolate(q, bounding_box, num_points, Gamma_txz_t1, Gamma_txz_t2);
  /* GammaUPt.s8 = GammaUPt.s2; */
  /* GammaUPt.s9 = GammaUPt.s6; */
  GammaUPt.sa = interpolate(q, bounding_box, num_points, Gamma_tyy_t1, Gamma_tyy_t2);
  GammaUPt.sb = interpolate(q, bounding_box, num_points, Gamma_tyz_t1, Gamma_tyz_t2);
  /* GammaUPt.sc = GammaUPt.s3; */
  /* GammaUPt.sd = GammaUPt.s7; */
  /* GammaUPt.se = GammaUPt.sb; */
  GammaUPt.sf = interpolate(q, bounding_box, num_points, Gamma_tzz_t1, Gamma_tzz_t2);

  GammaUPt.s489 = GammaUPt.s126;
  GammaUPt.scde = GammaUPt.s37b;


  GammaUPx.s0 = interpolate(q, bounding_box, num_points, Gamma_xtt_t1, Gamma_xtt_t2);
  GammaUPx.s1 = interpolate(q, bounding_box, num_points, Gamma_xtx_t1, Gamma_xtx_t2);
  GammaUPx.s2 = interpolate(q, bounding_box, num_points, Gamma_xty_t1, Gamma_xty_t2);
  GammaUPx.s3 = interpolate(q, bounding_box, num_points, Gamma_xtz_t1, Gamma_xtz_t2);
  GammaUPx.s5 = interpolate(q, bounding_box, num_points, Gamma_xxx_t1, Gamma_xxx_t2);
  GammaUPx.s6 = interpolate(q, bounding_box, num_points, Gamma_xxy_t1, Gamma_xxy_t2);
  GammaUPx.s7 = interpolate(q, bounding_box, num_points, Gamma_xxz_t1, Gamma_xxz_t2);
  GammaUPx.sa = interpolate(q, bounding_box, num_points, Gamma_xyy_t1, Gamma_xyy_t2);
  GammaUPx.sb = interpolate(q, bounding_box, num_points, Gamma_xyz_t1, Gamma_xyz_t2);
  GammaUPx.sf = interpolate(q, bounding_box, num_points, Gamma_xzz_t1, Gamma_xzz_t2);

  GammaUPx.s489 = GammaUPx.s126;
  GammaUPx.scde = GammaUPx.s37b;


  GammaUPy.s0 = interpolate(q, bounding_box, num_points, Gamma_ytt_t1, Gamma_ytt_t2);
  GammaUPy.s1 = interpolate(q, bounding_box, num_points, Gamma_ytx_t1, Gamma_ytx_t2);
  GammaUPy.s2 = interpolate(q, bounding_box, num_points, Gamma_yty_t1, Gamma_yty_t2);
  GammaUPy.s3 = interpolate(q, bounding_box, num_points, Gamma_ytz_t1, Gamma_ytz_t2);
  GammaUPy.s5 = interpolate(q, bounding_box, num_points, Gamma_yxx_t1, Gamma_yxx_t2);
  GammaUPy.s6 = interpolate(q, bounding_box, num_points, Gamma_yxy_t1, Gamma_yxy_t2);
  GammaUPy.s7 = interpolate(q, bounding_box, num_points, Gamma_yxz_t1, Gamma_yxz_t2);
  GammaUPy.sa = interpolate(q, bounding_box, num_points, Gamma_yyy_t1, Gamma_yyy_t2);
  GammaUPy.sb = interpolate(q, bounding_box, num_points, Gamma_yyz_t1, Gamma_yyz_t2);
  GammaUPy.sf = interpolate(q, bounding_box, num_points, Gamma_yzz_t1, Gamma_yzz_t2);

  GammaUPy.s489 = GammaUPy.s126;
  GammaUPy.scde = GammaUPy.s37b;


  GammaUPz.s0 = interpolate(q, bounding_box, num_points, Gamma_ztt_t1, Gamma_ztt_t2);
  GammaUPz.s1 = interpolate(q, bounding_box, num_points, Gamma_ztx_t1, Gamma_ztx_t2);
  GammaUPz.s2 = interpolate(q, bounding_box, num_points, Gamma_zty_t1, Gamma_zty_t2);
  GammaUPz.s3 = interpolate(q, bounding_box, num_points, Gamma_ztz_t1, Gamma_ztz_t2);
  GammaUPz.s5 = interpolate(q, bounding_box, num_points, Gamma_zxx_t1, Gamma_zxx_t2);
  GammaUPz.s6 = interpolate(q, bounding_box, num_points, Gamma_zxy_t1, Gamma_zxy_t2);
  GammaUPz.s7 = interpolate(q, bounding_box, num_points, Gamma_zxz_t1, Gamma_zxz_t2);
  GammaUPz.sa = interpolate(q, bounding_box, num_points, Gamma_zyy_t1, Gamma_zyy_t2);
  GammaUPz.sb = interpolate(q, bounding_box, num_points, Gamma_zyz_t1, Gamma_zyz_t2);
  GammaUPz.sf = interpolate(q, bounding_box, num_points, Gamma_zzz_t1, Gamma_zzz_t2);

  GammaUPz.s489 = GammaUPz.s126;
  GammaUPz.scde = GammaUPz.s37b;

  real GammaUU = dot(u, matrix_vector_product(GammaUPt, u));

  real4 rhs = {-dot(u, matrix_vector_product(GammaUPt, u)) + GammaUU * u.s0,
               -dot(u, matrix_vector_product(GammaUPx, u)) + GammaUU * u.s1,
               -dot(u, matrix_vector_product(GammaUPy, u)) + GammaUU * u.s2,
               -dot(u, matrix_vector_product(GammaUPz, u)) + GammaUU * u.s3};

  return (real8){u, rhs.s0, rhs.s1, rhs.s2, rhs.s3};
}
