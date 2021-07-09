# EXPERIMENT DEFAULT SETTINGS 
# DO NOT CHANGE, USE VARNAME=VALUE ARGUMENT WHEN CALLING SCRIPT TO OVERRIDE DEFAULTS 

# experiment settings
: ${EXPERIMENT:=norcpm-cf-system1_hindcast} # case prefix, not including _YYYYMMDD_memXX suffix 
: ${MEMBER1:=01} # first member  
: ${ENSSIZE:=60} # number of members 
: ${COMPSET:=N20TREXTAERCN1}
: ${RES:=f19_g16}
: ${START_YEARS:="`seq -w 1998 2001`"} # multiple start dates only for prediction
: ${START_MONTHS:="`seq -w 01 12`"} # multiple start dates only for prediction
: ${START_DAYS:=15} # multiple start dates only for prediction

# initialisation settings
: ${RUN_TYPE:=branch} # branch: reference ensemble, hybrid: single reference simulation  
: ${REF_EXPERIMENT:=norcpm-cf-system1_assim_19811115} # name of reference experiment, including start date if necessary
: ${REF_SUFFIX_MEMBER1:=_mem01} # reference run used to initialise first member for 'branch', all members for 'hybrid' 
: ${REF_PATH_LOCAL_MEMBER1:=/cluster/work/users/$USER/archive/$REF_EXPERIMENT/${REF_EXPERIMENT}${REF_SUFFIX_MEMBER1}}
: ${REF_PATH_REMOTE_MEMBER1:=}
: ${REF_YEARS:=} # multiple reference dates only for RUN_TYPE=hybrid
: ${REF_MONTHS:=} # multiple reference dates only for RUN_TYPE=hybrid
: ${REF_DAYS:=} # multiple reference dates only for RUN_TYPE=hybrid

# job settings
: ${STOP_OPTION:=nmonths} # units for run length specification STOP_N 
: ${STOP_N:=1} # run continuesly for this length 
: ${RESTART:=2} # restart this many times (perform assimilation three times before forecast) 
: ${WALLTIME:='48:00:00'}  
: ${STOP_OPTION_FORECAST:=ndays} # units for run length specification STOP_N 
: ${STOP_N_FORECAST:=142} # run continuesly for this length 
: ${PECOUNT:=T} # T=32, S=64, M=96, L=128, X1=502
: ${ACCOUNT:=nn9039k}
: ${MAX_PARALLEL_STARCHIVE:=30} 

# general settings 
: ${VERSION:=`basename $SETUPROOT`} # e.g. norcpm-cf-system1 
: ${CASESROOT:=$SETUPROOT/../../cases/$VERSION}
: ${CCSMROOT:=$SETUPROOT/../../model/$VERSION}
: ${SUBMIT_AFTER_SETUP:=0} # auto-submit after setting up experiment  
: ${ASK_BEFORE_REMOVE:=1} # 1=will ask before removing existing cases 
: ${VERBOSE:=1} # set -vx option in all scripts
: ${SKIP_CASE1:=0} # skip creating first/template case, assume it exists already 

# assimilation settings
: ${ENKF_VERSION:=2} # unset/empty=no assimilation  1=WCDA without sea ice update  2=SCDA with sea ice update 
: ${ENKFROOT:=$SETUPROOT/../../assim/$VERSION}
: ${ENKF_CODE:=$ENKFROOT/EnKF_i$ENKF_VERSION}
: ${ENSAVE_FIXENKF_CODE:=$ENKFROOT/ensave_fixenkf}
: ${MICOM_INIT_CODE:=$ENKFROOT/micom_init}
: ${PREP_OBS_CODE:=$ENKFROOT/prep_obs}
: ${ENSAVE:=1} # diagnose ensemble averages
: ${SKIPASSIM:=0} # skip first assimilation update ; will be forced to 1 at experiment start   
: ${RFACTOR_START:=8} # inflation factor at experiment start 
: ${COMPENSATE_ICE_FRESHWATER:=1} # only for use together with sea ice update
: ${ENKF_NTASKS:=128}
: ${MICOM_INIT_NTASKS_PER_MEMBER:=16}
: ${ENKFROOT:=$SETUPROOT/../../assim/$VERSION} 
: ${OCNGRIDFILE:=$INPUTDATA/ocn/micom/gx1v6/20101119/grid.nc}
  OBSLIST=('TEM SAL SST')
  PRODUCERLIST=('EN421 EN421 NOAA')
  REF_PERIODLIST=('1982-2016 1982-2016 1982-2016')
  COMBINE_ASSIM=('0 0 1')
  OBSLIST_PREFORECAST=('SST')
  PRODUCERLIST_PREFORCAST=('NOAA')
  REF_PERIODLIST_PREFORCAST=('1982-2016')
  COMBINE_ASSIM_PREFORCAST=('1')

# derived settings
: ${START_YEAR1:=`echo $START_YEARS | cut -d" " -f1`}
: ${START_MONTH1:=`echo $START_MONTHS | cut -d" " -f1`}
: ${START_DAY1:=`echo $START_DAYS | cut -d" " -f1`}
: ${REF_YEAR1:=`echo $REF_YEARS | cut -d" " -f1`}
: ${REF_MONTH1:=`echo $REF_MONTHS | cut -d" " -f1`}
: ${REF_DAY1:=`echo $REF_DAYS | cut -d" " -f1`}
: ${MEMBERN:=`expr $MEMBER1 + $ENSSIZE - 1`}
: ${REF_MEMBERN:=`expr $REF_MEMBER1 + $ENSSIZE - 1`}
: ${SCRIPTSROOT:=$CCSMROOT/scripts}
