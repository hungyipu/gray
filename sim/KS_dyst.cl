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

real4 physical_coords_to_normalized_coords(real4 xyz, real8 bounding_box){

  const real x = xyz.s0;
  const real y = xyz.s1;
  const real z = xyz.s2;
  const real xmin = bounding_box.s0;
  const real xmax = bounding_box.s4;
  const real ymin = bounding_box.s1;
  const real ymax = bounding_box.s5;
  const real zmin = bounding_box.s2;
  const real zmax = bounding_box.s6;

  return (real4){(x - xmin)/(xmax - xmin),
                 (y - ymin)/(ymax - ymin),
                 (z - zmin)/(zmax - zmin),
                  0};
}

inline real interpolate(real4 xyz, real8 bounding_box, __read_only image3d_t var){

  return read_imagef(var,
                     CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_CLAMP | CLK_FILTER_LINEAR,
                     physical_coords_to_normalized_coords(xyz, bounding_box)).x;
}

real8
rhs(real8 s,
    const    real8 bounding_box, /**< Max coordinates of the grid    */
    __read_only image3d_t Gamma_ttt,
    __read_only image3d_t Gamma_ttx,
    __read_only image3d_t Gamma_tty,
    __read_only image3d_t Gamma_ttz,
    __read_only image3d_t Gamma_txx,
    __read_only image3d_t Gamma_txy,
    __read_only image3d_t Gamma_txz,
    __read_only image3d_t Gamma_tyy,
    __read_only image3d_t Gamma_tyz,
    __read_only image3d_t Gamma_tzz,
    __read_only image3d_t Gamma_xtt,
    __read_only image3d_t Gamma_xtx,
    __read_only image3d_t Gamma_xty,
    __read_only image3d_t Gamma_xtz,
    __read_only image3d_t Gamma_xxx,
    __read_only image3d_t Gamma_xxy,
    __read_only image3d_t Gamma_xxz,
    __read_only image3d_t Gamma_xyy,
    __read_only image3d_t Gamma_xyz,
    __read_only image3d_t Gamma_xzz,
    __read_only image3d_t Gamma_ytt,
    __read_only image3d_t Gamma_ytx,
    __read_only image3d_t Gamma_yty,
    __read_only image3d_t Gamma_ytz,
    __read_only image3d_t Gamma_yxx,
    __read_only image3d_t Gamma_yxy,
    __read_only image3d_t Gamma_yxz,
    __read_only image3d_t Gamma_yyy,
    __read_only image3d_t Gamma_yyz,
    __read_only image3d_t Gamma_yzz,
    __read_only image3d_t Gamma_ztt,
    __read_only image3d_t Gamma_ztx,
    __read_only image3d_t Gamma_zty,
    __read_only image3d_t Gamma_ztz,
    __read_only image3d_t Gamma_zxx,
    __read_only image3d_t Gamma_zxy,
    __read_only image3d_t Gamma_zxz,
    __read_only image3d_t Gamma_zyy,
    __read_only image3d_t Gamma_zyz,
    __read_only image3d_t Gamma_zzz)
{

    real a_spin = 0;

    real4 q = s.s0123;
    real4 u = s.s4567;

    real  f,  dx_f,  dy_f,  dz_f;
    real  lx, dx_lx, dy_lx, dz_lx;
    real  ly, dx_ly, dy_ly, dz_ly;
    real  lz, dx_lz, dy_lz, dz_lz;

    real  hDxu, hDyu, hDzu;
    real4 uD;
    real  tmp;

    {
        real dx_r, dy_r, dz_r;
        real r, ir, iss;
        {
            real aa = a_spin * a_spin;
            real rr, tmp2;
            {
                real zz = q.s3 * q.s3;
                real dd;
                {
                    real kk = K(0.5) * (q.s1 * q.s1 + q.s2 * q.s2 + zz - aa);
                    dd = sqrt(kk * kk + aa * zz);
                    rr = dd + kk;
                }
                r  = sqrt(rr);
                ir = K(1.0) / r;
                {
                    real ss = rr + aa;
                    iss  = K(1.0) / ss;
                    tmp  = K(0.5) / (r * dd);
                    dz_r = tmp * ss * q.s3;
                    tmp *= rr;
                }
                dy_r = tmp * q.s2;
                dx_r = tmp * q.s1;
                tmp  = K(2.0) / (rr + aa * zz / rr);
            }
            tmp2 = K(3.0) - K(2.0) * rr * tmp;
            f    = tmp *  r;
            dx_f = tmp *  dx_r * tmp2;
            dy_f = tmp *  dy_r * tmp2;
            dz_f = tmp * (dz_r * tmp2 - tmp * aa * q.s3 * ir);
        } /* 48 (-8) FLOPs; estimated FLoating-point OPerations, the number
             in the parentheses is (the negative of) the number of FMA */
        {
            real m2r  = K(-2.0) * r;
            real issr = iss     * r;
            real issa = iss     * a_spin;

            lx    = iss * (q.s1 * r + q.s2 * a_spin);
            tmp   = iss * (q.s1 + m2r * lx);
            dx_lx = tmp * dx_r + issr;
            dy_lx = tmp * dy_r + issa;
            dz_lx = tmp * dz_r;

            ly    = iss * (q.s2 * r - q.s1 * a_spin);
            tmp   = iss * (q.s2 + m2r * ly);
            dx_ly = tmp * dx_r - issa;
            dy_ly = tmp * dy_r + issr;
            dz_ly = tmp * dz_r;

            lz    = q.s3 * ir;
            tmp   = -lz * ir;
            dx_lz = tmp * dx_r;
            dy_lz = tmp * dy_r;
            dz_lz = tmp * dz_r + ir;
        } /* 35 (-9) FLOPs */
    }

    {
        real  flu;
        real4 Dx, Dy, Dz;
        {
            real lu = u.s0 + lx * u.s1 + ly * u.s2 + lz * u.s3;
            flu   = f * lu;
            Dx.s0 = dx_f * lu + f * (dx_lx * u.s1 + dx_ly * u.s2 + dx_lz * u.s3);
            Dy.s0 = dy_f * lu + f * (dy_lx * u.s1 + dy_ly * u.s2 + dy_lz * u.s3);
            Dz.s0 = dz_f * lu + f * (dz_lx * u.s1 + dz_ly * u.s2 + dz_lz * u.s3); /* 31 (-12) FLOPs */
        }
        Dx.s1 = Dx.s0 * lx + flu * dx_lx;
        Dx.s2 = Dx.s0 * ly + flu * dx_ly;
        Dx.s3 = Dx.s0 * lz + flu * dx_lz; /* 9 (-3) FLOPs */

        Dy.s1 = Dy.s0 * lx + flu * dy_lx;
        Dy.s2 = Dy.s0 * ly + flu * dy_ly;
        Dy.s3 = Dy.s0 * lz + flu * dy_lz; /* 9 (-3) FLOPs */

        Dz.s1 = Dz.s0 * lx + flu * dz_lx;
        Dz.s2 = Dz.s0 * ly + flu * dz_ly;
        Dz.s3 = Dz.s0 * lz + flu * dz_lz; /* 9 (-3) FLOPs */

        hDxu = K(0.5) * dot(Dx, u);
        hDyu = K(0.5) * dot(Dy, u);
        hDzu = K(0.5) * dot(Dz, u); /* 24 (-9) FLOPs */

        uD  = u.s1 * Dx + u.s2 * Dy + u.s3 * Dz; /* 20 (-8) FLOPs */

        tmp = f * (-uD.s0 + lx * (uD.s1 - hDxu) + ly * (uD.s2 - hDyu) + lz * (uD.s3 - hDzu)); /* 10 (-3) FLOPs */
    }

    return (real8){u,
                      uD.s0 -      tmp,
               hDxu - uD.s1 + lx * tmp,
               hDyu - uD.s2 + ly * tmp,
               hDzu - uD.s3 + lz * tmp}; /* 10 (-3) FLOPs */

}
