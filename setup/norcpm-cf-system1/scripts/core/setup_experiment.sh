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
for MEMBER in `seq -w $MEMBER1 $MEMBERN`
do

  echo ++ PICK REFERENCE DATE
  REF_YEAR=$START_YEAR
  REF_MONTH=$START_MONTH
  REF_DAY=$START_DAY
  REF_YEAR1=$START_YEAR1
  REF_MONTH1=$START_MONTH1
  REF_DAY1=$START_DAY1
  COUNT=0
  for YEAR in $REF_YEARS
  do
  for MONTH in $REF_MONTHS
  do
  for DAY in $REF_DAYS
  do
    COUNT=$((COUNT+1))
    if [ $COUNT -eq 1 ] 
    then 
      REF_YEAR=$YEAR
      REF_MONTH=$MONTH
      REF_DAY=$DAY
      REF_YEAR1=$YEAR
      REF_MONTH1=$MONTH
      REF_DAY1=$DAY
    fi  
    if [ $COUNT -eq $((MEMBER-MEMBER1+1)) ] 
    then 
      REF_YEAR=$YEAR
      REF_MONTH=$MONTH
      REF_DAY=$DAY
    fi
  done ; done ; done 
  #
  START_DATE=$START_YEAR-$START_MONTH-$START_DAY 
  SDATE=`echo $START_DATE | sed 's/-//g'`  
  REF_DATE=$REF_YEAR-$REF_MONTH-$REF_DAY 
  REF_DATE_SHORT=`echo $REF_DATE | sed 's/-//g'`  
  CASE=${EXPERIMENT}_${SDATE}_mem$MEMBER
  RELPATH=$EXPERIMENT/${EXPERIMENT}_$SDATE/$CASE
  CASEROOT=$CASESROOT/$RELPATH
  EXEROOT=$WORK/noresm/$RELPATH
  DOUT_S_ROOT=$WORK/archive/$RELPATH
  # 
  START_DATE1=$START_YEAR1-$START_MONTH1-$START_DAY1 
  SDATE1=`echo $START_DATE1 | sed 's/-//g'`  
  REF_DATE1=$REF_YEAR1-$REF_MONTH1-$REF_DAY1 
  REF_DATE_SHORT1=`echo $REF_DATE1 | sed 's/-//g'`  
  CASE1=${EXPERIMENT}_${SDATE1}_mem$MEMBER1  
  RELPATH1=$EXPERIMENT/${EXPERIMENT}_$SDATE1/$CASE1
  CASEROOT1=$CASESROOT/$RELPATH1
  EXEROOT1=$WORK/noresm/$RELPATH1

  if [[ $SKIP_CASE1 && $SKIP_CASE1 -eq 1 && $CASE == $CASE1 ]]
  then
    echo ++ SKIP CASE $CASE
    continue 
  else 
    echo ++ PREPARE CASE $CASE 
  fi 
 
  echo ++ REMOVE OLD CASE IF NEEDED
  for ITEM in $CASEROOT $EXEROOT $DOUT_S_ROOT
  do
    if [ -e $ITEM ]
    then
      if [ $ASK_BEFORE_REMOVE -eq 1 ] 
      then 
        echo "remove existing $ITEM? (y/n)"
        if [ `read line ; echo $line` == "y" ]
        then
          rm -rf $ITEM
        fi
      else
        rm -rf $ITEM
      fi
    fi
  done

  echo ++ LOCATE REFERENCE CASE 
  if [ $REF_SUFFIX_MEMBER1 ]
  then 
    REF_MEMBER1=`echo $REF_SUFFIX_MEMBER1 | tail -3c`
    if [ $RUN_TYPE == branch ]
    then 
      REF_MEMBER=`printf %02d $(( $((10#$MEMBER)) + $((10#$REF_MEMBER1)) - $((10#$MEMBER1)) ))`
    else
      REF_MEMBER=$REF_MEMBER1
    fi 
    REF_SUFFIX=`basename $REF_SUFFIX_MEMBER1 $REF_MEMBER1`$REF_MEMBER
    REF_PATH_LOCAL=`dirname $REF_PATH_LOCAL_MEMBER1`/`basename $REF_PATH_LOCAL_MEMBER1 $REF_MEMBER1`$REF_MEMBER
  else 
    REF_PATH_LOCAL=$REF_PATH_LOCAL_MEMBER1
  fi
  REF_CASE=$REF_EXPERIMENT$REF_SUFFIX
  REF_CASE1=$REF_EXPERIMENT$REF_SUFFIX_MEMBER1
  REF_PATH=$REF_PATH_LOCAL/$REF_DATE
  if [ ! -e $REF_PATH ]
  then
    echo cannot locate restart data in $REF_PATH . will keep trying   
    REF_PATH=$REF_PATH_LOCAL/rest/$REF_DATE-00000
    if [ ! -e $REF_PATH ]
    then
      echo cannot locate restart data in $REF_PATH . will quit
      exit
    fi
  fi
  echo +++ use reference case $REF_CASE in $REF_PATH

  if [ $CASE == $CASE1 ] 
  then 
    echo +++ PREPARE MEMBER 1 FROM SCRATCH

    echo +++ CREATE MEMBER 1 CASE
    $SCRIPTSROOT/create_newcase -case $CASEROOT -compset $COMPSET -res $RES -mach $MACH -pecount $PECOUNT

    echo +++ SET INITIALISATION 
    cd $CASEROOT
    ./xmlchange -file env_build.xml -id EXEROOT -val $EXEROOT
    ./xmlchange -file env_run.xml -id DOUT_S_ROOT -val $DOUT_S_ROOT
    ./xmlchange -file env_conf.xml -id RUN_REFCASE -val $REF_CASE
    ./xmlchange -file env_conf.xml -id GET_REFCASE -val FALSE
    ./xmlchange -file env_conf.xml -id BRNCH_RETAIN_CASENAME -val TRUE
    ./xmlchange -file env_conf.xml -id RUN_TYPE -val $RUN_TYPE
    ./xmlchange -file env_conf.xml -id RUN_REFDATE -val $REF_DATE
    ./xmlchange -file env_conf.xml -id RUN_STARTDATE -val $START_DATE

    echo +++ CONFIGURE MEMBER 1 CASE 
    ./configure -case

    echo +++ DEACTIVATE MICOM RESTART COMPRESSION
    sed -i s/" RSTCMP   =".*/" RSTCMP   = 0"/ Buildconf/micom.buildnml.csh

    echo +++ BUILD MEMBER 1 CASE 
    set +e 
    ./$CASE.$MACH.build
    set -e 

  else
    echo +++ CLONE MEMBER 1 
    $SCRIPTSROOT/create_clone -clone $CASEROOT1 -case $CASEROOT

    echo +++ LINK BUILD OBJECTS AND EXECUTABLE FROM MEMBER 1
    mkdir -p $EXEROOT/run/timing/checkpoints $DOUT_S_ROOT
    cd $EXEROOT
    for ITEM in atm cpl ccsm csm_share glc ice ocn pio lib
    do
      ln -s  $EXEROOT1/$ITEM .
    done
    cd run
    ln -s $EXEROOT1/run/ccsm.exe . 

    echo +++ CONFIGURE CASE 
    cd $CASEROOT
    ./xmlchange -file env_build.xml -id EXEROOT -val $EXEROOT
    ./xmlchange -file env_run.xml -id DOUT_S_ROOT -val $DOUT_S_ROOT
    ./xmlchange -file env_conf.xml -id RUN_REFCASE -val $REF_CASE
    ./xmlchange -file env_conf.xml -id GET_REFCASE -val FALSE
    ./xmlchange -file env_conf.xml -id BRNCH_RETAIN_CASENAME -val TRUE
    ./xmlchange -file env_conf.xml -id RUN_TYPE -val $RUN_TYPE
    ./xmlchange -file env_conf.xml -id RUN_REFDATE -val $REF_DATE
    ./xmlchange -file env_conf.xml -id RUN_STARTDATE -val $START_DATE
    ./configure -case

    echo +++ MODIFY RESTART PATH IN NAMELISTS
    if [ $RUN_TYPE == branch ]
    then 
      sed -i "s%$RELPATH1/run/$REF_CASE1.cam2.r.$START_DATE1%$RELPATH/run/$REF_CASE.cam2.r.$START_DATE%" Buildconf/cam.buildnml.csh 
      sed -i "s%$REF_CASE1.cice.r.$START_DATE1%$REF_CASE.cice.r.$START_DATE%" Buildconf/cice.buildnml.csh
      sed -i "s%$REF_CASE1.clm2.r.$START_DATE1%$REF_CASE.clm2.r.$START_DATE%" Buildconf/clm.buildnml.csh
      sed -i "s/start_ymd      =.*/start_ymd      = $SDATE/" Buildconf/cpl.buildnml.csh 
    else 
      echo run_type hybrid not fully implement
      exit 
    fi

    echo +++ DUMMY BUILD
    ./xmlchange -file env_build.xml -id BUILD_COMPLETE -val TRUE 
    sed -i '/source $CASETOOLS\/ccsm_buildexe/d' $CASE.$MACH.build
    ./$CASE.$MACH.build 

  fi 
  echo ++ FINISHED PREPARING CASE

  echo ++ STAGE RESTART DATA 
  cd $EXEROOT/run 
  for FPATH in `ls $REF_PATH/*nc`
  do 
    if [[ $FPATH =~ .*micom.r.* ]]
    then 
      cp -f $FPATH . 
    else 
      ln -sf $FPATH . 
    fi 
  done 
  cp -f $REF_PATH/rpointer* .  

done ; done ; done ; done 
echo + END LOOP OVER START DATES AND MEMBERS 

echo + BUILD ASSIMILATION CODE IF NEEDED
cd $SETUPROOT
source scripts/core/build_assimcode.sh $*

echo + SETUP COMPLETED
if (( $SUBMIT_AFTER_SETUP ))
then 
  echo + SUBMIT EXPERIMENT 
  cd $SETUPROOT
  ./submit_experiment.sh $* 
fi 
