************************************************************************
c
c     Hill 1948 YIELD FUNCTION
c
c       doi:
c
      subroutine ummdp_yield_hill1948 ( s,se,dseds,d2seds2,nreq,pryld,
     1                                  ndyld )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer,intent(in) :: nreq,ndyld
      real*8 ,intent(in) :: s(6),pryld(ndyld)
c
      real*8,intent(out) :: se
      real*8,intent(out) :: dseds(6)
			real*8,intent(out) :: d2seds2(6,6)
c
      integer i,j
			real*8 pf,pg,ph,pl,pm,pn,phi
      real*8 v(6)
			real*8 c(6,6)
c-----------------------------------------------------------------------
c
c                                            ---- anisotropic parameters
      pf = pryld(1+1)
      pg = pryld(1+2)
      ph = pryld(1+3)
      pl = pryld(1+4)
      pm = pryld(1+5)
      pn = pryld(1+6)
c                                               ---- coefficients matrix
      c = 0.0d0
      c(1,1) = pg + ph
      c(1,2) = -ph
      c(1,3) = -pg
      c(2,1) = -ph
      c(2,2) = pf + ph
      c(2,3) = -pf
      c(3,1) = -pg
      c(3,2) = -pf
      c(3,3) = pf + pg
      c(4,4) = 2.0d0 * pn
      c(5,5) = 2.0d0 * pm
      c(6,6) = 2.0d0 * pl
      do i = 1,6
        do j = 1,6
          c(i,j) = c(i,j) / (pg+ph)
        end do
      end do
c
      call ummdp_utility_mv  ( v,c,s,6,6 )
      call ummdp_utility_vvs ( phi,s,v,6 )
c                                                 ---- equivalent stress
      if ( phi <= 0.0 ) phi = 0.0
      se = sqrt(phi)
c                                              ---- 1st order derivative
      if ( nreq >= 1 ) then
        do i = 1,6
          dseds(i) = v(i) / se
        end do
      end if
c                                              ---- 2nd order derivative
      if ( nreq >= 2 ) then
        do i = 1,6
          do j = 1,6
            d2seds2(i,j) = (-v(i)*v(j)/phi+c(i,j)) / se
          end do
        end do
      end if
c
      return
      end subroutine ummdp_yield_hill1948
c
c
c
