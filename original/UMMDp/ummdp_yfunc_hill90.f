c------------------------------------------------------------
c------------------------------------------------------------
c     Hill-1990 anisotropic yield function and its dfferentials
c
c     ---( 1990 ) Pergamon Press Plc.
c by R.Hill( Department of Applied Mathematics and Theoretical Physics,
c            University of Cambridge, Campridge CB#)EW, U.K)
c
c "Constutive Modelling of Orthotropic Plasticity in Sheet Metals"
c  Recieved in 18 July 1989)
c J.Mech. Physics. Solids Vol.38, No.3, pp-405-417,  1990
c Printed in Great Britain
c------------------------------------------------------------
c  coded by Tatsuhiko Ine ( at NIED ), 22/11/2010
c------------------------------------------------------------
c
      subroutine jancae_hill90 ( s,se,dseds,d2seds2,nreq,
     &                           pryld,ndyld )
c------------------------------------------------------------c
c input arguments
c s(3) :  stress 6-components -> in this program only use 3 stress components
c         but we define that stress array has 6 components.
c pryld(ndyld)  : material parameter for anisotropic yield function of Hill's 1990
c          : pryld(1+1)= a 
c          : pryld(1+2)= b
c          : pryld(1+3)= tau
c          : pryld(1+4)= sigb
c          : pryld(1+5)= m  (=>am)
c   nreq   : request code = 0 ( output equivalent stress only)
c          : request code = 1 ( output equivalent stress=se , dseds(3) )
c          : request code = 2 ( output equivalent stress=se , dseds(3),  d2seds2(3,3) )
c
c------------------------------------------------------------c
c output arguments
c se       : equivalent strss
c dseds(3) : differential coefficient of first order 
c          : equivalent strss defferentiated by stress (6 components)
c d2seds2(3,3) : differential coefficient of second order
c              : equivalent strss defferentiated by stress (6 components)
c------------------------------------------------------------c
c
c a1(3)        : vector to calc for equivalent stress 
c a2(3,3) : matrix to calc for equivalent stress 
c a3(3,3) : matrix to calc for equivalent stress 
c a4(3,3) : matrix to calc for equivalent stress 
c
c dfds1(3) : df1/ds =fai1 1st order derivative by stress
c dfds2(3) : df2/ds =fai2 1st order derivative by stress
c dfds3(3) : df3/ds =fai3 1st order derivative by stress
c dfds4(3) : df4/ds =fai4 1st order derivative by stress
c
c
c dxds1(3) : dx1/ds =x1 1st order derivative by stress
c dxds2(3) : dx2/ds =x2 1st order derivative by stress
c dxds3(3) : dx3/ds =x3 1st order derivative by stress
c dxds4(3) : dx4/ds =x4 1st order derivative by stress
c
c d2fds1(3,3) : d2f1/ds2 =fai1 2nd order derivative by stress
c d2fds2(3,3) : d2f2/ds2 =fai2 2nd order derivative by stress
c d2fds3(3,3) : d2f3/ds2 =fai3 2nd order derivative by stress
c d2fds4(3,3) : d2f4/ds2 =fai4 2nd order derivative by stress
c d2fds_t(3,3) : d2f/ds2 =fai  2nd order derivative by stress
c 
c------------------------------------------------------------c
      implicit real*8 (a-h,o-z)
c
      dimension s(3),dseds(3),d2seds2(3,3),pryld(ndyld)
      dimension c(3,3),v(3)
c
      dimension A1(3),A2(3,3),A3(3,3)
     &         ,A4(3,3)
c
      dimension dfds1(3),dfds2(3),dfds3(3)
     &         ,dfds4(3),dfds_t(3)
      dimension dxds1(3),dxds2(3),dxds3(3)
     &         ,dxds4(3)
c
      dimension d2fds1(3,3),d2fds2(3,3)
     &         ,d2fds3(3,3)
     &         ,d2fds4(3,3)
     &         ,d2fds_t(3,3)
c
      dimension dx1dx1(3,3),dx2dx2(3,3)
     &         ,dx3dx3(3,3)
     &         ,dx4dx4(3,3)
c
      dimension df4df3(3,3),df3df4(3,3)
c
      dimension d2xds1(3,3),d2xds2(3,3)
     &         ,d2xds3(3,3)
     &         ,d2xds4(3,3)
      character text*32
