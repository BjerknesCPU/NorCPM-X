#! /bin/sh -e
#SBATCH --account=nn9039k
#SBATCH --job-name=clone_restarts
#SBATCH --time=24:00:00
#SBATCH --ntasks=8
#SBATCH --mem=32GB
#SBATCH --qos=preproc
#SBATCH --output=clone_restarts.out

source /cluster/installations/lmod/lmod/init/sh
module --quiet restore system
module load StdEnv
module load netCDF/4.7.4-iompi-2020a

ARCHIVE_DIR_CASEOLD=$1 
ARCHIVE_DIR_CASENEW=$2 
COMPONENT=$3 # leave empty for cloning all 
if [[ ! -d $ARCHIVE_DIR_CASEOLD && ! -d $ARCHIVE_DIR_CASENEW ]]
then 
  echo "USAGE: $0 <archive path of original case> <archive path of new case> [<component>]"
  exit
fi 
CASEOLD=`basename $ARCHIVE_DIR_CASEOLD`
CASENEW=`basename $ARCHIVE_DIR_CASENEW`


clone () {
  if [ -d $ARCHIVE_DIR_CASEOLD/rest/$SDATE ]
  then 
    mkdir -p  $ARCHIVE_DIR_CASENEW/rest/$SDATE
    cd $ARCHIVE_DIR_CASEOLD/rest/$SDATE 
    for FNAMEOLD in `ls ${CASEOLD}.${COMPONENT}*.nc`
    do
      FNAMENEW=`echo $FNAMEOLD | sed "s/${CASEOLD}/${CASENEW}/g"`
      if [[ ${FNAMEOLD} =~ ${CASEOLD}.cpl.r.* || ${FNAMEOLD} =~ ${CASEOLD}.cam2.r.* ]]
      then 
        echo ${FNAMEOLD}
        rm -f $ARCHIVE_DIR_CASENEW/rest/$SDATE/$FNAMENEW 
        nccopy -6 ${FNAMEOLD} $ARCHIVE_DIR_CASENEW/rest/$SDATE/${FNAMEOLD}
        ncdump $ARCHIVE_DIR_CASENEW/rest/$SDATE/${FNAMEOLD} | sed "s/${CASEOLD}/${CASENEW}/g" | ncgen -o $ARCHIVE_DIR_CASENEW/rest/$SDATE/$FNAMENEW - 
        rm $ARCHIVE_DIR_CASENEW/rest/$SDATE/${FNAMEOLD}
      else 
        cp -fv $FNAMEOLD $ARCHIVE_DIR_CASENEW/rest/$SDATE/$FNAMENEW
      fi
    done 
    for FNAME in `ls rpoint*`
    do
      sed "s/${CASEOLD}/${CASENEW}/g" $FNAME > $ARCHIVE_DIR_CASENEW/rest/$SDATE/$FNAME 
    done 
  fi 
}

PROC=1 
for SDATE in `ls $ARCHIVE_DIR_CASEOLD/rest`
do
  clone & 
  if [ $PROC -lt 8 ]
  then 
    PROC=$((PROC+1))
  else 
    PROC=1
    wait
  fi   
done
wait
echo COMPLETE
