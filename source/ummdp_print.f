************************************************************************
*
*     PRINT SUBROUTINES
*
************************************************************************
c
c     ummdp_print_ummdp ( )
c       print ummmdp separator
c
c     ummdp_print_elastic ( prela,ndela )
c       print elasticity parameters
c
c     ummdp_print_yield ( pryld,ndyld )
c       print yield criteria parameters
c
c     ummdp_print_isotropci ( prihd,ndihd )
c       print isotropic hardening law parameters
c
c     ummdp_print_kinematic ( prkin,ndkin,npbs )
c       print kinematic hardening law parameters
c
c     ummdp_print_rupture ( prrup,ndrup )
c       print uncoupled rupture criterion parameters
c
c     ummdp_print_info
c       print info for debug (info)
c
c     ummdp_print_inout
c       print info for debug (input/output)
c
c     ummdp_print_element ( )
c       print element info
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT UMMDP SEPARATOR
c
      subroutine ummdp_print_ummdp ( )
c
c-----------------------------------------------------------------------
      implicit none
c
      character*20 fmt
c-----------------------------------------------------------------------
c
      fmt = '(1/,4xA,1/)'
      write (6,fmt) '~~~~~~~~~~~~~~~~~~ UMMDp ~~~~~~~~~~~~~~~~~~'
c
      return
      end subroutine ummdp_print_ummdp
c
c
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT ELASTICITY PARAMETERS
c
      subroutine ummdp_print_elastic ( prela,ndela )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer ndela
      real*8 prela(ndela)
c
      integer ntela,i
      character*50 fmtpr
c-----------------------------------------------------------------------
c
      ntela = nint(prela(1))
      write (6,'(/12xA,i1)') '> Elasticity | ',ntela
c
      fmtpr = '(16xA10,I1,A3,E20.12)'
      do i = 1,ndela-1
        write (6,fmtpr) '. prela(1+',i,') =',prela(i+1)
      end do
c
      return
      end subroutine ummdp_print_elastic
c
c
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT YIELD FUNCTION PARAMETERS
c
      subroutine ummdp_print_yield ( pryld,ndyld )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer ndyld
      real*8 pryld(ndyld)
c
      integer i,j
      integer ntyld
      character*50 fmtid,fmtpr
c-----------------------------------------------------------------------
c
      fmtid = '(/12XA,I1)'
c
      ntyld = pryld(1)
      if ( ntyld < 0 ) fmtid = '(/12XA,I2)'
      write (6,fmtid) '> Yield Function | ',ntyld
C
      fmtpr = '(16xA10,I1,A3,E20.12)'
      do i = 1,ndyld-1
        write (6,fmtpr) '. pryld(1+',i,') =',pryld(i+1)
      end do
c
      return
      end subroutine ummdp_print_yield
c
c
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT ISOTROPIC HARDENING LAW PARAMETERS
c
      subroutine ummdp_print_isotropic ( prihd,ndihd )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer ndihd
      real*8 prihd(ndihd)
c
      integer ntihd,i
      character*50 fmtpr
c-----------------------------------------------------------------------
c
      ntihd = nint(prihd(1))
c
      write (6,'(/12xA,I1)') '> Isotropic Hardening Law | ',ntihd
c
      fmtpr = '(16xA10,I1,A3,E20.12)'
      do i = 1,ndihd-1
        write (6,fmtpr) '. prihd(1+',i,') =',prihd(i+1)
      end do
c
      return
      end subroutine ummdp_print_isotropic
c
c
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT KINEMATIC HARDENING LAW PARAMETERS
c
      subroutine ummdp_print_kinematic ( prkin,ndkin )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer ndkin
      real*8 prkin(ndkin)
c
      integer i
      integer ntkin
      character*50 fmtpr
c-----------------------------------------------------------------------
c
      ntkin = nint(prkin(1))
c
      write (6,'(/12xA,I1)') '> Kinematic Hardening Law | ',ntkin
c
      fmtpr = '(16xA10,I1,A3,E20.12)'
      do i = 1,ndkin-1
        write (6,fmtpr) '. prkin(1+',i,') =',prkin(i+1)
      end do
c
      return
      end subroutine ummdp_print_kinematic
c
c
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT UNCOUPLED RUPTURE CRITERION PARAMETERS
c
      subroutine ummdp_print_rupture ( prrup,ndrup )
c
c-----------------------------------------------------------------------
      implicit none
c
      integer ndrup
      real*8 prrup(ndrup)