c
c---  define a1-matrix, a2-matrix
      data a1/ 1.0d0 , 1.0d0 , 0.0d0 /,
     &     a2/ 1.0d0 ,-1.0d0 , 0.0d0 ,
     &        -1.0d0 , 1.0d0 , 0.d00 ,
     &         0.0d0 , 0.0d0 , 4.0d0 /,
     &     a3/ 1.0d0 , 0.0d0 , 0.0d0 ,
     &         0.0d0 , 1.0d0 , 0.0d0 ,
     &         0.0d0 , 0.0d0 , 2.0d0 /
c
c                                      anisotropic parameters
       a      =  pryld(1+1)
       b      =  pryld(1+2)
       tau    =  pryld(1+3)
       sigb   =  pryld(1+4)
       am      = pryld(1+5)
c
       syini   =  1.0d0
       sigbtm =(sigb/tau)**am
       alarge = 1.0d0 + sigbtm -2.0d0*a + b
c
c
c                            coef. matrix of material parameters
c---  define a4-matrix consists of a & b     
       call jancae_clear2( a4,3,3 )
       a4(1,1) = -2.0d0*a +  b
       a4(2,2) =  2.0d0*a +  b
       a4(1,2) =          - b
       a4(2,1) =          - b
c
c--- fai1
      x1=s(1)+s(2)
      fai1=(abs( x1 ))**am
c
c--- fai2
      call jancae_mv  ( v,a2,s,3,3 )
      call jancae_vvs ( x2,s,v,3 )
      fai2= sigbtm * ( x2 )**(am/2.0d0)
c
c--- fai3
      call jancae_mv  ( v,a3,s,3,3 )
      call jancae_vvs ( x3,s,v,3 )
      fai3=  ( x3 )**(am/2.0d0-1.0d0)
c
c--- fai4
      call jancae_mv  ( v,a4,s,3,3 )
      call jancae_vvs ( x4,s,v,3 )
      fai4=  ( x4 )
c
c--- yield fuction : fyild
      fyild= fai1 + fai2 + fai3*fai4
c
c                                          equivalent stress
      se= (fyild/alarge)**(1.0d0/am)
c
      if ( nreq.eq.0 ) return
c
c--------------------------------------------------------------------c
c--- 1st order differential coefficient of yield fuction
c     dfdsi(i) : diff. of fai-i(i) with respect to s(j)
c     dxdsi(i) : diff. of x-i(i) with respect to s(j)
c                         1st order differential of x_number_i
c
c
c--- dfai1/ds
      dxds1(1)=1.0
      dxds1(2)=1.0
      dxds1(3)=0.0
c
      wrk= am * ( abs(x1)**(am-2) )*x1
        do i=1,3 
         dfds1(i)=wrk*dxds1(i)
        enddo
c
c--- dfai2/ds
      wrk= sigbtm * (am/2.0) * ( x2 )**(am/2.0-1.0)
      call jancae_mv( dxds2,a2,s,3,3 )
        do i=1,3 
         dxds2(i) = 2.0 *  dxds2(i)
         dfds2(i) = wrk * dxds2(i)
        enddo
c
c--- dfai3/ds
      wrk= (am/2.0-1.0) * ( x3 )**(am/2.0-2.0)
      call jancae_mv( dxds3,a3,s,3,3 )
        do i=1,3 
         dxds3(i) = 2.0 * dxds3(i) 
         dfds3(i) = wrk * dxds3(i) 
        enddo
c
c--- dfai4/ds
      call jancae_mv( dxds4,a4,s,3,3 )
        do i=1,3 
         dxds4(i)=  2.0 * dxds4(i) 
         dfds4(i)=  dxds4(i) 
        enddo
c
c
c--- 1st order differential coefficient of yield fuction result
c--- dfai/ds()= result = dfds_t(i)
c
        do i=1,3 
          dfds_t(i)=dfds1(i)+dfds2(i)+dfds3(i)*fai4+fai3*dfds4(i)
        enddo
c
c--- 1st order differential coefficient of equivalent stress
c
        wrk= (abs(fyild/alarge))**(1.0/am-1.0) / ( am*alarge )
        do i=1,3 
          dseds(i)= wrk * dfds_t(i)
        enddo
