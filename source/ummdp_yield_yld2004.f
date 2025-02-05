************************************************************************
c
c     YLD2004-18p YIELD FUNCTION
c
c       doi: 
c
      subroutine ummdp_yield_yld2004 ( s,se,dseds,d2seds2,nreq,pryld,
     1                                 ndyld )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer nreq,ndyld
      real*8 se
      real*8 s(6),dseds(6),pryld(ndyld)
      real*8 d2seds2(6,6)
c
      integer i,j,k,l,m,n,ip,iq,ir
      real*8 am,ami,dc,pi,eps2,eps3,del,cetpq1,cetpq2,fai,dsedfa,
     1       d2sedfa2,dummy
      real*8 sp1(6),sp2(6),psp1(3),psp2(3),hp1(3),hp2(3),
     1       dfadpsp1(3),dfadpsp2(3),dfadhp1(3),dfadhp2(3),dfads(6)
      real*8 cp1(6,6),cp2(6,6),cl(6,6),ctp1(6,6),ctp2(6,6),
     1       dpsdhp1(3,3),dpsdhp2(3,3),dhdsp1(3,6),dhdsp2(3,6),
     2       dsdsp1(6,6),dsdsp2(6,6),d2fadpsp11(3,3),d2fadpsp22(3,3),
     3       d2fadpsp12(3,3),d2fadpsp21(3,3),d2fadhp11(3,3),
     4       d2fadhp22(3,3),d2fadhp12(3,3),d2fadhp21(3,3),d2fads2(6,6),
     5       delta(3,3),xx1(3,6),xx2(3,6)
      real*8 d2psdhp11(3,3,3),d2psdhp22(3,3,3),d2hdsp11(3,6,6),
     1       d2hdsp22(3,6,6)
c-----------------------------------------------------------------------
c
c     sp1(6),sp2(6)     : linear-transformed stress
c     cp1(6,6),cp2(6,6) : matrix for anisotropic parameters
c     cl(6,6)           : matrix for transforming Cauchy stress to deviator
c     ctp1(6,6)         : matrix for transforming Cauchy stress to sp1
c     ctp2(6,6)         : matrix for transforming Cauchy stress to sp2
c     dc                : coef. of equivalent stress (se=(fai/dc)**(1/am))
c     aap1(3),aap2(3)   : for dc
c     ppp1,ppp2         : for dc
c     qqp1,qqp2         : for dc
c     ttp1,ttp2         : for dc
c     bbp1(3),bbp2(3)   : for dc
c     fai               : yield fuction
c     psp1(3)           : principal values of sp1
c     psp2(3)           : principal values of sp2
c     hp1(3)            : invariants of sp1
c     hp2(3)            : invariants of sp2
c     cep1,cep2         : coef. of characteristic equation p
c     ceq1,ceq2         : coef. of characteristic equation q
c     cet1,cet2         : arccos ( q/p^(3/2) )
c
c     dfadpsp1(3),dfadpsp2(3)   : d(fai)/d(psp)
c     dfadhp1(3),dfadhp2(3)     : d(fai)/d(hp)
c     dpsdhp1(3,3),dpsdhp2(3,3) : d(psp)/d(hp)
c     dhdsp1(3,6),dhdsp2(3,6)   : d(hp)/d(sp)
c     dsdsp1(6,6), dsdsp2(6,6)  : d(sp)/d(s)
c     dfads(6)                  : d(fai)/d(s)
c
c     d2fadpsp11(3,3),d2fadpsp22(3,3)   : d2(fai)/d(psp)2
c     d2fadpsp12(3,3),d2fadpsp21(3,3)   : d2(fai)/d(psp)2
c     d2psdhp11(3,3,3),d2psdhp22(3,3,3) : d2(psp)/d(hp)2
c     d2hdsp11(3,6,6),d2hdsp22(3,6,6)   : d2(hp)/d(sp)2
c     d2fads2(6,6)                      : d2(fai)/d(s)2
c
c     eps2,eps3 : values for calculation of d(psp)/d(hp),d2(psp)/d(hp)2
c
      pi = acos(-1.0d0)
      eps2 = 1.0d-15
      eps3 = 1.0d-8
      del = 1.0d-4