c
      integer ntrup,i
      character*50 fmtpr
c-----------------------------------------------------------------------
c
      ntrup = nint(prrup(1))
c
      write (6,'(/12xA,I1)') '> Uncoupled Rupture Criterion | ',ntrup
c
      fmtpr = '(16xA10,I1,A3,E20.12)'
      do i = 1,ndrup-1
        write (6,fmtpr) '. prrup(1+',i,') =',prrup(i+1)
      end do
c
      return
      end subroutine ummdp_print_rupture
c
c
c
c+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c     PRINT INFO FOR DEBUG (INFO)
c
      subroutine ummdp_print_info ( inc,nnrm,nshr )
c
c-----------------------------------------------------------------------
      implicit none
c
      common /ummdp1/ne,ip,lay
c
			integer inc,nnrm,nshr
c
			integer ne,ip,lay,nttl,nerr
      character*50 fmt1,fmt2,fmt3,ptype,tmp
c-----------------------------------------------------------------------
c
      fmt1 = '(/12xA,A)'
      fmt2 = '(/12xA,I1)'
      fmt3 =  '(12xA,I1)'
c
      nttl = nnrm + nshr
c
      write(6,'(4/8xA)') '>> Info'
c
      write (tmp,'(I)') inc
      write (6,fmt1) '        Increment : ',adjustl(tmp)
c
      call ummdp_print_element ( )
c
      write (6,fmt2) ' Total Components : ',nttl
      write (6,fmt3) 'Normal Components : ',nnrm
      write (6,fmt3) ' Shear Components : ',nshr
c
      nerr = 0
      if ( nnrm == 3 ) then
        if ( nshr == 3 ) then
          ptype = '3D Solid'
        else if ( nshr == 1 ) then
          ptype = 'Plane Strain or Axisymmetric Solid'
        else
          nerr = 1
        end if
      else if ( nnrm == 2 ) then
        if ( nshr == 1 ) then
          ptype = 'Plane Stress or Thin Shell'
        else if ( nshr == 3 ) then
          ptype = 'Thick Shell'
        else
          nerr = 1
        end if
      else
        nerr = 1
      end if
c
      if ( nerr == 0 ) then
        write (6,'(/12xA,A)') '     Element Type : ',ptype
      else
        ptype = 'Not Supported'
        write (6,'(/12xA,A)') '     Element Type : ',ptype
        call ummdp_exit ( 100 )
      end if
c
      return
      end subroutine ummdp_print_info
c
c
c
************************************************************************
c
c     PRINT INFO FOR DEBUG (INPUT/OUTPUT)
c
      subroutine ummdp_print_inout ( io,s,de,d,nttl,stv,nstv )
c
c-----------------------------------------------------------------------
      implicit none
c
			integer io,nttl,nstv
			real*8 s(nttl),stv(nstv),de(nttl),d(nttl,nttl)
c
      character*100 text
c-----------------------------------------------------------------------
c
      if ( io == 0 ) then
        write(6,'(//8xA)') '>> Input'
      else
        write(6,'(//8xA)') '>> Output'
      end if
c
      text = 'Stress'
      call ummdp_utility_print1 ( text,s,nttl,0 )
c
      text = 'Internal State Variables'
      call ummdp_utility_print1 ( text,stv,nstv,0 )
c
      text = 'Strain Increment'
      call ummdp_utility_print1 ( text,de,nttl,0 )
c
      text = 'Tangent Modulus Matrix'
      call ummdp_utility_print2 ( text,d,nttl,nttl,0 )
c
      return
      end subroutine ummdp_print_inout
c
c
c
************************************************************************
c
c     PRINT ELEMENT INFO
c
      subroutine ummdp_print_element ( )
c
c-----------------------------------------------------------------------
      implicit none
c
      common /ummdp1/ne,ip,lay
      integer ne,ip,lay
      character*100 fmt1,fmt2,tmp
c-----------------------------------------------------------------------
c
      fmt1 = '(/12xA,A)'
      fmt2 =  '(12xA,A)'
c
      write (tmp,'(I)') ne
      write (6,fmt1) '          Element : ',adjustl(tmp)
c
      write (tmp,'(I)') ip
      write (6,fmt2) 'Integration Point : ',adjustl(tmp)
c
      write (tmp,'(I)') lay
      write (6,fmt2) '            Layer : ',adjustl(tmp)
c
      return
      end subroutine ummdp_print_element
c
c
c