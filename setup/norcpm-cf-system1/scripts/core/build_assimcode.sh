#!/bin/sh -e

SETUPROOT=`readlink -f \`dirname $0\``
if [[ `basename $SETUPROOT` == "core" || `basename $SETUPROOT` == "util" ]]
then
  SETUPROOT=`dirname \`dirname $SETUPROOT\``
fi
. $SETUPROOT/scripts/core/source_settings.sh $*

echo + BEGIN LOOP OVER START DATES AND MEMBERS 
for START_YEAR in $START_YEARS
do
for START_MONTH in $START_MONTHS
do
for START_DAY in $START_DAYS
do

  START_DATE_SHORT=$START_YEAR$START_MONTH$START_DAY
  ANALYSISROOT=$WORK/noresm/$EXPERIMENT/${EXPERIMENT}_$START_DATE_SHORT/ANALYSIS
  START_DATE_SHORT1=$START_YEAR1$START_MONTH1$START_DAY1
  ANALYSISROOT1=$WORK/noresm/$EXPERIMENT/${EXPERIMENT}_$START_DATE_SHORT1/ANALYSIS

  if [ $START_DATE_SHORT == $START_DATE_SHORT1 ] 
  then 

    if [[ $ENKF_VERSION && $ENKF_CODE ]]
    then
      echo + build EnKF
      mkdir -p $ANALYSISROOT/bld/EnKF/TMP
      cd $ANALYSISROOT/bld/EnKF
      cp -f $ENKFROOT/shared/* . 
      cp -f $ENKF_CODE/* . 
      make clean
      make  
    fi

    if [[ $ENKF_VERSION && $PREP_OBS_CODE ]]
    then
      echo + build prep_obs
      mkdir -p $ANALYSISROOT/bld/prep_obs/TMP
      cd $ANALYSISROOT/bld/prep_obs
      cp -f $ENKFROOT/shared/* . 
      cp -f $PREP_OBS_CODE/* . 
      make clean
      make
    fi

    if [[ $ENKF_VERSION && $ENSAVE_FIXENKF_CODE ]]
    then
      echo + build ensave and fixenkf
      mkdir -p $ANALYSISROOT/bld/ensave_fixenkf/TMP
      cd $ANALYSISROOT/bld/ensave_fixenkf
      cp -f $ENKFROOT/shared/* . 
      cp -f $ENSAVE_FIXENKF_CODE/* . 
      make clean
      make
    fi

    if [[ $ENKF_VERSION && $MICOM_INIT_CODE ]]
    then
      echo + build micom_init
      mkdir -p $ANALYSISROOT/bld/micom_init
      cd $ANALYSISROOT/bld/micom_init
      cp -f $MICOM_INIT_CODE/* . 
      make clean
      make
    fi

  else 

    mkdir -p $ANALYSISROOT
    cd $ANALYSISROOT
    ln -sf $ANALYSISROOT1/* . 

  fi 
  
done; done; done  