c                                                   ---- Kronecker Delta
      delta = 0.0d0
      do i = 1,3
        delta(i,i) = 1.0d0
      end do
c                                        ---- set anisotropic parameters
      cp1 = 0.0d0
      cp2 = 0.0d0
      cp1(1,2) = -pryld(1+1)
      cp1(1,3) = -pryld(1+2)
      cp1(2,1) = -pryld(1+3)
      cp1(2,3) = -pryld(1+4)
      cp1(3,1) = -pryld(1+5)
      cp1(3,2) = -pryld(1+6)
      cp1(4,4) =  pryld(1+9)  ! for tau_xy (c'66 in original paper)
      cp1(5,5) =  pryld(1+8)  ! for tau_xz (c'55 in original paper)
      cp1(6,6) =  pryld(1+7)  ! for tau_zx (c'44 in original paper)
      cp2(1,2) = -pryld(1+10)
      cp2(1,3) = -pryld(1+11)
      cp2(2,1) = -pryld(1+12)
      cp2(2,3) = -pryld(1+13)
      cp2(3,1) = -pryld(1+14)
      cp2(3,2) = -pryld(1+15)
      cp2(4,4) =  pryld(1+18) ! for tau_xy (c"66 in original paper)
      cp2(5,5) =  pryld(1+17) ! for tau_xz (c"55 in original paper)
      cp2(6,6) =  pryld(1+16) ! for tau_zx (c"44 in original paper)
      am       =  pryld(1+19)
      dc       =  4
      ami = 1.0d0 / am
c
c             ---- set matrix for transforming Cauchy stress to deviator
      cl = 0.0d0
      do i = 1,3
        do j = 1,3
          if ( i == j ) then
            cl(i,j) = 2.0d0
          else
            cl(i,j) = -1.0d0
          end if
        end do
      end do
      do i = 4,6
        cl(i,i) = 3.0d0
      end do
      do i = 1,6
        do j = 1,6
          cl(i,j) = cl(i,j) / 3.0d0
        end do
      end do
c
c                  ---- matrix for transforming Cauchy stress to sp1,sp2
      call ummdp_utility_mm ( ctp1,cp1,cl,6,6,6 )
      call ummdp_utility_mm ( ctp2,cp2,cl,6,6,6 )
c                               ---- coefficient of equivalent stress dc
c      call ummdp_yield_yld2004_coef ( cp1,cp2,pi,am,dc )
c                                  ---- calculation of equivalent stress
      call ummdp_yield_yld2004_yf ( ctp1,ctp2,s,am,ami,dc,pi,sp1,sp2,
     1                              psp1,psp2,hp1,hp2,cetpq1,cetpq2,fai,
     2                              se )
c
c                                            ---- 1st order differential
      if ( nreq >= 1 ) then
c                                                     ---- d(fai)/d(psp)
        dfadpsp1 = 0.0d0
        dfadpsp2 = 0.0d0
        do i = 1,3
          do j = 1,3
            dfadpsp1(i) = dfadpsp1(i) + (psp1(i)-psp2(j)) *
     1                    abs(psp1(i)-psp2(j))**(am-2.0d0)
            dfadpsp2(i) = dfadpsp2(i) + (psp1(j)-psp2(i)) *
     2                    abs(psp1(j)-psp2(i))**(am-2.0d0)
          end do
          dfadpsp1(i) = dfadpsp1(i) * am
          dfadpsp2(i) = dfadpsp2(i) * (-am)
        end do
c                                         ---- d(psp)/d(hp)&d(fai)/d(hp)
        dpsdhp1 = 0.0d0
        dpsdhp2 = 0.0d0
        dfadhp1 = 0.0d0
        dfadhp2 = 0.0d0
c                                                  ---- theta'<>0 & <>pi
        if ( abs(cetpq1-1.0d0) >= eps2 .and. 
     1       abs(cetpq1+1.0d0) >= eps2 ) then
          do i = 1,3
            call ummdp_yield_yld2004_dpsdhp ( i,psp1,hp1,dpsdhp1 )
          end do
c                                                          ---- theta'=0
        else if ( abs(cetpq1-1.0d0) < eps2 ) then
          i = 1
          call ummdp_yield_yld2004_dpsdhp ( i,psp1,hp1,dpsdhp1 )
          do i = 2,3
            do j = 1,3
              dpsdhp1(i,j) = -0.5d0 * (dpsdhp1(1,j)-3.0d0*delta(1,j))
            end do
           end do
c                                                         ---- theta'=pi
        else
          i = 3
          call ummdp_yield_yld2004_dpsdhp ( i,psp1,hp1,dpsdhp1 )
          do i = 1,2
            do j = 1,3
              dpsdhp1(i,j) = -0.5d0 * (dpsdhp1(3,j)-3.0d0*delta(1,j))
            end do
           end do
        end if
c                                                 ---- theta''<>0 & <>pi
        if ( abs(cetpq2-1.0d0) >= eps2 .and. 
     1       abs(cetpq2+1.0d0) >= eps2 ) then
          do i = 1,3
            call ummdp_yield_yld2004_dpsdhp ( i,psp2,hp2,dpsdhp2 ) 
          end do
c                                                         ---- theta''=0
        else if ( abs(cetpq2-1.0d0) < eps2 ) then
          i = 1
          call ummdp_yield_yld2004_dpsdhp ( i,psp2,hp2,dpsdhp2 )
          do i = 2,3
            do j = 1,3
              dpsdhp2(i,j) = -0.5d0 * (dpsdhp2(1,j)-3.0d0*delta(1,j))
            end do
           end do
c                                                        ---- theta''=pi
        else
          i = 3
          call ummdp_yield_yld2004_dpsdhp ( i,psp2,hp2,dpsdhp2 )
          do i = 1,2
            do j = 1,3
              dpsdhp2(i,j) = -0.5d0 * (dpsdhp2(3,j)-3.0d0*delta(1,j))
            end do
           end do
        end if
c
        do i = 1,3
          do j = 1,3
            dfadhp1(i) = dfadhp1(i) + dfadpsp1(j)*dpsdhp1(j,i)
            dfadhp2(i) = dfadhp2(i) + dfadpsp2(j)*dpsdhp2(j,i)
          end do
        end do
c                                                       ---- d(hp)/d(sp)
        dhdsp1 = 0.0d0
        dhdsp2 = 0.0d0
        do i = 1,3
          j = mod(i,  3) + 1
          k = mod(i+1,3) + 1
          l = mod(i,  3) + 4
          if ( i == 1 ) l = 6
          if ( i == 2 ) l = 5
          dhdsp1(1,i) =  1.0d0/3.0d0
          dhdsp2(1,i) =  1.0d0/3.0d0
          dhdsp1(2,i) = -1.0d0/3.0d0 * (sp1(j)+sp1(k))
          dhdsp2(2,i) = -1.0d0/3.0d0 * (sp2(j)+sp2(k))
          dhdsp1(3,i) =  1.0d0/2.0d0 * (sp1(j)*sp1(k)-sp1(l)**2)
          dhdsp2(3,i) =  1.0d0/2.0d0 * (sp2(j)*sp2(k)-sp2(l)**2)
        end do
        do i = 4,6
          k = mod(i+1,3) + 1
          l = mod(i,  3) + 4
          m = mod(i+1,3) + 4
          if ( i == 5 ) k = 2
          if ( i == 6 ) k = 1
          dhdsp1(2,i) = 2.0d0/3.0d0 * sp1(i)
          dhdsp2(2,i) = 2.0d0/3.0d0 * sp2(i)
          dhdsp1(3,i) = sp1(l)*sp1(m) - sp1(k)*sp1(i)
          dhdsp2(3,i) = sp2(l)*sp2(m) - sp2(k)*sp2(i)
        end do
c                                                        ---- d(sp)/d(s)
        do i = 1,6
          do j = 1,6
            dsdsp1(i,j) = ctp1(i,j)
            dsdsp2(i,j) = ctp2(i,j)
          end do
        end do
c                                                       ---- d(fai)/d(s)
        xx1 = 0.0d0
        xx2 = 0.0d0
        dfads = 0.0d0
        do l = 1,6
          do j = 1,3
            do k = 1,6
              xx1(j,l) = xx1(j,l) + dhdsp1(j,k)*dsdsp1(k,l)
              xx2(j,l) = xx2(j,l) + dhdsp2(j,k)*dsdsp2(k,l)
            end do
            dfads(l) = dfads(l) +
     1                 dfadhp1(j)*xx1(j,l) + 
     2                 dfadhp2(j)*xx2(j,l)
          end do
        end do
c                                                        ---- d(se)/d(s)
        dsedfa = fai**(ami-1.0d0) / am / dc**ami
        do i = 1,6
          dseds(i) = dsedfa*dfads(i)
        end do
c
      endif
c                                            ---- 2nd order differential
      if ( nreq >= 2 ) then
c                                                   ---- d2(fai)/d(psp)2
        d2fadpsp11 = 0.0d0
        d2fadpsp22 = 0.0d0
        d2fadpsp12 = 0.0d0
        d2fadpsp21 = 0.0d0
        do i = 1,3
          d2fadpsp11(i,i) = am*(am-1.0d0) *
     1                      ( abs(psp1(i)-psp2(1))**(am-2.0d0) +
     2                        abs(psp1(i)-psp2(2))**(am-2.0d0) +
     3                        abs(psp1(i)-psp2(3))**(am-2.0d0) )
          d2fadpsp22(i,i) = am*(am-1.0d0) * 
     1                      ( abs(psp1(1)-psp2(i))**(am-2.0d0) +
     2                        abs(psp1(2)-psp2(i))**(am-2.0d0) +
     3                        abs(psp1(3)-psp2(i))**(am-2.0d0) )
          do j = 1,3
            d2fadpsp12(i,j) = -am*(am-1.0d0) * 
     1                         abs(psp1(i)-psp2(j))**(am-2.0d0)
            d2fadpsp21(i,j) = -am*(am-1.0d0) *
     1                         abs(psp1(j)-psp2(i))**(am-2.0d0)
          end do
        end do
c                                                    ---- d2(psp)/d(hp)2
        if ( abs(cetpq1-1.0d0) >= eps3 .and. 
     1       abs(cetpq2-1.0d0) >= eps3 .and.
     2       abs(cetpq1+1.0d0) >= eps3 .and. 
     3       abs(cetpq2+1.0d0) >= eps3 ) then
c
          d2psdhp11 = 0.0d0
          d2psdhp22 = 0.0d0
          do i = 1,3
            call ummdp_yield_yld2004_d2psdhp ( i,psp1,hp1,d2psdhp11 )                                             
            call ummdp_yield_yld2004_d2psdhp ( i,psp2,hp2,d2psdhp22 )                                 
          end do
c                                                    ---- d2(fai)/d(hp)2
c                                                  -- d2(fai)/d(hd)d(hd)
          d2fadhp11 = 0.0d0
          do iq = 1,3
            do m = 1,3
              do ip = 1,3
                do l = 1,3
                  d2fadhp11(iq,m) = d2fadhp11(iq,m)
     1                              + d2fadpsp11(ip,l)
     2                                * dpsdhp1(l,m)*dpsdhp1(ip,iq)
                end do
                d2fadhp11(iq,m) = d2fadhp11(iq,m)
     1                            + dfadpsp1(ip)*d2psdhp11(ip,iq,m)
              end do
            end do
          end do
c                                              ---- d2(fai)/d(hdd)d(hdd)
          d2fadhp22 = 0.0d0
          do iq = 1,3
            do m = 1,3
              do ip = 1,3
                do l = 1,3
                  d2fadhp22(iq,m) = d2fadhp22(iq,m)
     1                              + (d2fadpsp22(ip,l)
     2                                 * dpsdhp2(l,m)*dpsdhp2(ip,iq) )
                end do
                d2fadhp22(iq,m) = d2fadhp22(iq,m) + 
     1                            dfadpsp2(ip)*d2psdhp22(ip,iq,m)
              end do
            end do
          end do
c                         ---- d2(fai)/d(hdd)d(hd) & d2(fai)/d(hd)d(hdd)
          d2fadhp12 = 0.0d0
          d2fadhp21 = 0.0d0
          do iq = 1,3
            do m = 1,3
              do ip = 1,3
                do l = 1,3
                  d2fadhp12(iq,m) = d2fadhp12(iq,m)
     1                              + (d2fadpsp12(ip,l)
     2                                 * dpsdhp2(l,m)*dpsdhp1(ip,iq))
                  d2fadhp21(iq,m) = d2fadhp21(iq,m)
     1                              + d2fadpsp21(ip,l)
     2                                * dpsdhp1(l,m)*dpsdhp2(ip,iq)
                end do
               end do
            end do
          end do
c                                                     ---- d2(hp)/d(sp)2
          d2hdsp11 = 0.0d0
          d2hdsp22 = 0.0d0
          do i = 1,3
            j = mod(i,  3) + 1
            k = mod(i+1,3) + 1
            dummy = -1.0d0 / 3.0d0
            d2hdsp11(2,i,j) = dummy
            d2hdsp11(2,j,i) = dummy
            d2hdsp22(2,i,j) = dummy
            d2hdsp22(2,j,i) = dummy
            d2hdsp11(3,i,j) = sp1(k) / 2.0d0
            d2hdsp11(3,j,i) = sp1(k) / 2.0d0
            d2hdsp22(3,i,j) = sp2(k) / 2.0d0
            d2hdsp22(3,j,i) = sp2(k) / 2.0d0
          end do
          do i = 4,6
            j = mod(i,  3) + 4
            k = mod(i+1,3) + 1
            m = mod(i+1,3) + 4
            if ( i == 5 ) k = 2
            if ( i == 6 ) k = 1
            dummy = 2.0d0 / 3.0d0
            d2hdsp11(2,i,i) = dummy
            d2hdsp22(2,i,i) = dummy
            d2hdsp11(3,i,i) = -sp1(k)
            d2hdsp22(3,i,i) = -sp2(k)
            d2hdsp11(3,i,j) =  sp1(m)
            d2hdsp11(3,j,i) =  sp1(m)
            d2hdsp22(3,i,j) =  sp2(m)
            d2hdsp22(3,j,i) =  sp2(m)
          end do
          do i = 1,3
            j = mod(i,3) + 4
            if ( i == 1 ) j = 6
            if ( i == 2 ) j = 5
            d2hdsp11(3,i,j) = -sp1(j)
            d2hdsp11(3,j,i) = -sp1(j)
            d2hdsp22(3,i,j) = -sp2(j)
            d2hdsp22(3,j,i) = -sp2(j)
          end do
c                                                     ---- d2(fai)/d(s)2
          xx1 = 0.0d0
          xx2 = 0.0d0
          do i = 1,3
            do j = 1,6
              do ip = 1,6
                xx1(i,j) = xx1(i,j) + dhdsp1(i,ip)*dsdsp1(ip,j)
                xx2(i,j) = xx2(i,j) + dhdsp2(i,ip)*dsdsp2(ip,j)
              end do
            end do
          end do
c
          d2fads2 = 0.0d0
          do i = 1,6
            do j = 1,6
              do iq = 1,3
                do m = 1,3
                  d2fads2(i,j) = d2fads2(i,j) +
     1                           + d2fadhp11(iq,m)*xx1(iq,i)*xx1(m,j)
     2                           + d2fadhp12(iq,m)*xx1(iq,i)*xx2(m,j)
     3                           + d2fadhp21(iq,m)*xx2(iq,i)*xx1(m,j)
     4                           + d2fadhp22(iq,m)*xx2(iq,i)*xx2(m,j)
                end do
                do n = 1,6
                  do ir = 1,6
                    d2fads2(i,j) = d2fads2(i,j) +
     1                             + d2hdsp11(iq,ir,n)*dfadhp1(iq)
     2                               * dsdsp1(ir,i)*dsdsp1(n,j)
     3                             + d2hdsp22(iq,ir,n)*dfadhp2(iq)
     4                               * dsdsp2(ir,i)*dsdsp2(n,j)
                  end do
                end do
              end do
            end do
          end do
c                                                      ---- d2(se)/d(s)2
          d2sedfa2 = ami * (ami-1.0d0) * fai**(ami-2.0d0) / dc**ami
          do i = 1,6
            do j = 1,6
              d2seds2(i,j) = d2sedfa2*dfads(i)*dfads(j)
     1                       + dsedfa*d2fads2(i,j)
            end do
          end do
        else
c                                            ---- numerical differential
          call ummdp_yield_yld2004_nu2 ( ctp1,ctp2,s,se,am,ami,dc,pi,
     1                                   del,d2seds2 )
        end if
      end if
c
      return
      end
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     COEFFICIENT OF EQUIVALENT STRESS I
c
      subroutine ummdp_yield_yld2004_coef ( cp1,cp2,pi,am,dc )
c
c-----------------------------------------------------------------------
      implicit none
c
      real*8 pi,am,dc
      real*8 cp1(6,6),cp2(6,6)
c
      integer i,j
      real*8 bbp1(3),bbp2(3)
c-----------------------------------------------------------------------
c
      call ummdp_yield_yld2004_coef_sub ( cp1,pi,bbp1 )
      call ummdp_yield_yld2004_coef_sub ( cp2,pi,bbp2 )
      dc = 0.0d0
      do i = 1,3
        do j = 1,3
          dc = dc + (abs(bbp1(i)-bbp2(j)))**am
        end do
      end do
c
      return
      end subroutine ummdp_yield_yld2004_coef
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     COEFFICIENT OF EQUIVALENT STRESS II
c
      subroutine ummdp_yield_yld2004_coef_sub ( cp,pi,bbp )
c
c-----------------------------------------------------------------------
      implicit none
c
      real*8 pi
      real*8 cp(6,6)
c
      real*8 ppp,qqp,ttp
      real*8 aap(3),bbp(3)
c-----------------------------------------------------------------------
c                                                  ---- coefficients aap
      aap(1) = (cp(1,2)+cp(1,3)-2.0d0*cp(2,1)
     1          + cp(2,3)-2.0d0*cp(3,1)+cp(3,2))/9.0d0
      aap(2) = ((2.0d0*cp(2,1)-cp(2,3))*(cp(3,2)-2.0d0*cp(3,1))
     2          + (2.0d0*cp(3,1)-cp(3,2))*(cp(1,2)+cp(1,3))
     3          + (cp(1,2)+cp(1,3))*(2.0d0*cp(2,1)-cp(2,3)))/2.7d1
      aap(3) = (cp(1,2)+cp(1,3))*(cp(2,3)-2.0d0*cp(2,1))
     1         *(cp(3,2)-2.0d0*cp(3,1))/5.4d1
c                                          ---- coefficients ppp,qqp,ttp
      ppp = aap(1)**2 + aap(2)
      qqp = (2.0d0*aap(1)**3+3.0d0*aap(1)*aap(2)+2.0d0*aap(3)) / 2.0d0
      ttp = acos(qqp / ppp**(3.0d0/2.0d0))
c                                                  ---- coefficients bbp
      bbp(1) = 2.0d0*sqrt(ppp)*cos(ttp/3.0d0) + aap(1)
      bbp(2) = 2.0d0*sqrt(ppp)*cos((ttp+4.0d0*pi)/3.0d0) + aap(1)
      bbp(3) = 2.0d0*sqrt(ppp)*cos((ttp+2.0d0*pi)/3.0d0) + aap(1)
c
      return
      end subroutine ummdp_yield_yld2004_coef_sub
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     YIELD FUNCTION I
c
      subroutine ummdp_yield_yld2004_yf ( ctp1,ctp2,s,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,se )
c
c-----------------------------------------------------------------------
      implicit none
c
      real*8 am,ami,dc,pi,cetpq1,cetpq2,fai,se
      real*8 s(6),sp1(6),sp2(6),psp1(3),psp2(3),hp1(3),hp2(3)
      real*8 ctp1(6,6),ctp2(6,6)
c
      integer i,j
c-----------------------------------------------------------------------
      call ummdp_yield_yld2004_yfsub ( ctp1,s,pi,sp1,psp1,hp1,cetpq1 )                 
      call ummdp_yield_yld2004_yfsub ( ctp2,s,pi,sp2,psp2,hp2,cetpq2 )                                   
c                                                    ---- yield function
      fai = 0.0d0
      do i = 1,3
        do j = 1,3
          fai = fai + (abs(psp1(i)-psp2(j)))**am
        end do
      end do
c                                                 ---- equivalent stress
      se = (fai/dc) ** ami
c
      return
      end subroutine ummdp_yield_yld2004_yf
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     CALCULATE YIELD FUNCTION II
c
      subroutine ummdp_yield_yld2004_yfsub ( ctp,s,pi,sp,psp,hp,cetpq )
     1
c
c-----------------------------------------------------------------------
      implicit none
c
      real*8 pi,cetpq
      real*8 s(6),sp(6),psp(3),hp(3)
      real*8 ctp(6,6)
c
      integer i
      real*8 hpq,cep,ceq,cet
c-----------------------------------------------------------------------
c
c                                         ---- linear-transformed stress
      call ummdp_utility_mv ( sp,ctp,s,6,6 )
c
c                                                  ---- invariants of sp
      hp(1) = (sp(1)+sp(2)+sp(3)) / 3.0d0
      hp(2) = (sp(5)**2+sp(6)**2+sp(4)**2
     1         - sp(2)*sp(3)-sp(3)*sp(1)-sp(1)*sp(2)) / 3.0d0
      hp(3) = (2.0d0*sp(5)*sp(6)*sp(4)+sp(1)*sp(2)*sp(3)
     1         - sp(1)*sp(6)**2-sp(2)*sp(5)**2-sp(3)*sp(4)**2) / 2.0d0
c
c                           ---- coefficients of characteristic equation
      hpq = sqrt(hp(1)**2 + hp(2)**2 + hp(3)**2)
      if ( hpq > 1.0e-16 ) then
        cep = hp(1)**2 + hp(2)
        ceq = (2.0d0*hp(1)**3+3.0d0*hp(1)*hp(2)+2.0d0*hp(3)) / 2.0d0
        cetpq = ceq / cep**(3.0d0/2.0d0)
        if ( cetpq >  1.0d0 ) cetpq =  1.0d0
        if ( cetpq < -1.0d0 ) cetpq = -1.0d0
        cet = acos(cetpq)
c
c                                           ---- principal values of sp1
        psp(1) = 2.0d0*sqrt(cep)*cos(cet/3.0d0) + hp(1)
        psp(2) = 2.0d0*sqrt(cep)*cos((cet+4.0d0*pi)/3.0d0) + hp(1)
        psp(3) = 2.0d0*sqrt(cep)*cos((cet+2.0d0*pi)/3.0d0) + hp(1)
      else
        cetpq = 0.0
        do i = 1,3
          psp(i) = 0.0
        end do
      end if
c
      return
      end subroutine ummdp_yield_yld2004_yfsub
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     NUMERICAL DIFFERENTIATION FOR 2ND ORDER DERIVATIVES
c
      subroutine ummdp_yield_yld2004_nu2 ( ctp1,ctp2,s,se,am,ami,dc,pi,
     1                                     del,d2seds2 )
c
c-----------------------------------------------------------------------
      implicit none
c
      real*8 se,am,ami,dc,pi,del
      real*8 s(6)
      real*8 ctp1(6,6),ctp2(6,6),d2seds2(6,6)
c
      integer i,j
      real*8 cetpq1,cetpq2,fai,sea,seb,seaa,seba,seab,sebb,abc1,abc2
      real*8 sp1(6),sp2(6),psp1(3),psp2(3),hp1(3),hp2(3),s0(6)
c-----------------------------------------------------------------------
c
      s0(:) = s(:)
      do i = 1, 6
        do j = 1, 6
          if ( i == j ) then
            s0(i) = s(i) - del
            call ummdp_yield_yld2004_yf ( ctp1,ctp2,s0,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,sea )
            s0(i) = s(i) + del
            call ummdp_yield_yld2004_yf ( ctp1,ctp2,s0,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,seb )
            s0(i) = s(i)
            abc1 = (se-sea) / del
            abc2 = (seb-se) / del
            d2seds2(i,j) = (abc2-abc1) / del
          else
            s0(i) = s(i) - del
            s0(j) = s(j) - del
            call ummdp_yield_yld2004_yf ( ctp1,ctp2,s0,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,seaa )
            s0(i) = s(i) + del
            s0(j) = s(j) - del
            call ummdp_yield_yld2004_yf ( ctp1,ctp2,s0,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,seba )
            s0(i) = s(i) - del
            s0(j) = s(j) + del
            call ummdp_yield_yld2004_yf ( ctp1,ctp2,s0,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,seab )
            s0(i) = s(i) + del
            s0(j) = s(j) + del
            call ummdp_yield_yld2004_yf ( ctp1,ctp2,s0,am,ami,dc,pi,sp1,
     1                                    sp2,psp1,psp2,hp1,hp2,cetpq1,
     2                                    cetpq2,fai,sebb )
            s0(i) = s(i)
            s0(j) = s(j)
            abc1 = (seba-seaa) / (2.0d0*del)
            abc2 = (sebb-seab) / (2.0d0*del)
            d2seds2(i,j) = (abc2-abc1) / (2.0d0*del)
          end if
        end do
      end do
c
      return
      end subroutine ummdp_yield_yld2004_nu2
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     CALCULATE d(psp)/d(hp)
c
      subroutine ummdp_yield_yld2004_dpsdhp ( i,psp,hp,dpsdhp )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer i
      real*8 psp(3),hp(3)
      real*8 dpsdhp(3,3)
c
      real*8 dummy
c-----------------------------------------------------------------------
c
      dummy = psp(i)**2-2.0d0*hp(1)*psp(i) - hp(2)
      dpsdhp(i,1) = psp(i)**2/dummy
      dpsdhp(i,2) = psp(i) / dummy
      dpsdhp(i,3) = 2.0d0/3.0d0/dummy
c
      return
      end subroutine ummdp_yield_yld2004_dpsdhp
c
c
c
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c     CALCULATE d2(psp)/d(hp)2
c
      subroutine ummdp_yield_yld2004_d2psdhp ( i,psp,hp,d2psdhp )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer i
      real*8 psp(3),hp(3)
      real*8 d2psdhp(3,3,3)
c
      real*8 dummy
c-----------------------------------------------------------------------
      dummy = (psp(i)**2-2.0d0*hp(1)*psp(i)-hp(2)) ** 3
      d2psdhp(i,1,1) = 2.0d0*psp(i)**3*
     1                 (psp(i)**2-3.0d0*hp(1)*psp(i)-2.0d0*hp(2))/dummy
      d2psdhp(i,2,2) = -2.0d0*psp(i) * (hp(1)*psp(i)+hp(2)) / dummy
      d2psdhp(i,3,3) = -8.0d0/9.0d0 * (psp(i)-hp(1)) / dummy
      d2psdhp(i,1,2) = psp(i)**2 * 
     1                (psp(i)**2-4.0d0*hp(1)*psp(i)-3.0d0*hp(2)) / dummy
      d2psdhp(i,2,1) = d2psdhp(i,1,2)
      d2psdhp(i,2,3) = -2.0d0 * (psp(i)**2+hp(2)) / 3.0d0 / dummy
      d2psdhp(i,3,2) = d2psdhp(i,2,3)
      d2psdhp(i,3,1) = -4.0d0 * psp(i) * (hp(1)*psp(i)+hp(2)) /
     1                  3.0d0 / dummy
      d2psdhp(i,1,3) = d2psdhp(i,3,1)
c
      return
      end subroutine ummdp_yield_yld2004_d2psdhp
c
c
c
