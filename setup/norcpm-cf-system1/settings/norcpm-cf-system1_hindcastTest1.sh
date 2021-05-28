# EXPERIMENT DEFAULT SETTINGS 
# DO NOT CHANGE, USE VARNAME=VALUE ARGUMENT WHEN CALLING SCRIPT TO OVERRIDE DEFAULTS 

# EXPERIMENT DESCRIPTION
#
# test hindcast 

# experiment settings
: ${CASE_PREFIX:=`basename $1 .sh`} # case prefix, not including _YYYYMMDD_XX suffix ; extracted from name of this file
: ${REST_PREFIX:=norcpm-cf-system1_assim_19811115_mem} 
: ${REST_PATH_REMOTE:=}
: ${REST_PATH_LOCAL:=/cluster/work/users/ingo/archive/norcpm-cf-system1_assim_19811115}
: ${START_YEARS:=1992} # multiple start dates only for prediction
: ${START_MONTHS:=09} # multiple start dates only for prediction
: ${START_DAYS:=15} # multiple start dates only for prediction
: ${REF_YEARS:=1992} # multiple reference dates only for RUN_TYPE=hybrid
: ${REF_MONTHS:=09} # multiple reference dates only for RUN_TYPE=hybrid
: ${REF_DAYS:=15} # multiple reference dates only for RUN_TYPE=hybrid
: ${REF_ENSEMBLE:=1} # set to 1 if ensemble of perturbed intial conditions with same start date, only for RUN_TYPE=hybrid
: ${REF_MEMBER1:=01}
: ${RUN_TYPE:=branch} # use "branch" if unspecified 
: ${ENSSIZE:=4} # number of members 
: ${MEMBER1:=01} # first member  
: ${STOP_OPTION:=nmonths} # units for run length specification STOP_N 
: ${STOP_N:=1} # run continuesly for this length 
: ${RESTART:=2} # restart this many times (perform assimilation twice before forecast) 
: ${WALLTIME:='24:00:00'}  
: ${STOP_OPTION_FORECAST:=ndays} # units for run length specification STOP_N 
: ${STOP_N_FORECAST:=150} # run continuesly for this length 

# general settings 
: ${VERSION:=`basename $SETUPROOT`}
: ${CASESROOT:=$SETUPROOT/../../cases/$VERSION}
: ${CCSMROOT:=$SETUPROOT/../../model/$VERSION}
: ${COMPSET:=N20TREXTAERCN1}
: ${PECOUNT:=L} # T=32, S=64, M=96, L=128, X1=502
: ${RES:=f19_g16}
: ${ACCOUNT:=nn9039k}
: ${ASK_BEFORE_REMOVE:=0} # 1=will ask before removing existing cases 
: ${MEMBERTAG:=mem} # leave empty or set to 'mem' 
: ${MAX_PARALLEL_STARCHIVE:=30} 
: ${VERBOSE:=1} # set -vx option in all scripts

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
  OBSLIST=(${OBSLIST:='TEM SAL SST'})
  PRODUCERLIST=(${PRODUCERLIST:='EN421 EN421 NOAA'})
  REF_PERIODLIST=(${REF_PERIODLIST:='1982-2016 1982-2016 1982-2016'})
  COMBINE_ASSIM=(${COMBINE_ASSIM:='0 0 1'})
  OBSLIST_PREFORECAST=(${OBSLIST:='SST'})
  PRODUCERLIST_PREFORCAST=(${PRODUCERLIST:='NOAA'})
  REF_PERIODLIST_PREFORCAST=(${REF_PERIODLIST:='1982-2016'})
  COMBINE_ASSIM_PREFORCAST=(${COMBINE_ASSIM:='1'})

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
: ${ANALYSISROOT:=$WORK/noresm/${CASE_PREFIX}_${START_YEAR1}${START_MONTH1}${START_DAY1}/ANALYSIS}