c
c
        if ( nreq.eq.1 ) return
c
c--------------------------------------------------------------------c
c--- 2st order differential coefficient of equivalent stress
c                                       with respect to s(j)
c--------------------------------------------------------------------c
c     dfds_t(3,3) : 2nd order differ of fai by s(j) & s(k)
c     df2ds1(3,3)
c                    : 2nd order diff. of  s(j) & s(k)
c--------------------------------------------------------------------c
c
c--- d2fai1/ds2
       wrk = am*(am-1.0)*( abs(x1) )**(am-2.0)
        do i=1,3 
         do j=1,3  
          d2fds1(i,j) = wrk * dxds1(i)*dxds1(j)
         enddo
        enddo
c
c
c-----------------------------------------------------------c
c--- d2fai2/ds2
      wrk1= sigbtm * (am/2.0)
        if( abs(x2).lt.1e-10) then
           x2=1e-10
        end if
      wrk2=(am/2.0-1.0) * ( x2**(am/2.0-2.0) )
      wrk3=  x2**(am/2.0-1.0)
      wrk2 = wrk1 * wrk2
      wrk3 = wrk1 * wrk3
c
c---    make [ dx2 * dx2(t) ] & [d2x/ds2] & make [d2fai2/ds2]
        do i=1,3 
         do j=1,3 
         dx2dx2(i,j)=dxds2(i)*dxds2(j)
         d2xds2(i,j)=2.0*a2(j,i)
         d2fds2(i,j)= wrk2 * dx2dx2(i,j) + wrk3 * d2xds2(i,j)
         enddo
        enddo
c
c
c-----------------------------------------------------------c
c--- d2fai3/ds2   make   d2fds3(i,j)
      wrk1 =(am/2.0-1.0)
      wrk2 =(am/2.0-2.0) * ( x3**(am/2.0-3.0) )
      wrk3 = x3**(am/2.0-2.0) 
      wrk2 =  wrk1 * wrk2
      wrk3 =  wrk1 * wrk3
c                        
c---                [d2x3/ds2] &  make [d2fai3/ds2]
        do i=1,3 
         do j=1,3 
          dx3dx3(i,j)= dxds3(i)*dxds3(j)
          d2xds3(i,j)= 2.0 * a3(j,i)
          d2fds3(i,j)= wrk2 * dx3dx3(i,j) + wrk3 * d2xds3(i,j) 
         enddo
        enddo
c
c---                [d2fai3/ds2]*fai4
        do i=1,3 
         do j=1,3 
          d2fds3(i,j)= d2fds3(i,j) * fai4
         enddo
        enddo
c
c---                [dfai4/ds]*[dfai3/ds](T)
        do i=1,3 
         do j=1,3 
          df4df3(i,j)= dfds4(i)*dfds3(j)
         enddo
        enddo
c
c
c-----------------------------------------------------------c
c--- d2fai4/ds2
c---          ---make [d2fai3/ds2]
        do i=1,3 
         do j=1,3 
          d2fds4(i,j)=  2.0*a4(i,j)
         enddo
        enddo
c
c-----------------------------------------------------------c
c--- 2nd order differential coefficient of yield fuction result
c--- d2fai/ds2()= result = d2fds_t(i)
c
        do i=1,3 
         do j=1,3 
           d2fds_t(i,j) =    d2fds1(i,j)  + d2fds2(i,j)
     &               +  d2fds3(i,j)*fai4  + df4df3(i,j) 
     &               +  df4df3(j,i)       + fai3 * d2fds4(i,j) 
         enddo
        enddo
c
c
c--- 2n order differential coefficient of equivalent stress by stress
c
        wrk1 = 1.0/(am*alarge)
        wrk2 = (1.0/am-1.0)/alarge
        wrk3 = (fyild/alarge)**(1.0/am-2.0)
        wrk4 = (fyild/alarge)**(1.0/am-1.0)
        wrk2 =  wrk1  * wrk2* wrk3
        wrk4 =  wrk1  * wrk4
c
        do i=1,3 
         do j=1,3 
          d2seds2(i,j)=  wrk2 * dfds_t(i)* dfds_t(j)
     &                 + wrk4 * d2fds_t(i,j)
         enddo
        enddo
c
c
c
      return
      end
c

c
c
