--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-9 -------------------------------
--------------------------------------------------------------------------------

Added 2d flux diagnostics for MICOM, added functionality for multi-instance 
runs, revision of short-term archiving, fix of N20TREXTAERCN compset, 
new locations for single-column MICOM configuration and revised 
cpu-configurations.

Change history: projectsEPOCASA-8 -> projectsEPOCASA-9 
(55369fd2d0f890c784ffab5aa7340fac2bc7dea4 (svn r544) - 
daf4ae5dc03e42f02076cb558c69c5b5ae721969 (svn r636))

Revision 636

Added RCP85 cpp-flag for CAM-OSLO to extended historical compset N20TREXTAERCN 
to ensure that RCP8.5 aerosol emissions are used after 2005. Added transport 
diagnostics to MICOM output. Added single-column MICOM configurations for BATS 
and ALOHA. 
Modified short-term archiving script to include updates from Francois. 
Revised cpu-configurations to S (64 cpus, 2.4 sim-yr/d hexagon, 5.5 sim-yr/d 
vilje), M (96, 4.3, 8.7), L (160, 6.1, 12.3), X1 (310, 10.8, 21.7) and X2 
(415, 13.6, 29.1). 

Revision 558 

Modified short-term archiving script to avoid use of temporary directories.

Revision 557 

Added functionality to run ensemble in SPMD mode. Fixed 2d flux diagnostic 
entries in MICOM namelist.

Revision 556 

Added 2d flux diagnostics for MICOM. Added 21-pe patch for gx1 grid and 
256/315-pe patches for tnx1 grid.

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-8 -------------------------------
--------------------------------------------------------------------------------

Added fv1.9x2.5_tnx1.5 grid configuration with customized compsets.

Change history: projectsEPOCASA-7 -> projectsEPOCASA-8 
(5ce688ba90401ccf3aa0b55f4cf681ba3a09420e (svn r523) - 
55369fd2d0f890c784ffab5aa7340fac2bc7dea4 (svn r544))

Revision 544 

Fixed bug in TS-nudging and fixed problem in st_archive.csh that occurred when 
running on a single cpu. Customized F19_tn1.5 configuration. Updated module 
specifications for vilje and compiler optimization for vilje and hexagon. 

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-7 -------------------------------
--------------------------------------------------------------------------------

Added MICOM column and CLM stand-alone configurations.  

Change history: projectsEPOCASA-6 -> projectsEPOCASA-7 (r486 - r523)

Revision 523 

Set path to CLM forcing data. Set default cpu account to nn9039k.

Revision 518 

Added MICOM single column compsets NOINY1, NOINYOC1, NOIIA1 and NOIIAOC1. Added 
nudging functionality for 3d temperature and salinity. Update pes-configurations 
and history output specifications. Changed compiler optimisation from barcelona 
to interlagos. 

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-6 -------------------------------
--------------------------------------------------------------------------------

I/O optimisation of short-term archiving to reduce I/O load on login nodes. 

Change history:  projectsEPOCASA-5 -> projectsEPOCASA-6 (r401 -> r486)

Revision 486

Changed short-term archiving script: copying operations are now performed on 
backend rather than on the login node; information from rpointer files is used 
to identify latest restart files (previously, the file time step has been used 
for this purpose).  

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-5 -------------------------------
--------------------------------------------------------------------------------

Bug fixes that affect writing of daily ocean diagnostics and running of
NorESM1-ME.

Change history:  

Fixed writing of daily MICOM diagnostics when restarting at the middle of a
month. 

Added wrap_close statements to emissions.F90 file of CAM-OSLO to avoid NorESM
crash as consequence of too many open files.

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-4 -------------------------------
--------------------------------------------------------------------------------

NorESM version for GREENICE project. 

Change history:  

Includes a new WACCM physics-only configuration, additional AMIP compsets,
diagnostic output changes for the land model and updated module specifications
for HEXAGON.  

New atmospheric configuration WACCM_PHYS (WP):  
-66 vertical levels with WACCM physics activated 
-chemistry deactivated (as in standard CAM4) 
-configured for 1deg and 2deg finite volume resolutions

New compsets: 

F_WACCM_PHYS_AMIP_CN (FWPAMIPCN): WACCM physics on 66 levels, prescribed GHG 
and SST/sea ice 1979-2012  

F_2000_WACCM_PHYS (FWP): WACCM physics on 66 levels, fixed 2000 GHGs, modern 
SST/sea ice climatology

F_1850_WACCM_PHYS (F1850WP): WACCM physics on 66 levels, fixed 1850 GHGs, 
modern SST/sea ice climatology   

N_WACCM_PHYS_1850 (NWP1850): WACCM physics on 66 levels coupled to MICOM  

Namelist changes: clm default diagnostic output is set to monthly instead of
annual

Machine specific changes: updated module specifications in 
env_machopts.hexagon_intel and env_machopts.hexagon_pgi

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-3 -------------------------------
--------------------------------------------------------------------------------

Introduces new NorCPM version that is based on the CMIP5 NorESM1-ME version
(with minor modifications). 

Change history:  

Partially accumulated MICOM diagnostics are only read if all present in restart
file.

New compset N20TREXTAERCN for extended historical simulations (RCP8.5 after
2005) using CAM-OSLO atmosphere component.

Configured f19_gx1 to be close to NorESM1-ME. Differences are reduced mixing
under sea ice and stronger damping of coastal waves. Simplified and modified
specification of diagnostic output. In particular, the default output for
f19_gx1 is heavily reduced. Applied changes to MICOM source code that disable
global budget computations by default, make it possible to read NorESM1-ME
restart information and make it possible to overwrite existing data (feature
needed for assimilation).  

For computational efficient set-up f19_tn2: changed rhminl back to 0.895 to be
consistence with first set of NorCPM experiments performed by Francois

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-2 -------------------------------
--------------------------------------------------------------------------------

Freeze of physical model system to be used in the first 20C reanalysis
experiment in EPOCASA 

Change history:  

Changed rhminl back to 0.895 to be consistent with existing NorCPM experiments
performed by Francois Counillon.

--------------------------------------------------------------------------------
------------------------------- projectEPOCASA-1 -------------------------------
--------------------------------------------------------------------------------

First model version that is used in project EPOCASA. This version is based on
r208 of the NorESM branch cesm1_0_4_previous_trunk-1

Change history: 

WACCM specific changes: Added hexagon/vilje pes-configurations for FW* compsets.
Fixed WACCM io problem on hexagon. Updated hexagon compiler specifications for
intel. 
