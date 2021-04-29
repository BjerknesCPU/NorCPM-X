#! /bin/csh -f

set objdir = $OBJROOT/atm/obj; cd $objdir

set comp = "unknown"
if ($COMP_INTERFACE == 'MCT' ) set comp = mct
if ($COMP_INTERFACE == 'ESMF') set comp = esmf

\cat >! .tmp << EOF; cmp -s .tmp Filepath || mv -f .tmp Filepath 
$CASEROOT/SourceMods/src.cam
/cluster/projects/nn9039k/people/ingo/NorCPM-X/model/norcpm-cf-system1/models/atm/cam/src/chemistry/pp_none
$CODEROOT/atm/cam/src/chemistry/mozart
$CODEROOT/atm/cam/src/physics/cam_oslo
$CODEROOT/atm/cam/src/chemistry/bulk_aero
$CODEROOT/atm/cam/src/chemistry/utils
$CODEROOT/atm/cam/src/physics/cam
$CODEROOT/atm/cam/src/dynamics/fv
$CODEROOT/atm/cam/src/cpl_$comp
$CODEROOT/atm/cam/src/cpl_share
$CODEROOT/atm/cam/src/control
$CODEROOT/atm/cam/src/utils
$CODEROOT/atm/cam/src/utils/pilgrim
EOF

set camdefs = "   -DCO2A -DMAXPATCH_PFT=numpft+1 -DLSMLAT=1 -DLSMLON=1 -DPLON=144 -DPLAT=96 -DPLEV=26 -DPCNST=28 -DPCOLS=16 -DPTRM=1 -DPTRN=1 -DPTRK=1 -DSTAGGERED  -DSPMD -DAERLIFE -DDIRIND -DAER1850 -DRCP85"
gmake complib -j $GMAKE_J MODEL=cam COMPLIB=$LIBROOT/libatm.a MACFILE=$CASEROOT/Macros.$MACH USER_CPPDEFS="$camdefs" -f $CASETOOLS/Makefile || exit 2

wait

